//
//  SNDPlaybackSegmentedControl.m
//  SND
//
//  Created by Alex Antipov on 4/23/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaybackSegmentedControl.h"

@implementation SNDPlaybackSegmentedControl

- (void)awakeFromNib {
    //NSLog(@"banderlog2");
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playerPlayerStartedPlayingNotification:) name:@"SND.Notification.PlayerStartedPlaying" object:nil];
    [nc addObserver:self selector:@selector(playerPlayerStoppedPlayingNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    [nc addObserver:self selector:@selector(playerPlayerStoppedPlayingNotification:) name:@"SND.Notification.PlayerPausedPlaying" object:nil];
}

- (void)playerPlayerStartedPlayingNotification:(NSNotification *)notification {
    NSImage *pic = [NSImage imageNamed:@"pic_pause"];
    [self setImage:pic forSegment:1];
}

- (void)playerPlayerStoppedPlayingNotification:(NSNotification *)notification {
    NSImage *pic = [NSImage imageNamed:@"pic_play"];
    [self setImage:pic forSegment:1];
}

@end
