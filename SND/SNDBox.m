//
//  SNDBox.m
//  SND
//
//  Created by Alex Antipov on 4/30/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDBox.h"
#import "SNDPlaylist.h"

#import "SNDPlayer.h"
#import "SNDTrack.h"
#import "SNDPlaylistView.h"

#import "SNDPlaylistRenameController.h"

@implementation SNDBox

@synthesize playlists = _playlists;
@synthesize currentTrack = _currentTrack;
@synthesize currentSelectedPlaylist = _currentSelectedPlaylist;
@synthesize currentPlayingPlaylist = _currentPlayingPlaylist;
@synthesize tabs = _tabs;
@synthesize playlistRenameController = _playlistRenameController;

NSString *const PBType = @"playlistRowDragDropType";

- (void)awakeFromNib {
    [super awakeFromNib];    
    self.appDelegate = NSApplication.sharedApplication.delegate;
    self.appDelegate.dockDropDelegate = self;    
    self.sndWindow.windowDropDelegate = self;
    
    self.playlists = [[NSMutableArray alloc] init];   
    self.playlistRenameController = [[SNDPlaylistRenameController alloc] init];
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playlistDeleteTrackNotification:) name:@"SND.Notification.PlaylistDeleteTrackKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playerStoppedPlayingNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    [nc addObserver:self selector:@selector(playpauseKeyPressedNotification:) name:@"SND.Notification.PlaylistPlayKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playlistPreviousKeyPressedNotification:) name:@"SND.Notification.PlaylistPreviousKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playlistNextKeyPressedNotification:) name:@"SND.Notification.PlaylistNextKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playlistNewKeyPressedNotification:) name:@"SND.Notification.PlaylistNewPressed" object:nil];
    [nc addObserver:self selector:@selector(playlistDeletePlaylistKeyPressedNotification:) name:@"SND.Notification.PlaylistDeletePlaylistPressed" object:nil];
    
    [playlistTableView setTarget:self];
    [playlistTableView setDoubleAction:@selector(doubleClick:)];
    [playlistTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBType, NSFilenamesPboardType, @"public.utf8-plain-text", nil]];
	[playlistTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"ololo" action:nil keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [menuItem setRepresentedObject:[NSNumber numberWithInteger:0]]; // pass playlist index
    [menuItem setAction:@selector(playlistDeleteMenuItemPressed:)];
	[self.playlistContextMenu insertItem:menuItem atIndex:1];
}


- (NSIndexSet *) _indexesToProcessForContextMenu {
    NSIndexSet *selectedIndexes = [playlistTableView selectedRowIndexes];
    // If the clicked row was in the selectedIndexes, then we process all selectedIndexes. Otherwise, we process just the clickedRow
    if ([playlistTableView clickedRow] != -1 && ![selectedIndexes containsIndex:[playlistTableView clickedRow]]) {
        selectedIndexes = [NSIndexSet indexSetWithIndex:[playlistTableView clickedRow]];
    }
    return selectedIndexes;
}

- (IBAction) playlistMenuShowInFinderSelected:(id)sender {
    NSIndexSet *selectedIndexes = [self _indexesToProcessForContextMenu];
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger row, BOOL *stop) {
        SNDTrack *track = [self.currentSelectedPlaylist.tracks objectAtIndex:row];
        [[NSWorkspace sharedWorkspace] selectFile:track.path inFileViewerRootedAtPath:nil];
    }];
}

- (IBAction) playlistMenuDeleteSelected:(id)sender {
    NSIndexSet *selectedIndexes = [self _indexesToProcessForContextMenu];
    NSInteger index = [self.playlists indexOfObject:self.currentSelectedPlaylist];
    SNDPlaylist *playlist = [self.playlists objectAtIndex:index];
    [playlist.tracks removeObjectsAtIndexes:selectedIndexes];   
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
    [self save];
}


- (IBAction) playlistSelectAll:(id)sender {
    NSLog(@"select all");
    [playlistTableView selectAll:sender];
}


- (IBAction) playlistAdd:(id)sender {
    [self addPlaylist:nil];
}

- (IBAction) playlistDelete:(id)sender {
    NSInteger index = [self.playlists indexOfObject:self.currentSelectedPlaylist];
    [self deletePlaylist:index];
}

