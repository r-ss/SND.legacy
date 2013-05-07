//
//  SNDTotalPlaybackTimeCounter.m
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDTotalPlaybackTimeCounter.h"
#import "NSNumber+hhmmssFromSeconds.h"

@implementation SNDTotalPlaybackTimeCounter

@synthesize totalTime = _totalTime;
@synthesize playbackTimer = _playbackTimer;

- (id)init
{
    //self = [super initWithWindowNibName:@"Preferences"];
    self = [super init];
    if (self) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(playerStartedPlayingNotification:) name:@"SND.Notification.PlayerStartedPlaying" object:nil];
        [nc addObserver:self selector:@selector(playerStoppedPlayingNotification:) name:@"SND.Notification.PlayerPausedPlaying" object:nil];
        [nc addObserver:self selector:@selector(playerStoppedPlayingNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.totalTime = [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDTotalPlaybackTime"]];
    }
    return self;
}

- (void) playerStartedPlayingNotification:(NSNotification *)notification {
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
}

- (void) playerStoppedPlayingNotification:(NSNotification *)notification {
    [self.playbackTimer invalidate];
}

- (void) timerTick: (NSTimer *)timer {
    NSLog(@"tick: %@", self.totalTime);
    NSNumber *tickTime = @1;
    
    self.totalTime = [NSNumber numberWithDouble:self.totalTime.doubleValue + tickTime.doubleValue];
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setDouble:[self.totalTime doubleValue] forKey:@"SNDTotalPlaybackTime"];
}

- (NSString *) getTotalPlaybackTime {
    return [self.totalTime hhmmssFromSeconds:self.totalTime];
}

@end
