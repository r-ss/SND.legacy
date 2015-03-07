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

    // Restoring volume from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //DDLogInfo(@"Volume found: %@", [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]);
    [self setVolume:[NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]];
    [volumeSlider setIntegerValue:self.volume.doubleValue];
    
    
    if (!BASS_PluginLoad("libbassflac.dylib", 0)) {
        DDLogError(@"Can't load BASS FLAC Plugin libbassflac.dylib");
    }

    [self initBASS];
    
    //DDLogInfo(@"NUUUUU");
    //[self rawTest];

}

- (void) initBASS {
//    self.player = [[ORGMEngine alloc] init];
//    self.player.delegate = self;
//    [self.player setVolume:self.volume.doubleValue];
    if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
        DDLogError(@"An incorrect version of BASS was loaded");
        //return 0;
    }
    if (!BASS_Init(-1,44100,0,win,NULL)) {
        DDLogError(@"Can't initialize BASS device");
        //return 0;
    }
    
}

/*

Error codes list
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



- (void) rawTest {
    
    //BASS_init(-1 ,44100,0,0,NULL ) ;
    
    //Bass.BASS_Init(-1, 44100, BASSInit.BASS_DEVICE_DEFAULT, IntPtr.Zero);
    //DDLogInfo(@"%u", system("pwd"));
    //char filename[] = "song.mp3";
    //char filename[] = "/Users/ress/Desktop/song.mp3";
    char filename[] = "/Users/ress/Desktop/flac.flac";
    //FSRefMakePath(&fr,(BYTE*)file,sizeof(file));
    //NSString *filename = [NSString stringWithFormat:@"/Users/ress/Desktop/song.mp3"];
    
    //char file[256];
    //FSRefMakePath(&fr,(BYTE*)file,sizeof(file));
    
    
    HSTREAM stream;
    stream = BASS_StreamCreateFile(FALSE, filename, 0, 0, 0);
    //stream =BASS_StreamCreateURL(filename, 0, 0, NULL, 0);
    if (!stream) {
        DDLogInfo(@"no stream");
    }
    
    //int BASS_ErrorGetCode();
    DDLogError(@"error %u", BASS_ErrorGetCode());
    
    BASS_ChannelPlay(stream,TRUE);

}



// overriding synthesized setVolume method
- (void) setVolume:(NSNumber *)volume {
    _volume = volume;
    
    float vol = self.volume.floatValue / 100;
    DDLogInfo(@"Vol: %f", vol);
    BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, vol);

//    [self.player setVolume:_volume.doubleValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:_volume.doubleValue forKey:@"SNDVolume"];
    [userDefaults synchronize];
}

- (IBAction)volumeSlider:(NSSlider *)sender {
    DDLogInfo(@"> volumeSlider");
    [self setVolume:[NSNumber numberWithInteger:[sender integerValue]]];
}

- (IBAction)positionSlider:(NSSlider *)sender {
    if(self.isPlaying){
//        [self.player seekToTime:[sender doubleValue]];
        QWORD pos = [sender doubleValue];
        BASS_ChannelSetPosition(stream, pos, BASS_POS_BYTE);
        
        
    } else {
        [positionSlider setDoubleValue:self.position.doubleValue];
    }
}

- (void) updatePositionViews {
    //[durationOutlet setStringValue:[NSString stringWithString:[[NSNumber alloc] hhmmssFromSeconds:self.position]]];
    
    double seconds = BASS_ChannelBytes2Seconds(stream, _position.doubleValue);
    [durationOutlet setStringValue:[NSString stringWithString:[[NSNumber alloc] hhmmssFromSeconds: [NSNumber numberWithDouble: seconds]]]];
    
    [positionSlider setDoubleValue:self.position.doubleValue];
}

-(void) timerTick: (NSTimer *)timer {
//    self.position = [NSNumber numberWithDouble:self.player.amountPlayed];
    QWORD pos = BASS_ChannelGetPosition(stream, BASS_POS_BYTE);
    _position = [NSNumber numberWithDouble: pos];
    [self updatePositionViews];
}

- (void) playTrack:(SNDTrack *)track {
    if(track){
        DDLogInfo(@"track path: %@", track.path);
        
        const char *filename =[track.path UTF8String];
        
        
        DDLogInfo(@"Channel status: %u", BASS_ChannelIsActive(stream));
        if (BASS_ChannelIsActive(stream) == 1 ) {
            DDLogInfo(@"Channel is active");
            BASS_ChannelStop(stream);
            BASS_StreamFree(stream);
        }
        
        
        stream = BASS_StreamCreateFile(FALSE, filename, 0, 0, 0);
        //stream =BASS_StreamCreateURL(filename, 0, 0, NULL, 0);
        if (!stream) {
            DDLogError(@"no stream");
        }
        
        int error_code = BASS_ErrorGetCode();
        if(error_code != 0){
            DDLogError(@"BASS Error %u", error_code);
        }
        
        BASS_ChannelPlay(stream,TRUE);
        
        error_code = BASS_ErrorGetCode();
        if(error_code != 0){
            DDLogError(@"BASS Error %u", error_code);
        }
        
        //_isPlaying = YES;
        [self bassChangedState];
        
    }
}

- (void) playPauseAction {
//    if(self.player.currentState == ORGMEngineStatePlaying){
//        [self.player pause];
//    } else if (self.player.currentState == ORGMEngineStatePaused) {
//        [self.player resume];
//    }
    if(self.isPlaying){
//        DDLogInfo(@"Channel status: %u", BASS_ChannelIsActive(stream));
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
//    DDLogInfo(@"> checkBASSState");
    int state = BASS_ChannelIsActive(stream);
    
//    0 - BASS_ACTIVE_STOPPED   The channel is not active, or handle is not a valid channel.
//    1 - BASS_ACTIVE_PLAYING   The channel is playing (or recording).
//    2 - BASS_ACTIVE_PAUSED    The channel is paused.
//    3 - BASS_ACTIVE_STALLED   Playback of the stream has been stalled due to a lack of sample data.
//                              The playback will automatically resume once there is sufficient data to do so.

    switch (state) {
        case 0: {
            DDLogInfo(@">>> BASS Stopped");
            [self.timer invalidate];
            _isPlaying = NO;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
            break;
        }
        case 1: {
            DDLogInfo(@">>> BASS Playing");
            //self.duration = [NSNumber numberWithDouble:self.player.trackTime];
            
            DDLogWarn(@">>> Channel Length %llu", BASS_ChannelGetLength(stream, BASS_POS_BYTE));
            
            //DWORD mode = "BASS_POS_BYTE";
            QWORD length_bytes = BASS_ChannelGetLength(stream, BASS_POS_BYTE);
//            int error_code = BASS_ErrorGetCode();
//            DDLogError(@"BASS Error %u", error_code);
            float length_seconds = BASS_ChannelBytes2Seconds(stream, length_bytes);
            DDLogInfo(@"Length %f", length_seconds);
            
            
            _duration = [NSNumber numberWithDouble:length_bytes];
            
            /*
            
            Getting the elapsed and remaining time:
            // length in bytes
            long len = Bass.BASS_ChannelGetLength(channel);
            // position in bytes
            long pos = Bass.BASS_ChannelGetPosition(channel);
            // the total time length
            double totaltime = Bass.BASS_ChannelBytes2Seconds(channel, len);
            // the elapsed time length
            double elapsedtime = Bass.BASS_ChannelBytes2Seconds(channel, pos);
            double remainingtime = totaltime - elapsedtime;
             */
            
            
            
            [positionSlider setMaxValue:self.duration.doubleValue];
            
            [self setVolume: self.volume];
            
            
            
            [self updatePositionViews];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            _isPlaying = YES;
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStartedPlaying" object:self];
            break;
        }
        case 2:case 3 : {
            DDLogInfo(@">>> BASS Paused (or stalled)");
            [self.timer invalidate];
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

//#pragma mark - ORGMEngineDelegate
//- (NSURL *) engineExpectsNextUrl:(ORGMEngine *)engine {
//    SNDTrack *nextTrack = [self.sndBox nextTrack];
//    DDLogInfo(@"next track is: %@", nextTrack);
//    return nextTrack.url;
//}
//
//- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state {
//    switch (state) {
//        case ORGMEngineStateStopped: {
//            DDLogInfo(@">>> ORGMEngineStateStopped");
//            self.isPlaying = NO;
//            [self.timer invalidate];            
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
//            self.player = nil;
//            break;
//        }
//        case ORGMEngineStatePaused: {
//            DDLogInfo(@">>> ORGMEngineStatePaused");           
//            self.isPlaying = NO;
//            [self.timer invalidate];
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
//            break;
//        }
//        case ORGMEngineStatePlaying: {
//            DDLogInfo(@">>> ORGMEngineStatePlaying");
//            [self.player setVolume:self.volume.doubleValue];
//            //self.position = [NSNumber numberWithDouble:0];
//            self.duration = [NSNumber numberWithDouble:self.player.trackTime];
//            [positionSlider setMaxValue:self.duration.doubleValue];
//            [self updatePositionViews];
//            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];          
//            self.isPlaying = YES;           
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerStartedPlaying" object:self];
//            break;
//        }
//        case ORGMEngineStateError:
//            DDLogInfo(@">>> ORGMEngineStateError");
//            self.player = nil;
//            break;
//    }
//}


@end