- (IBAction) playlistRename:(id)sender {
    NSInteger index = [self.playlists indexOfObject:self.currentSelectedPlaylist];
    SNDPlaylist *playlist = [self.playlists objectAtIndex:index];
    [self.playlistRenameController showWithInitialName:playlist.title forTab:index];
}

- (void) setupDefaultEmptyPlaylists {
    NSInteger i;
    for(i = 0; i < 5; i++){
        NSNumber *index = [NSNumber numberWithInteger:i];
        SNDPlaylist *playlist = [[SNDPlaylist alloc] initWithIndex:index];
        [self.playlists addObject:playlist];
        [self.tabs setSegmentCount:[self.playlists count]];
        //[self setupMenuForTab:i];
    }    
    self.currentSelectedPlaylist = [self.playlists objectAtIndex:0];
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
}

- (void) renamePlaylist:(NSInteger)index withName:(NSString *)name {
    NSLog(@"rename to: %@", name);
    SNDPlaylist *playlist = [self.playlists objectAtIndex:index];
    playlist.manualEnteredName = name;
    [self updateAllTabsTitles];
    [self save];
}

- (void) setupMenuForTab:(NSInteger)tab {
    //NSLog(@"> setup menu for tab");
    
    NSMenu *newMenu = [[NSMenu alloc] init];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Rename" action:nil keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [menuItem setRepresentedObject:[NSNumber numberWithInteger:tab]]; // pass playlist index
    [menuItem setAction:@selector(playlistRenameMenuItemPressed:)];
	[newMenu insertItem:menuItem atIndex:0];
    
	menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete playlist" action:nil keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [menuItem setRepresentedObject:[NSNumber numberWithInteger:tab]]; // pass playlist index
    [menuItem setAction:@selector(playlistDeleteMenuItemPressed:)];
	[newMenu insertItem:menuItem atIndex:1];
    
    SNDPlaylist *playlistForTab = [self.playlists objectAtIndex:tab];
    NSString *totalTimeRowText = [NSString stringWithFormat:@"playing time: %@", playlistForTab.totalPlaylistPlayingTime];
    menuItem = [[NSMenuItem alloc] initWithTitle:totalTimeRowText action:nil keyEquivalent:@""];
    [menuItem setEnabled:NO];
	[newMenu insertItem:menuItem atIndex:2];
    
    [self.tabs setMenu:newMenu forSegment:tab];
}

- (IBAction) addPlaylist:(NSButton *)sender {
    NSLog(@"> addPlaylist");
    NSNumber *newPlaylistIndex = [NSNumber numberWithInteger:[self.playlists count]];
    SNDPlaylist *playlist = [[SNDPlaylist alloc] initWithIndex:newPlaylistIndex];
    [self.playlists addObject:playlist];    
    
    [self.tabs setSegmentCount:[self.playlists count]];
    [self updateTabTitle:newPlaylistIndex.integerValue];    
    [self setupMenuForTab:newPlaylistIndex.integerValue];
    [self save];
}

- (void) playlistRenameMenuItemPressed:(id)sender {
    NSLog(@"> playlistRenameMenuItemPressed %@", [sender representedObject]);
    NSNumber *tab = [sender representedObject];
    NSLog(@"> tab id %ld", (long)tab.integerValue);
    SNDPlaylist *playlist = [self.playlists objectAtIndex:tab.integerValue];
    [self.playlistRenameController showWithInitialName:playlist.title forTab:tab.integerValue];
}

- (void) playlistDeleteMenuItemPressed:(id)sender {
    NSLog(@"> playlistDeleteMenuItemPressed %@", [sender representedObject]);
    NSNumber *index = [sender representedObject];
    [self deletePlaylist:index.integerValue];
}

