//
//  SNDPlaylist.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDBox.h"

@class SNDTrack;

@interface SNDPlaylist : SNDBox

@property (nonatomic, strong, readwrite) NSMutableArray *tracks;
@property (nonatomic) NSNumber *currentTrackIndex;
@property (nonatomic) SNDTrack *currentTrack;


- (void) deactivate;
- (void) setCurrentTrackByIndex:(NSNumber *)index;
- (void) setCurrentTrackIndexByTrack:(SNDTrack *)currentTrack;

- (SNDTrack *) selectNextOrPreviousTrack:(BOOL)next;
- (SNDTrack *) selectItemAtRow:(NSInteger)rowIndex;

@end
