//
//  SNDBox.h
//  SND
//
//  Created by Alex Antipov on 4/30/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SNDAppDelegate.h"
#import "SNDWindow.h"

@class SNDPlayer;
@class SNDTrack;

@interface SNDBox : NSObject <WindowDropDelegate, DockDropDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *playlistTableView;
}

@property (nonatomic, assign) SNDAppDelegate *appDelegate;

@property (nonatomic, assign) IBOutlet SNDWindow *sndWindow;
@property (nonatomic, assign) IBOutlet SNDPlayer *sndPlayer;

@property (nonatomic) NSMutableArray *playlists;
@property (nonatomic) SNDPlaylist *currentSelectedPlaylist;
@property (nonatomic) SNDPlaylist *currentPlayingPlaylist;

@property (nonatomic) SNDTrack *currentTrack;

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;


- (IBAction) tabAction:(NSSegmentedControl *)sender;
- (IBAction) controlAction:(NSSegmentedControl *)sender;

// player will preload next track in queue for smooth track swithing
- (SNDTrack *) nextTrack;

// loading playlist from disk
- (void) load;


@end