- (void) deletePlaylist:(NSInteger)index {
    if([self.playlists count] > 1){
        NSInteger currentSelectedPlaylistIndex = [self.playlists indexOfObject:self.currentSelectedPlaylist];

        [self.playlists removeObjectAtIndex:index];
        [self.tabs setSegmentCount:[self.playlists count]];
        [self updateAllTabsTitles];
        
        if(currentSelectedPlaylistIndex == index){
            if(currentSelectedPlaylistIndex == [self.playlists count]){
                self.currentSelectedPlaylist = [self.playlists objectAtIndex:currentSelectedPlaylistIndex - 1];
                [self.tabs setSelectedSegment:currentSelectedPlaylistIndex - 1];
            } else {
                self.currentSelectedPlaylist = [self.playlists objectAtIndex:currentSelectedPlaylistIndex];
                [self.tabs setSelectedSegment:currentSelectedPlaylistIndex];
            }
            [playlistTableView reloadData];
        }        
        [self save];
    } else {
        [self showCommonInformationalAlert:@"Please don't delete last playlist" informativeText:@"because program will crash :)"];
    }
}

- (void) updateAllTabsTitles {
    NSInteger i;
    for (i = 0; i < [self.playlists count]; i++){
        [self updateTabTitle:i];
        [self setupMenuForTab:i];
    }
}

- (void) updateTabTitle:(NSInteger)tabIndex {
    SNDPlaylist *playlist = [self.playlists objectAtIndex:tabIndex];
    [self.tabs setLabel:playlist.title forSegment:tabIndex];
}

- (IBAction) tabAction:(NSSegmentedControl *)sender {
    //NSLog(@"tab click: %ld", sender.selectedSegment);
    if([self.playlists indexOfObject:self.currentSelectedPlaylist] != sender.selectedSegment){
        //[self.currentPlaylist deactivate];
        self.currentSelectedPlaylist = [self.playlists objectAtIndex:sender.selectedSegment];
        [playlistTableView reloadData];
        //[self updateAllTabsTitles];
        [playlistTableView deselectAll:self];
        
        SNDPlaylist *playlist = [self.playlists objectAtIndex:sender.selectedSegment];
        [self.tabs setLabel:playlist.title forSegment:sender.selectedSegment];
    }
    //NSLog(@"%@", self.currentPlaylist.tracks);
}

- (void) save {
    NSLog(@"> save");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // loading playlists
    NSEntityDescription *playlistEntity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:playlistEntity];    
    NSArray *playlists = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // loading tracks
    NSEntityDescription *trackEntity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:trackEntity];    
    NSArray *tracks = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSManagedObject *playlistMO = nil;
    NSManagedObject *trackMO = nil;
    
    // delete all data before saving new
    if([playlists count] > 0){
        NSInteger i;
        for (i = 0; i < [playlists count]; i++) {
            playlistMO = [playlists objectAtIndex:i];
            [self.appDelegate.managedObjectContext deleteObject:playlistMO];
        }
    }
    if([tracks count] > 0){
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            [self.appDelegate.managedObjectContext deleteObject:trackMO];
        }
    }
    
    // saving playlists
    for (SNDPlaylist *playlist in self.playlists) {
        playlistMO = [NSEntityDescription insertNewObjectForEntityForName:@"Playlist" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [playlistMO setValue:[NSNumber numberWithInteger:playlist.index.integerValue] forKey:@"index"];
        [playlistMO setValue:playlist.manualEnteredName forKey:@"manualName"];
    }
    
    // saving tracks    
    for (SNDPlaylist *playlist in self.playlists) {
        NSInteger k;
        for (k = 0; k < [playlist.tracks count]; k++) {
            SNDTrack *t = [playlist.tracks objectAtIndex:k];
            trackMO = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
            [trackMO setValue:[NSNumber numberWithInteger:k] forKey:@"row"];
            [trackMO setValue:[NSNumber numberWithInteger:playlist.index.integerValue] forKey:@"memberOfPlaylist"];
            [trackMO setValue:t.path forKey:@"path"];            
            [trackMO setValue:t.artist forKey:@"tag_artist"];
            [trackMO setValue:t.album forKey:@"tag_album"];
            [trackMO setValue:t.title forKey:@"tag_title"];
            [trackMO setValue:t.tracknumber forKey:@"tag_tracknumber"];
            [trackMO setValue:t.year forKey:@"tag_year"];
            [trackMO setValue:t.duration forKey:@"tag_duration"];            
        }
    }
      
    NSError *err = nil;
    if(![self.appDelegate.managedObjectContext save:&err]){
        NSLog(@"error %@, %@", err, [err userInfo]);
        abort();
    }
}

