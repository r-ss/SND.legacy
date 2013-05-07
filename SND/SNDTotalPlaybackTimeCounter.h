//
//  SNDTotalPlaybackTimeCounter.h
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDTotalPlaybackTimeCounter : NSObject

@property (nonatomic, strong) NSNumber *totalTime;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) NSTimer *saveTimer;

- (NSString *) getTotalPlaybackTime;

@end
