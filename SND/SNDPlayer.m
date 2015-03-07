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

WindowPtr win=NULL;

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
@synthesize position, duration;
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
    self.isPlaying = NO;

    // Restoring volume from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSLog(@"Volume found: %@", [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]);
    [self setVolume:[NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]];
    [volumeSlider setIntegerValue:self.volume.doubleValue];
    
    NSLog(@"NUUUUU");
    //[self rawTest];

}

- (void) initOGRMEngine {
//    self.player = [[ORGMEngine alloc] init];
//    self.player.delegate = self;
//    [self.player setVolume:self.volume.doubleValue];
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
    BASS_PluginLoad("libbassflac.dylib", 0);
    
    //BASS_init(-1 ,44100,0,0,NULL ) ;
    
    //Bass.BASS_Init(-1, 44100, BASSInit.BASS_DEVICE_DEFAULT, IntPtr.Zero);
    //NSLog(@"%u", system("pwd"));
    //char filename[] = "song.mp3";
    //char filename[] = "/Users/ress/Desktop/song.mp3";
    char filename[] = "/Users/ress/Desktop/flac.flac";
    //FSRefMakePath(&fr,(BYTE*)file,sizeof(file));
    //NSString *filename = [NSString stringWithFormat:@"/Users/ress/Desktop/song.mp3"];
    
    //char file[256];
    //FSRefMakePath(&fr,(BYTE*)file,sizeof(file));
    if (HIWORD(BASS_GetVersion())!=BASSVERSION) {
        NSLog(@"An incorrect version of BASS was loaded");
        //return 0;
    }
    if (!BASS_Init(-1,44100,0,win,NULL)) {
        NSLog(@"Can't initialize device");
        //return 0;
    }
    
    HSTREAM stream;
    stream = BASS_StreamCreateFile(FALSE, filename, 0, 0, 0);
    //stream =BASS_StreamCreateURL(filename, 0, 0, NULL, 0);
    if (!stream) {
        NSLog(@"no stream");
    }
    
    //int BASS_ErrorGetCode();
    NSLog(@"error %u", BASS_ErrorGetCode());
    
    BASS_ChannelPlay(stream,TRUE);

}



// overriding synthesized setVolume method
- (void) setVolume:(NSNumber *)volume {
    _volume = volume;
//    [self.player setVolume:_volume.doubleValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:_volume.doubleValue forKey:@"SNDVolume"];
    [userDefaults synchronize];
}


- (IBAction)volumeSlider:(NSSlider *)sender {
    [self setVolume:[NSNumber numberWithDouble:[sender doubleValue]]];
}

- (IBAction)positionSlider:(NSSlider *)sender {
    if(self.isPlaying){
//        [self.player seekToTime:[sender doubleValue]];
    } else {
        [positionSlider setDoubleValue:self.position.doubleValue];
    }
}

- (void) updatePositionViews {
    [durationOutlet setStringValue:[NSString stringWithString:[[NSNumber alloc] hhmmssFromSeconds:self.position]]];
    [positionSlider setDoubleValue:self.position.doubleValue];    
}

-(void) timerTick: (NSTimer *)timer {
//    self.position = [NSNumber numberWithDouble:self.player.amountPlayed];
    [self updatePositionViews];
}

- (void) playTrack:(SNDTrack *)track {
    if(track){
//        if(!self.player)
//            [self initOGRMEngine];
        
//        if(self.player.currentState == ORGMEngineStatePlaying){
//            //NSLog(@"A");
//            [self.player setNextUrl:track.url withDataFlush:YES];
//        } else {
//            //NSLog(@"B");
//            [self.player playUrl:track.url];            
//        }
    }
}

- (void) playPauseAction {
//    if(self.player.currentState == ORGMEngineStatePlaying){
//        [self.player pause];
//    } else if (self.player.currentState == ORGMEngineStatePaused) {
//        [self.player resume];
//    }
}

//#pragma mark - ORGMEngineDelegate
//- (NSURL *) engineExpectsNextUrl:(ORGMEngine *)engine {
//    SNDTrack *nextTrack = [self.sndBox nextTrack];
//    NSLog(@"next track is: %@", nextTrack);
//    return nextTrack.url;
//}
//
//- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state {
//    switch (state) {
//        case ORGMEngineStateStopped: {
//            NSLog(@">>> ORGMEngineStateStopped");
//            self.isPlaying = NO;
//            [self.timer invalidate];            
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
//            self.player = nil;
//            break;
//        }
//        case ORGMEngineStatePaused: {
//            NSLog(@">>> ORGMEngineStatePaused");           
//            self.isPlaying = NO;
//            [self.timer invalidate];
//            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
//            break;
//        }
//        case ORGMEngineStatePlaying: {
//            NSLog(@">>> ORGMEngineStatePlaying");
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
//            NSLog(@">>> ORGMEngineStateError");
//            self.player = nil;
//            break;
//    }
//}


@end