- (void) load {
    //NSDate *start = [NSDate date];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // loading playlists
    NSEntityDescription *playlistEntity = [NSEntityDescription entityForName:@"Playlist" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:playlistEntity];
    NSArray *playlists = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    // loading tracks
    NSEntityDescription *trackEntity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:trackEntity];
    NSArray *tracks = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    NSManagedObject *playlistMO = nil;
    NSManagedObject *trackMO = nil; 
    
    // filling playlists
    if([playlists count] > 0){
        
        // remove default empty playlists
        [self.playlists removeAllObjects];        
        
        NSMutableArray *unsortedPlaylists = [[NSMutableArray alloc] init];
        NSInteger i;
        for (i = 0; i < [playlists count]; i++) {
            playlistMO = [playlists objectAtIndex:i];
            SNDPlaylist *playlist = [[SNDPlaylist alloc] initWithIndex:[NSNumber numberWithInteger:[[playlistMO valueForKey:@"index"] integerValue]]];
            playlist.manualEnteredName = [playlistMO valueForKey:@"manualName"];
            [unsortedPlaylists addObject:playlist];
        }
        
        NSArray *sortedPlaylists = [unsortedPlaylists sortedArrayUsingComparator:^(SNDPlaylist *a, SNDPlaylist *b) {
            if (a.index.integerValue > b.index.integerValue)
                return (NSComparisonResult)NSOrderedDescending;
            if (a.index.integerValue < b.index.integerValue)
                return (NSComparisonResult)NSOrderedAscending;
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        for (i = 0; i < [sortedPlaylists count]; i++) {
            [self.playlists addObject:[sortedPlaylists objectAtIndex:i]];
            [self.tabs setSegmentCount:[self.playlists count]];
            //[self setupMenuForTab:i];
        }
        
        self.currentSelectedPlaylist = [self.playlists objectAtIndex:0];
        //[playlistTableView reloadData];
        //[self updateAllTabsTitles];
    } else {
        // if saved playlists not found setup default playlists
        [self setupDefaultEmptyPlaylists];
    }

    // filling tracks
    if([tracks count] > 0){
        NSMutableArray *rawTracks = [[NSMutableArray alloc] init];       
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            //[dict setObject:[[NSURL alloc] initFileURLWithPath:[trackMO valueForKey:@"path"]] forKey:@"tag_duration"];
            [dict setObject:[[NSURL alloc] initFileURLWithPath:[trackMO valueForKey:@"path"]] forKey:@"path"];
            [dict setObject:[NSNumber numberWithInteger:[[trackMO valueForKey:@"tag_duration"] intValue]] forKey:@"tag_duration"];
            [dict setObject:[NSNumber numberWithInteger:[[trackMO valueForKey:@"tag_year"] intValue]] forKey:@"tag_year"];
            [dict setObject:[NSNumber numberWithInteger:[[trackMO valueForKey:@"tag_tracknumber"] intValue]] forKey:@"tag_tracknumber"];            
            [dict setObject:[NSString stringWithString:[trackMO valueForKey:@"tag_artist"]] forKey:@"tag_artist"];
            [dict setObject:[NSString stringWithString:[trackMO valueForKey:@"tag_album"]] forKey:@"tag_album"];
            [dict setObject:[NSString stringWithString:[trackMO valueForKey:@"tag_title"]] forKey:@"tag_title"];          
            NSDictionary *finalDict = [dict copy];
            dict = nil;
            SNDTrack *t = [[SNDTrack alloc] initWithSavedData:finalDict];        
            
            
            //SNDTrack *t = [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:[trackMO valueForKey:@"path"]]];
            int rowIndex = [[trackMO valueForKey:@"row"] intValue];
            int memberOfPlaylist = [[trackMO valueForKey:@"memberOfPlaylist"] intValue];
            [rawTracks addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:memberOfPlaylist],[NSNumber numberWithInt:rowIndex],t, nil ]];
        }
        
        //NSLog(@"found %ld raw tracks", [rawTracks count]);

        for (i = 0; i < [self.playlists count]; i++) {
            NSMutableArray *unsortedRows = [[NSMutableArray alloc] init];
            NSInteger k;
            for (k = 0; k < [rawTracks count]; k++) {
                NSArray *rawTrack = [rawTracks objectAtIndex:k];
                NSNumber *memberOf = [rawTrack objectAtIndex:0];
                if(memberOf.intValue == i){
                    [unsortedRows addObject:[rawTracks objectAtIndex:k]];
                }
            }
            NSArray *sortedRows = [unsortedRows sortedArrayUsingComparator:^(id a, id b)
            {
                NSNumber *n1 = [a objectAtIndex:1];
                NSNumber *n2 = [b objectAtIndex:1];
                if (n1.integerValue > n2.integerValue)
                    return (NSComparisonResult)NSOrderedDescending;
                if (n1.integerValue < n2.integerValue)
                    return (NSComparisonResult)NSOrderedAscending;
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            NSInteger z;
            for (z = 0; z < [sortedRows count]; z++) {
                SNDPlaylist *playlist = [self.playlists objectAtIndex:i];
                [playlist.tracks addObject:[[sortedRows objectAtIndex:z] objectAtIndex:2]];
            }
        }
     }
        
    
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
    
    
    //NSDate *methodFinish = [NSDate date];
    //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];    
    //NSLog(@"Execution Time: %f", executionTime);
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == playlistTableView) {
        return [self.currentSelectedPlaylist.tracks count];
	}
	return 0;
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == playlistTableView) {
        SNDTrack *t = [self.currentSelectedPlaylist.tracks objectAtIndex:row];
        
        if([tableColumn.identifier isEqualToString:@"state"]){
            if(!t.isAccessible){
                return @"?";
            }            
            if (row == self.currentSelectedPlaylist.currentTrackIndex.intValue && [self.currentSelectedPlaylist isEqualTo:self.currentPlayingPlaylist]){
                return @">";
            } else {
                return @"";
            }
        }        
        NSString *identifier = tableColumn.identifier;
        return [t valueForKey:identifier];
	}
	return NULL;
}

