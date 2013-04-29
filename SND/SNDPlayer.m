//
//  SNDPlayer.m
//  SND
//
//  Created by Alex Antipov on 4/20/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//
#import "SNDPlayer.h"
#import <OrigamiEngine/ORGMEngine.h>

// private part
@interface SNDPlayer() <ORGMEngineDelegate>
@property (strong, nonatomic) ORGMEngine *player;
//@property (nonatomic) SNDTrack *nextTrack;
@property (nonatomic) NSTimer *timer;
@end

@implementation SNDPlayer

@synthesize isPlaying = _isPlaying;
@synthesize volume = _volume;
@synthesize position, duration;
@synthesize timer = _timer;
@synthesize player = _player; // private
//@synthesize nextTrack = _nextTrack; // private

/* OGRMEngine methods
[_player metadata];                         // current metadata
[_player pause];                            // pause playback
[_player resume];                           // resume playback
[_player stop];                             // stop playback
[_player seekToTime:seekSlider.value];      // seek to second
[_player setNextUrl:url withDataFlush:YES]; // play next track and clear current buffer
 */

- (void)awakeFromNib {
    //self.sndPlaylist.playerDelegate = self;
    self.volume = [NSNumber numberWithInteger:1];
    self.isPlaying = NO;
    
    // Restoring volume from user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.volume = [NSNumber numberWithFloat:[userDefaults floatForKey:@"defaultVolume"]];
    [volumeSlider setIntegerValue:self.volume.floatValue * 100];
    
    self.player = [[ORGMEngine alloc] init];
    self.player.delegate = self;
}


- (IBAction)volumeSlider:(NSSlider *)sender {
    self.volume = [NSNumber numberWithFloat:[sender floatValue] / 100];
    //if (self.audioPlayer){
    //    self.audioPlayer.volume = self.volume.floatValue;
    //}
    
    // Saving volume to user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:self.volume.floatValue forKey:@"defaultVolume"];
}

- (IBAction)positionSlider:(NSSlider *)sender {
    if(self.isPlaying){
        float percent = [sender doubleValue] / 100;
        double targetTime = self.duration.doubleValue * percent;
        //NSLog(@"percent: %f, duration, %f, targetTime: %f", percent, self.duration.doubleValue, targetTime);
        [self.player seekToTime:targetTime];
    }
}

- (NSString *)hhmmssFromSeconds:(NSInteger)s {
    NSInteger seconds = s % 60;
    NSInteger minutes = (s / 60) % 60;
    NSInteger hours = (s / 3600);
    if (hours > 0){
        return [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

-(void)updatePositionViews {
    [durationOutlet setStringValue:[NSString stringWithString:[self hhmmssFromSeconds:self.position.integerValue]]];
    NSNumber *percent = [NSNumber numberWithDouble:(self.position.doubleValue / self.duration.doubleValue) * 100];
    [positionSlider setIntegerValue:percent.integerValue];
}

-(void) timerTick: (NSTimer *)timer {
    self.position = [NSNumber numberWithDouble:self.player.amountPlayed];
    if(self.duration.intValue == 0)
        self.duration = [NSNumber numberWithDouble:self.player.trackTime];
    
    [self updatePositionViews];    
    
    //NSNumber *percent = [NSNumber numberWithDouble:(self.position.doubleValue / self.duration.doubleValue) * 100];
    //NSLog(@"> timer tick, position: %li, duration: %li, percent: %@", (long)self.position.integerValue, (long)self.duration.integerValue, percent);
}


- (void) playTrack:(SNDTrack *)track {
    //if(![track isEqual:self.preloadedTrack] && [track hash] != [self.preloadedTrack hash]){
    [self.player playUrl:track.url];
}

-(void) playPauseAction {
    if(self.player.currentState == ORGMEngineStatePlaying){
        [self.player pause];
    } else if (self.player.currentState == ORGMEngineStatePaused) {
        [self.player resume];
    }
}

#pragma mark - ORGMEngineDelegate
- (NSURL *)engineExpectsNextUrl:(ORGMEngine *)engine {
    SNDTrack *nextTrack = [self.sndPlaylist nextTrack];
    //NSLog(@"> self.nextTrack = %@", self.nextTrack);
    return nextTrack.url;
}

- (void)engine:(ORGMEngine *)engine didChangeState:(ORGMEngineState)state {
    switch (state) {
        case ORGMEngineStateStopped: {
            NSLog(@">>> ORGMEngineStateStopped");
            //_seekSlider.doubleValue = 0.0;
            //_lblPlayedTime.stringValue = @"Waiting...";
            //[_btnPlay setEnabled:YES];
            //[_btnPause setTitle:NSLocalizedString(@"Pause", nil)];
            
            self.isPlaying = NO;
            [self.timer invalidate];            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStoppedPlaying" object:self];
            break;
        }
        case ORGMEngineStatePaused: {
            NSLog(@">>> ORGMEngineStatePaused");
            //[_btnPause setTitle:NSLocalizedString(@"Resume", nil)];
            
            self.isPlaying = NO;
            [self.timer invalidate];
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerPausedPlaying" object:self];
            break;
        }
        case ORGMEngineStatePlaying: {
            NSLog(@">>> ORGMEngineStatePlaying");
            
            //NSString* metadata = @"";
            //NSDictionary* metadataDict = [_player metadata];
            //for (NSString* key in metadataDict.allKeys) {
            //    if (![key isEqualToString:@"picture"]) {
            //        metadata = [metadata stringByAppendingFormat:@"%@: %@\n", key,
            //                    [metadataDict objectForKey:key]];
            //    }
            //}
            //_tvMetadata.string = metadata;
            //NSData *data = [metadataDict objectForKey:@"picture"];
            //_ivCover.image = data ? [[NSImage alloc] initWithData:data] : nil;
            
            self.position = [NSNumber numberWithDouble:0];
            self.duration = [NSNumber numberWithDouble:0];
            [self updatePositionViews];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
            
            //self.preloadedTrack = nil;
            
            self.isPlaying = YES;           
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"SND.Notification.PlayerStartedPlaying" object:self];
            break;
        }
        case ORGMEngineStateError:
            NSLog(@">>> ORGMEngineStateError");
            //_tvMetadata.string = [_player.currentError localizedDescription];
            break;
    }
}


@end
