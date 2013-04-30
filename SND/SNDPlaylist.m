//
//  SNDPlaylist.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaylist.h"
#import "SNDTrack.h"

@implementation SNDPlaylist

@synthesize tracks = _tracks;
@synthesize currentTrackIndex = _currentTrackIndex;

- (id)init {
    self = [super init];
    if (self) {
        self.tracks = [[NSMutableArray alloc] init];
        self.currentTrackIndex = [NSNumber numberWithInt:-1];
    }
    return self;
}

- (void) deactivate {
    self.currentTrackIndex = [NSNumber numberWithInt:-1];
}

- (void) setCurrentTrackByIndex:(NSNumber *)index {
    self.currentTrackIndex = index;
    self.currentTrack = [self.tracks objectAtIndex:index.integerValue];
}

- (void) setCurrentTrackIndexByTrack:(SNDTrack *)currentTrack {
    self.currentTrackIndex = [NSNumber numberWithInteger:[self.tracks indexOfObject:currentTrack]];
}

- (SNDTrack *) selectNextOrPreviousTrack:(BOOL)next {
    NSLog(@"> selectNextOrPreviousTrack");
    if(self.currentTrackIndex.integerValue == -1){
        self.currentTrackIndex = [NSNumber numberWithInt:0];
        [self setCurrentTrackByIndex:self.currentTrackIndex];
        [self selectItemAtRow:self.currentTrackIndex.intValue];
        return nil;
    }
    NSInteger current = self.currentTrackIndex.intValue;
    NSInteger total = [self.tracks count] - 1;
    if(total > 1){
        if(next){
            if(current < total){
                current++;
            }
        } else {
            if(current >= 1){
                current--;
            }
        }
        if(current != self.currentTrackIndex.intValue)
            return [self selectItemAtRow:current];
    }
    return nil;
}

- (SNDTrack *) selectItemAtRow:(NSInteger)rowIndex{
    self.currentTrackIndex = [NSNumber numberWithInt:rowIndex];
    [self setCurrentTrackByIndex:self.currentTrackIndex];
    //SNDTrack *track = [seld.tracks objectAtIndex:]
    return self.currentTrack;
}


@end