- (void) tableView:(NSTableView *)pTableView setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRowIndex {
    if (pTableView == playlistTableView) {
		SNDTrack * zData = [self.currentSelectedPlaylist.tracks objectAtIndex:pRowIndex];
		zData.path	= (NSString *)pObject;
        [self.currentSelectedPlaylist.tracks replaceObjectAtIndex:pRowIndex withObject:zData];
	}
}

- (BOOL) tableView:(NSTableView *)pTableView writeRowsWithIndexes:(NSIndexSet *)pIndexSetOfRows toPasteboard:(NSPasteboard*)pboard {
    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:pIndexSetOfRows];
    [pboard declareTypes:[NSArray arrayWithObject:PBType] owner:self];
    [pboard setData:zNSIndexSetData forType:PBType];
	if ([pIndexSetOfRows count] > 1) {
		return YES;
	}
	NSInteger zIndex	= [pIndexSetOfRows firstIndex];
	SNDTrack * zDataObj	= [self.currentSelectedPlaylist.tracks objectAtIndex:zIndex];
	NSString *zDataString = zDataObj.path;
	[pboard setString:zDataString forType:@"public.utf8-plain-text"];
    return YES;
}

- (NSDragOperation) tableView:(NSTableView*)pTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    return NSDragOperationEvery;
}

