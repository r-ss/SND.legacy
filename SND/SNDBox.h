//
//  SNDBox.h
//  SND
//
//  Created by Alex Antipov on 4/30/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDAppDelegate.h"
#import "SNDWindow.h"

@class SNDPlayer;
@class SNDTrack;

@class SNDPlaylistRenameController;

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

@property (nonatomic, strong) SNDPlaylistRenameController *playlistRenameController;


- (IBAction) tabAction:(NSSegmentedControl *)sender;
@property (nonatomic, assign) IBOutlet NSSegmentedControl *tabs;

- (IBAction) controlAction:(NSSegmentedControl *)sender;

- (IBAction) addPlaylist:(NSButton *)sender;

// player will preload next track in queue for smooth track swithing
- (SNDTrack *) nextTrack;

// loading playlist from disk
- (void) load;

- (void) renamePlaylist:(NSInteger)index withName:(NSString *)name;

- (IBAction) playlistSelectAll:(id)sender;
- (IBAction) playlistAdd:(id)sender;
- (IBAction) playlistDelete:(id)sender;
- (IBAction) playlistRename:(id)sender;

- (IBAction) playlistMenuShowInFinderSelected:(id)sender;
- (IBAction) playlistMenuDeleteSelected:(id)sender;

@end
