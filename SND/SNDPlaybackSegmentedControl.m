//
//  SNDPlaybackSegmentedControl.m
//  SND
//
//  Created by Alex Antipov on 4/23/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaybackSegmentedControl.h"

@interface SNDPlaybackSegmentedControl()
@property (nonatomic) NSImage *pic;
@property (nonatomic) NSTimer *timer; // need little delay for prevent playback icon blinking on tracks switching
@end

@implementation SNDPlaybackSegmentedControl

@synthesize pic = _pic;
@synthesize timer = _timer;

- (void)awakeFromNib {
    //NSLog(@"banderlog2");
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playerPlayerStartedPlayingNotification:) name:@"SND.Notification.PlayerStartedPlaying" object:nil];
    [nc addObserver:self selector:@selector(playerPlayerStoppedPlayingNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    [nc addObserver:self selector:@selector(playerPlayerStoppedPlayingNotification:) name:@"SND.Notification.PlayerPausedPlaying" object:nil];
}

- (void)playerPlayerStartedPlayingNotification:(NSNotification *)notification {
    self.pic = [NSImage imageNamed:@"pic_pause"];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(changePic:) userInfo:nil repeats:NO];
}

- (void)playerPlayerStoppedPlayingNotification:(NSNotification *)notification {
    self.pic = [NSImage imageNamed:@"pic_play"];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(changePic:) userInfo:nil repeats:NO];
}

- (void) changePic:(NSTimer *)timer {
    [self setImage:self.pic forSegment:1];
}



@end