- (BOOL) tableView:(NSTableView *)pTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)pRow dropOperation:(NSTableViewDropOperation)operation {
	
    NSPasteboard* zPBoard = [info draggingPasteboard];
	NSArray *supportedTypes = [NSArray arrayWithObjects: PBType, NSFilenamesPboardType, @"public.utf8-plain-text", NSPasteboardTypeString, nil];
	NSString * zStrAvailableType = [zPBoard availableTypeFromArray:supportedTypes];
	//NSLog(@"> acceptDrop zStrAvailableType=%@",zStrAvailableType);
	
	if ([zStrAvailableType compare:PBType] == NSOrderedSame ) {
        
		NSData* zRowNSData = [zPBoard dataForType:PBType];
		NSIndexSet* zNSIndexSetRows = [NSKeyedUnarchiver unarchiveObjectWithData:zRowNSData];
        
		NSMutableArray *zArySelectedElements = [[NSMutableArray alloc]init];
		NSInteger i;
        ////// SELECTION
		for (i=[zNSIndexSetRows firstIndex]; i <= [zNSIndexSetRows lastIndex];i++) {
			if ( ! [zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zArySelectedElements addObject:[self.currentSelectedPlaylist.tracks objectAtIndex:i]];
		}
		NSMutableArray *zNewAry = [[NSMutableArray alloc]init];
        ////// TOP
		for (i = 0; i < pRow; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.currentSelectedPlaylist.tracks objectAtIndex:i]];
		}
		[zNewAry addObjectsFromArray:zArySelectedElements];
        ////// BOTTOM
		for (i = pRow; i < [self.currentSelectedPlaylist.tracks count]; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.currentSelectedPlaylist.tracks objectAtIndex:i]];
		}
        
		self.currentSelectedPlaylist.tracks = zNewAry;
        [self.currentSelectedPlaylist setCurrentTrackIndexByTrack:self.currentSelectedPlaylist.currentTrack];
        [playlistTableView noteNumberOfRowsChanged];
        [playlistTableView deselectAll:self];
		[playlistTableView reloadData];
        [self updateAllTabsTitles];
		return YES;
	}
	
	if ([zStrAvailableType compare:@"public.utf8-plain-text"] == NSOrderedSame ) {
		NSLog(@"public.utf8-plain-text");
		NSData* zStringData = [zPBoard dataForType:@"public.utf8-plain-text"];
		NSString * aStr = [[NSString alloc] initWithData:zStringData encoding:NSASCIIStringEncoding];
		SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:aStr]];
		[self.currentSelectedPlaylist.tracks insertObject:zDataObj atIndex:pRow];
		[playlistTableView noteNumberOfRowsChanged];
        [playlistTableView deselectAll:self];
        [self.currentSelectedPlaylist setCurrentTrackIndexByTrack:self.currentSelectedPlaylist.currentTrack];
		[playlistTableView reloadData];
        [self updateAllTabsTitles];
		return YES;
	}
	
	if ([zStrAvailableType compare:NSFilenamesPboardType] == NSOrderedSame ) {
		NSLog(@"NSFilenamesPboardType");
		
		NSArray* zPListFilesAry = [zPBoard propertyListForType:NSFilenamesPboardType];
        [self addFiles:zPListFilesAry atRow:pRow];
		return YES;
	}
	return NO;
}

- (BOOL) tableView:(NSTableView *)tv writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {
	// declare our own pasteboard types
	NSArray *typesArray = [NSArray arrayWithObjects:PBType, nil];
	[pboard declareTypes:typesArray owner:self];
	// add rows array for local move
	[pboard setPropertyList:rows forType:PBType];
	return YES;
}

- (NSIndexSet *) indexSetFromRows:(NSArray *)rows {
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSUInteger NSUI = 2;
    [indexSet addIndex:NSUI];
	return indexSet;
}

- (int) rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet {
	NSUInteger currentIndex = [indexSet firstIndex];
	int i = 0;
	while (currentIndex != NSNotFound) {
		if (currentIndex < row)
			i++;
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
	}
	return i;
}

- (void) playlistDeleteTrackNotification:(NSNotification *)notification{
    [playlistTableView abortEditing];    
    NSIndexSet *selectedRowIndexes = [playlistTableView selectedRowIndexes];    
    [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        if(index == self.currentSelectedPlaylist.currentTrackIndex.integerValue){
            self.currentSelectedPlaylist.currentTrackIndex = [NSNumber numberWithInteger: -1];
            self.currentSelectedPlaylist.currentTrack = nil;
        }
    }];
    [self.currentSelectedPlaylist.tracks removeObjectsAtIndexes:selectedRowIndexes];
    [playlistTableView deselectAll:self];
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
    [self save];
}

- (void) playlistNewKeyPressedNotification:(NSNotification *)notification {
    [self addPlaylist:nil];
}

- (void) playlistDeletePlaylistKeyPressedNotification:(NSNotification *)notification {
    NSInteger index = [self.playlists indexOfObject:self.currentSelectedPlaylist];
    [self deletePlaylist:index];
}

- (void) playerStoppedPlayingNotification:(NSNotification *)notification{
    self.currentPlayingPlaylist.currentTrack = nil;
    self.currentPlayingPlaylist.currentTrackIndex = [NSNumber numberWithInt:-1];
    self.currentPlayingPlaylist = nil;
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
}

- (void) playpauseKeyPressedNotification:(NSNotification *)notification {
    [self playPause];
}

- (void) playlistPreviousKeyPressedNotification:(NSNotification *)notification {
    [self previous];
}

