//
//  SNDPlayer.m
//  SND
//
//  Created by Alex Antipov on 4/20/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//
#import "SNDPlayer.h"
//#import <OrigamiEngine/ORGMEngine.h>
#import "NSNumber+hhmmssFromSeconds.h"

#include "bass.h"

WindowPtr win=NULL; // Bass's shit
HSTREAM stream; // Bass's shit




// CocoaLumberjack Logger - https://github.com/CocoaLumberjack/CocoaLumberjack
#import <CocoaLumberjack/CocoaLumberjack.h>
// Debug levels: off, error, warn, info, verbose
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;



// private part
//@interface SNDPlayer() <ORGMEngineDelegate>
@interface SNDPlayer()
//@property (strong) ORGMEngine *player;
@property (nonatomic) NSTimer *timer;
@end

@implementation SNDPlayer

@synthesize acceptableFileExtensions = _acceptableFileExtensions;
@synthesize isPlaying = _isPlaying;
@synthesize volume = _volume;
@synthesize position = _position;
@synthesize duration = _duration;
@synthesize timer = _timer; // private
//@synthesize player = _player; // private

/* OGRMEngine methods
[_player metadata];                         // current metadata
[_player pause];                            // pause playback
[_player resume];                           // resume playback
[_player stop];                             // stop playback
[_player seekToTime:seekSlider.value];      // seek to second
[_player setNextUrl:url withDataFlush:YES]; // play next track and clear current buffer
*/

- (void)awakeFromNib {
    _acceptableFileExtensions = [[NSArray alloc] initWithObjects:@"mp3", @"flac", @"wav", nil];
    
    _volume = [NSNumber numberWithDouble:100];
    _isPlaying = NO;
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];

    // Restoring volume from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    DDLogInfo(@"Volume found: %@", [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]);
    int defaultsVolume = [userDefaults doubleForKey:@"SNDVolume"];
    if (defaultsVolume == 0){
        defaultsVolume = 100;
    }
    [self setVolume: [NSNumber numberWithInteger:defaultsVolume]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [volumeSlider setIntegerValue:defaultsVolume];
    });   
    
    if (!BASS_PluginLoad("libbassflac.dylib", 0)) {
        DDLogError(@"Can't load BASS FLAC Plugin libbassflac.dylib");
    }

    [self initBASS];
   //DDLogError(@"hello");
}

- (void) initBASS {
    DDLogInfo(@"> initBASS");
    if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
        DDLogError(@"An incorrect version of BASS was loaded");
        //return 0;
    }
    if (!BASS_Init(-1,44100,0,win,NULL)) {
        DDLogError(@"Can't initialize BASS device");
        //return 0;
    }
    
    BASS_SetConfig(BASS_CONFIG_BUFFER, 500);
    BASS_SetConfig(BASS_CONFIG_UPDATETHREADS, 1);
    BASS_SetConfig(BASS_CONFIG_UPDATEPERIOD, 30);
}

/*

BASS Error codes list
0	BASS_OK
1	BASS_ERROR_MEM
2	BASS_ERROR_FILEOPEN
3	BASS_ERROR_DRIVER
4	BASS_ERROR_BUFLOST
5	BASS_ERROR_HANDLE
6	BASS_ERROR_FORMAT
7	BASS_ERROR_POSITION
8	BASS_ERROR_INIT
9	BASS_ERROR_START
10	BASS_ERROR_SSL
14	BASS_ERROR_ALREADY
18	BASS_ERROR_NOCHAN
19	BASS_ERROR_ILLTYPE
20	BASS_ERROR_ILLPARAM
21	BASS_ERROR_NO3D
22	BASS_ERROR_NOEAX
23	BASS_ERROR_DEVICE
24	BASS_ERROR_NOPLAY
25	BASS_ERROR_FREQ
27	BASS_ERROR_NOTFILE
29	BASS_ERROR_NOHW
31	BASS_ERROR_EMPTY
32	BASS_ERROR_NONET
33	BASS_ERROR_CREATE
34	BASS_ERROR_NOFX
37	BASS_ERROR_NOTAVAIL
38	BASS_ERROR_DECODE
39	BASS_ERROR_DX
40	BASS_ERROR_TIMEOUT
41	BASS_ERROR_FILEFORM
42	BASS_ERROR_SPEAKER
43	BASS_ERROR_VERSION
44	BASS_ERROR_CODEC
45	BASS_ERROR_ENDED
46	BASS_ERROR_BUSY
-1	BASS_ERROR_UNKNOWN

*/


// overriding synthesized setVolume method
- (void) setVolume:(NSNumber *)volume {
    _volume = volume;
    float vol = self.volume.floatValue / 100;
    //DDLogInfo(@"Vol: %f", vol);
    BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, vol);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:_volume.doubleValue forKey:@"SNDVolume"];
    [userDefaults synchronize];
}

- (IBAction)volumeSlider:(NSSlider *)sender {
    [self setVolume:[NSNumber numberWithInteger:[sender integerValue]]];
}

- (IBAction)positionSlider:(NSSlider *)sender {
    QWORD pos = [sender doubleValue];
    BASS_ChannelSetPosition(stream, pos, BASS_POS_BYTE);
    if(!self.isPlaying){
        BASS_ChannelPlay(stream, FALSE);
        [self bassChangedState];
    }
}

