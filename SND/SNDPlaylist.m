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

@synthesize index = _index;
@synthesize title = _title;

@synthesize tracks = _tracks;
@synthesize currentTrackIndex = _currentTrackIndex;

- (id) init {
    self = [super init];
    if (self) {
        self.tracks = [[NSMutableArray alloc] init];
        self.currentTrackIndex = [NSNumber numberWithInt:-1];
    }
    return self;
}

- (id) initWithIndex:(NSNumber *)i {
    self = [super init];
    if (self) {
        self.tracks = [[NSMutableArray alloc] init];
        self.currentTrackIndex = [NSNumber numberWithInt:-1];
        self.index = i;
    }
    return self;
}

// Overriding title getter
- (NSString *) title {
    if ([self.tracks count] > 0){
        SNDTrack *firstTrack = [self.tracks objectAtIndex:0];
        NSString *firstTrackArtist = firstTrack.artist;
        if([self.tracks count] > 1){
            NSInteger i;
            for (i = 1; i < [self.tracks count]; i++){
                SNDTrack *track = [self.tracks objectAtIndex:i];
                if(![track.artist isEqualToString:firstTrackArtist]){
                    return [NSString stringWithFormat:@"%li", (long)self.index.integerValue];
                }
            }
            return firstTrackArtist;
        } else {
            return firstTrackArtist;
        }
    }
    return [NSString stringWithFormat:@"%li", (long)self.index.integerValue];
}

- (void) setCurrentTrackByIndex:(NSNumber *)index {
    self.currentTrackIndex = index;
    self.currentTrack = [self.tracks objectAtIndex:index.integerValue];
}

- (void) setCurrentTrackIndexByTrack:(SNDTrack *)currentTrack {
    self.currentTrackIndex = [NSNumber numberWithInteger:[self.tracks indexOfObject:currentTrack]];
}

- (SNDTrack *) selectNextOrPreviousTrack:(BOOL)next {
    if([self.tracks count] == 0)
        return nil;    
    if(self.currentTrackIndex.integerValue == -1){
        self.currentTrackIndex = [NSNumber numberWithInt:0];
        [self setCurrentTrackByIndex:self.currentTrackIndex];
        return [self selectItemAtRow:self.currentTrackIndex.intValue];
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
    return self.currentTrack;
}


@end