- (void) playlistNextKeyPressedNotification:(NSNotification *)notification {
    [self next];
}

// WindowDropDelegate methods
- (void) filesDroppedIntoWindow:(NSArray *)filesURL {
    [self addFiles:filesURL atRow:-1];
}

// DockDropDelegate metods
- (void) filesDroppedIntoDock:(NSArray *)filesURL {
    [self addFiles:filesURL atRow:-1];
}

- (NSArray *) sortSNDTracksByTrackNumber:(NSArray *)tracks {
    NSArray *sortedTracks = [tracks sortedArrayUsingComparator:^(SNDTrack *a, SNDTrack *b){
        NSNumber *n1 = a.tracknumber;
        NSNumber *n2 = b.tracknumber;
        if (n1.integerValue > n2.integerValue)
            return (NSComparisonResult)NSOrderedDescending;
        if (n1.integerValue < n2.integerValue)
            return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sortedTracks;
}

- (void) addFiles:(NSArray *)filesURL atRow:(NSInteger)row {
    NSInteger i;

    for (i = 0; i < [filesURL count]; i++) {
        NSString * zStrFilePath	= [filesURL objectAtIndex:i];
        NSString * aStrPath = [zStrFilePath stringByStandardizingPath];
        
        BOOL isDir;
        if([[NSFileManager defaultManager] fileExistsAtPath: aStrPath isDirectory:&isDir] && isDir){
            //NSLog(@"is a directory");
            /*
            search for subdirs
            sort subdirs alphabetical
            search tracks in sorted subdirs and add to playlist
            add tracks at 1st directory level to end of playlist
            */
            NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:aStrPath];
            
            NSMutableArray *unsortedSubdirectories = [[NSMutableArray alloc] init];
            NSMutableArray *unsortedTracks = [[NSMutableArray alloc] init];
            
            for (NSString *filepath in dirEnum) {
                NSString *path = [NSString stringWithFormat:@"%@/%@", aStrPath, filepath];
                BOOL isSubDir;
                if([[NSFileManager defaultManager] fileExistsAtPath: path isDirectory:&isSubDir] && isSubDir){
                    [unsortedSubdirectories addObject:path];
                } else {
                    if ([self.sndPlayer.acceptableFileExtensions containsObject:filepath.pathExtension] && [dirEnum level] == 1) {
                        SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:path]];
                        [unsortedTracks addObject:zDataObj];
                    }
                }
            }
            
            NSArray *sortedSubdirectories = [unsortedSubdirectories sortedArrayUsingSelector:@selector(compare:)];
            
            //NSInteger ia;
            for (NSString *subdirpath in sortedSubdirectories) {
                NSDirectoryEnumerator *subdirEnum = [[NSFileManager defaultManager] enumeratorAtPath:subdirpath];
                NSMutableArray *unsortedTracksInSubdir = [[NSMutableArray alloc] init];                
                for (NSString *sfilepath in subdirEnum) {
                    NSString *path = [NSString stringWithFormat:@"%@/%@", subdirpath, sfilepath];
                    if ([self.sndPlayer.acceptableFileExtensions containsObject:sfilepath.pathExtension]) {
                        SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:path]];
                        [unsortedTracksInSubdir addObject:zDataObj];
                    }                    
                }
                NSArray *sortedTracksInSubdir = [self sortSNDTracksByTrackNumber:unsortedTracksInSubdir];
                NSInteger k;
                for (k = 0; k < [sortedTracksInSubdir count]; k++) {
                    (row != -1) ? [self.currentSelectedPlaylist.tracks insertObject:[sortedTracksInSubdir objectAtIndex:k] atIndex:row++] : [self.currentSelectedPlaylist.tracks addObject:[sortedTracksInSubdir objectAtIndex:k]];
                }
            }
            
            NSArray *sortedTracks = [self sortSNDTracksByTrackNumber:unsortedTracks];
            NSInteger ib;
            for (ib = 0; ib < [sortedTracks count]; ib++) {
                (row != -1) ? [self.currentSelectedPlaylist.tracks insertObject:[sortedTracks objectAtIndex:ib] atIndex:row++] : [self.currentSelectedPlaylist.tracks addObject:[sortedTracks objectAtIndex:ib]];
            }            
        } else {
            //NSLog (@"is a file");
            if([self.sndPlayer.acceptableFileExtensions containsObject:aStrPath.pathExtension]){
                SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:aStrPath]];                
                (row != -1) ? [self.currentSelectedPlaylist.tracks insertObject:zDataObj atIndex:row++] : [self.currentSelectedPlaylist.tracks addObject:zDataObj];
            }
        }
    }
    [playlistTableView noteNumberOfRowsChanged];
    [playlistTableView deselectAll:self];
    [self.currentSelectedPlaylist setCurrentTrackIndexByTrack:self.currentSelectedPlaylist.currentTrack];
    [playlistTableView reloadData];
    [self updateAllTabsTitles];
    [self save];
}