- (void) updatePositionViews {
    
    if(self.isPlaying){
        double seconds = BASS_ChannelBytes2Seconds(stream, _position.doubleValue);
        
        if (seconds == -1){
            seconds = 0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            DDLogWarn(@"seconds: %f", seconds);
            [durationOutlet setStringValue:[NSString stringWithString:[[NSNumber alloc] hhmmssFromSeconds: [NSNumber numberWithDouble: seconds]]]];
            [positionSlider setDoubleValue:self.position.doubleValue];
        });
    }
    
}

- (void) timerTick: (NSTimer *)timer {
//    self.position = [NSNumber numberWithDouble:self.player.amountPlayed];
    QWORD pos = BASS_ChannelGetPosition(stream, BASS_POS_BYTE);
    _position = [NSNumber numberWithDouble: pos];
    [self updatePositionViews];
}

- (void) playTrack:(SNDTrack *)track {
    if(track){
        // resetting slider (not necessary)
        _duration = [NSNumber numberWithInt:100];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [positionSlider setDoubleValue:0];
        });
        
        
        const char *filename = [track.path UTF8String];

        //DDLogInfo(@"Channel status: %u", BASS_ChannelIsActive(stream));
        if (BASS_ChannelIsActive(stream) == 1 ) {
            DDLogInfo(@"Channel is active");
            BASS_ChannelStop(stream);
            BASS_StreamFree(stream);
        }
        
        stream = BASS_StreamCreateFile(FALSE, filename, 0, 0, 0);
        if (stream) {
            //SNDTrack *nextTrack = [self.sndBox nextTrack];
            //DDLogInfo(@"Next track is: %@", nextTrack);
            
            
            //BASS_ChannelSetSync(stream, BASS_SYNC_POS, 50000, PosSyncProc, (__bridge void *)(self));
            BASS_ChannelSetSync(stream, BASS_SYNC_END, 0, EndSyncProc, (__bridge void *)(self));
            
            BASS_ChannelPlay(stream,TRUE);
        } else {
            DDLogError(@"No stream");
        }
        
        int error_code = BASS_ErrorGetCode();
        if(error_code != 0){
            DDLogError(@"BASS Error %u", error_code);
        }

        //_isPlaying = YES;
        [self bassChangedState];
    }
}

//void CALLBACK PosSyncProc(HSYNC handle, DWORD channel, DWORD data, void *user)
//{
//    DDLogInfo(@">>>>>>>> PosSyncProc <<<<<<<<<");
//    //BASS_ChannelStop(stream);
//    //BASS_StreamFree(stream);
//    SNDPlayer *selfObj = (__bridge SNDPlayer*)user;
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc postNotificationName:@"SND.Notification.PlayingJustStarted" object:selfObj];
//}

void CALLBACK EndSyncProc(HSYNC handle, DWORD channel, DWORD data, void *user)
{
    DDLogInfo(@"> EndSyncProc");
    BASS_ChannelStop(stream);
    BASS_StreamFree(stream);
    
    
    
    SNDPlayer *selfObj = (__bridge SNDPlayer*)user;
    [selfObj end];
    
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"SND.Notification.PlayingReachedEnd" object:selfObj];
    
    [selfObj bassChangedState];

}

- (void) end {
    DDLogInfo(@"end");
    //[self.timer invalidate];
    _position = [NSNumber numberWithDouble:0];
    _duration = [NSNumber numberWithDouble:0];
    [self updatePositionViews];
}


- (void) playPauseAction {
    if(self.isPlaying){
        DDLogInfo(@"PAUSING");
        BASS_ChannelPause(stream);
        [self bassChangedState];
    } else {
        DDLogInfo(@"RESUME");
        BASS_ChannelPlay(stream, FALSE);
        [self bassChangedState];
    }
    
}

- (void) bassChangedState {
    //DDLogInfo(@"> checkBASSState");
    int state = BASS_ChannelIsActive(stream);
    
//    0 - BASS_ACTIVE_STOPPED   The channel is not active, or handle is not a valid channel.
//    1 - BASS_ACTIVE_PLAYING   The channel is playing (or recording).
//    2 - BASS_ACTIVE_PAUSED    The channel is paused.
//    3 - BASS_ACTIVE_STALLED   Playback of the stream has been stalled due to a lack of sample data.
//                              The playback will automatically resume once there is sufficient data to do so.

    switch (state) {
        case BASS_ACTIVE_STOPPED: {
            DDLogInfo(@">>> BASS Stopped");
            dispatch_async(dispatch_get_main_queue(), ^{
               [self.timer invalidate];
            });
            _isPlaying = NO;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
            break;
        }
        case BASS_ACTIVE_PLAYING: {
            DDLogInfo(@">>> BASS Playing");
            QWORD length_bytes = BASS_ChannelGetLength(stream, BASS_POS_BYTE);
            //float length_seconds = BASS_ChannelBytes2Seconds(stream, length_bytes);
            
            _duration = [NSNumber numberWithDouble:length_bytes];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [positionSlider setMaxValue:self.duration.doubleValue];
            });
            
            
            [self setVolume: self.volume];

            [self updatePositionViews];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            });

            
            
            _isPlaying = YES;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStartedPlaying" object:self];
            break;
        }
        case BASS_ACTIVE_PAUSED:case BASS_ACTIVE_STALLED : {
            DDLogInfo(@">>> BASS Paused (or stalled)");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.timer invalidate];
            });
            _isPlaying = NO;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
            break;
        }
//        case 3: {
//            DDLogError(@">>> BASS STALLED");
//            _isPlaying = NO;
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
//            break;
//        }
            
    }
}


@end
