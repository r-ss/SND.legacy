//
//  SNDPlaylist.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SNDAppDelegate.h"
#import "SNDWindow.h"
#import "SNDPlaylistView.h"
#import "SNDTrack.h"



@class SNDPlayer;

@interface SNDPlaylist : NSObject <WindowDropDelegate, DockDropDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *playlistTableView;
}

@property (nonatomic, assign) IBOutlet SNDWindow *sndWindow;
@property (nonatomic, assign) IBOutlet SNDAppDelegate *sndAppDelegate;
@property (nonatomic, assign) IBOutlet SNDPlayer *sndPlayer;

@property (nonatomic) SNDTrack *currentTrack;
@property (nonatomic) NSNumber *currentTrackIndex;
@property (nonatomic) NSMutableArray *playlistData;

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;


- (IBAction)controlAction:(NSSegmentedControl *)sender;

// player will preload next track in queue for smooth track swithing
- (SNDTrack *) nextTrack;

// loading playlist from disk
- (void) loadPlaylist;

@end