// player will preload next track in queue for smooth track swithing
- (SNDTrack *) nextTrack {
    NSInteger current = self.currentPlayingPlaylist.currentTrackIndex.intValue;
    NSInteger total = [self.currentPlayingPlaylist.tracks count] - 1;
    if(current < total){
        SNDTrack *t = [self.currentPlayingPlaylist selectNextOrPreviousTrack:YES];
        if(t)
            [playlistTableView reloadData];
        [self updateAllTabsTitles];
        return t;
    }
    return nil;
}

- (IBAction) doubleClick:(id)sender {
    NSInteger clickedRow = [playlistTableView clickedRow];
    if([self.currentSelectedPlaylist.tracks count] >= clickedRow){
        self.currentPlayingPlaylist = self.currentSelectedPlaylist;
        [self playTrack:[self.currentSelectedPlaylist selectItemAtRow:clickedRow]];
    }
}

- (void) showCommonInformationalAlert:(NSString *)messageText informativeText:(NSString *)information {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:messageText];
    [alert setInformativeText:information];    
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    [alert beginSheetModalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(commonInformationalAlertDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
}

- (void)commonInformationalAlertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)info {
//	if (returnCode == NSAlertFirstButtonReturn) {
//        NSLog(@"1");
//    } else {
//        NSLog(@"2");
//	}
}

- (void) playTrack:(SNDTrack *)track {
    if(track){
        if(track.isAccessible){
            [self.sndPlayer playTrack:track];
            if(!self.currentPlayingPlaylist)
                self.currentPlayingPlaylist = self.currentSelectedPlaylist;
            [playlistTableView reloadData];
            [self updateAllTabsTitles];
        } else {
            [self showCommonInformationalAlert:@"File not found" informativeText:@"maybe it's moved or deleted"];
        }
    }
}

- (IBAction) controlAction:(NSSegmentedControl *)sender {
    switch(sender.selectedSegment) {
        // previous button
        case 0:
        {
            [self previous];
            break;
        }
        // play/pause button
        case 1:
        {
            [self playPause];
            break;
        }
        // next button
        case 2:
        {
            [self next];
            break;
        }
    }
}

- (void) previous {
    (self.currentPlayingPlaylist) ? [self playTrack:[self.currentPlayingPlaylist selectNextOrPreviousTrack:NO]] : [self playTrack:[self.currentSelectedPlaylist selectNextOrPreviousTrack:NO]];
}

- (void) next {
    (self.currentPlayingPlaylist) ? [self playTrack:[self.currentPlayingPlaylist selectNextOrPreviousTrack:YES]] : [self playTrack:[self.currentSelectedPlaylist selectNextOrPreviousTrack:YES]];
}

- (void) playPause {
    if(self.currentPlayingPlaylist){
        [self.sndPlayer playPauseAction];
        return;
    }
    
    if([self.currentSelectedPlaylist.tracks count] > 0){
        // if no selected track
        if(self.currentSelectedPlaylist.currentTrackIndex.integerValue == -1){
            self.currentSelectedPlaylist.currentTrackIndex = [NSNumber numberWithInt:0];
            [self.currentSelectedPlaylist setCurrentTrackByIndex:self.currentSelectedPlaylist.currentTrackIndex];
            [self playTrack:[self.currentSelectedPlaylist selectItemAtRow:self.currentSelectedPlaylist.currentTrackIndex.intValue]];
            self.currentPlayingPlaylist = self.currentSelectedPlaylist;
            return;
        }
        [self.sndPlayer playPauseAction];
    }
    return;
}

@end