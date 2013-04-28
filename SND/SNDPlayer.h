//
//  SNDPlayer.h
//  SND
//
//  Created by Alex Antipov on 4/20/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDPlaylist.h"


@interface SNDPlayer : NSObject {
    IBOutlet NSTextField *durationOutlet;
    IBOutlet NSSlider *positionSlider;
    IBOutlet NSSlider *volumeSlider;
}

@property (nonatomic, assign) IBOutlet SNDPlaylist *sndPlaylist;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) NSNumber *volume;
@property (nonatomic) NSNumber *position;
@property (nonatomic) NSNumber *duration;


- (IBAction)volumeSlider:(NSSlider *)sender;
- (IBAction)positionSlider:(NSSlider *)sender;

- (void) playTrack:(SNDTrack *)track;
//- (void) playURL:(NSURL *)fileURL;
- (void) playPauseAction;

@end
