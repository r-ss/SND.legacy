//
//  SNDPlayer.m
//  SND
//
//  Created by Alex Antipov on 4/20/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//
#import "SNDPlayer.h"
#import <OrigamiEngine/ORGMEngine.h>

#import "NSNumber+hhmmssFromSeconds.h"

// private part
@interface SNDPlayer() <ORGMEngineDelegate>
@property (strong) ORGMEngine *player;
@property (nonatomic) NSTimer *timer;
@end

@implementation SNDPlayer

@synthesize acceptableFileExtensions = _acceptableFileExtensions;
@synthesize isPlaying = _isPlaying;
@synthesize volume = _volume;
@synthesize position, duration;
@synthesize timer = _timer; // private
@synthesize player = _player; // private

/* OGRMEngine methods
[_player metadata];                         // current metadata
[_player pause];                            // pause playback
[_player resume];                           // resume playback
[_player stop];                             // stop playback
[_player seekToTime:seekSlider.value];      // seek to second
[_player setNextUrl:url withDataFlush:YES]; // play next track and clear current buffer
*/

- (void)awakeFromNib {
    _acceptableFileExtensions = [[NSArray alloc] initWithObjects:@"mp3", @"flac", nil];
    
    _volume = [NSNumber numberWithDouble:100];
    self.isPlaying = NO;

    // Restoring volume from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"Volume found: %@", [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]);
    [self setVolume:[NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDVolume"]]];
    [volumeSlider setIntegerValue:self.volume.doubleValue];
    
    self.player = [[ORGMEngine alloc] init];
    self.player.delegate = self;
    
    [_player setVolume:_volume.doubleValue];
    
}

// overriding synthesized setVolume method
- (void) setVolume:(NSNumber *)volume {
    _volume = volume;
    [self.player setVolume:_volume.doubleValue];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:_volume.doubleValue forKey:@"SNDVolume"];
    [userDefaults synchronize];
}


- (IBAction)volumeSlider:(NSSlider *)sender {
    [self setVolume:[NSNumber numberWithDouble:[sender doubleValue]]];
}

- (IBAction)positionSlider:(NSSlider *)sender {
    if(self.isPlaying){
        [self.player seekToTime:[sender doubleValue]];
    }
}

- (void) updatePositionViews {
    [durationOutlet setStringValue:[NSString stringWithString:[[NSNumber alloc] hhmmssFromSeconds:self.position]]];
    [positionSlider setDoubleValue:self.position.doubleValue];    
}

-(void) timerTick: (NSTimer *)timer {
    self.position = [NSNumber numberWithDouble:self.player.amountPlayed];
    [self updatePositionViews];
}

- (void) playTrack:(SNDTrack *)track {
    if(track){
        if(self.player.currentState == ORGMEngineStatePlaying){
            //NSLog(@"A");
            [self.player setNextUrl:track.url withDataFlush:YES];
        } else {
            //NSLog(@"B");
            [self.player playUrl:track.url];            
        }
    }
}

- (void) playPauseAction {
    if(self.player.currentState == ORGMEngineStatePlaying){
        [self.player pause];
    } else if (self.player.currentState == ORGMEngineStatePaused) {
        [self.player resume];
    }
}

#pragma mark - ORGMEngineDelegate
- (NSURL *) engineExpectsNextUrl:(ORGMEngine *)engine {
    SNDTrack *nextTrack = [self.sndBox nextTrack];
    NSLog(@"next track is: %@", nextTrack);
    return nextTrack.url;
}

- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state {
    switch (state) {
        case ORGMEngineStateStopped: {
            NSLog(@">>> ORGMEngineStateStopped");
            self.isPlaying = NO;
            [self.timer invalidate];            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
            break;
        }
        case ORGMEngineStatePaused: {
            NSLog(@">>> ORGMEngineStatePaused");           
            self.isPlaying = NO;
            [self.timer invalidate];
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
            break;
        }
        case ORGMEngineStatePlaying: {
            NSLog(@">>> ORGMEngineStatePlaying");
            [self.player setVolume:self.volume.doubleValue];
            //self.position = [NSNumber numberWithDouble:0];
            self.duration = [NSNumber numberWithDouble:self.player.trackTime];
            [positionSlider setMaxValue:self.duration.doubleValue];
            [self updatePositionViews];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];          
            self.isPlaying = YES;           
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStartedPlaying" object:self];
            break;
        }
        case ORGMEngineStateError:
            NSLog(@">>> ORGMEngineStateError");
            break;
    }
}


@end
