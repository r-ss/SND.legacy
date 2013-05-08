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

@implementation SNDBox

@synthesize playlists = _playlists;
@synthesize currentTrack = _currentTrack;

@synthesize currentSelectedPlaylist = _currentSelectedPlaylist;
@synthesize currentPlayingPlaylist = _currentPlayingPlaylist;

//@synthesize managedObjectContext = _managedObjectContext;

NSString *const PBType = @"playlistRowDragDropType";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.appDelegate = NSApplication.sharedApplication.delegate;
    self.appDelegate.dockDropDelegate = self;
    
    self.sndWindow.windowDropDelegate = self;
    
    self.playlists = [[NSMutableArray alloc] init];
        
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playlistDeleteNotification:) name:@"SND.Notification.PlaylistDeleteKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playerStoppedPlayingNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:@"SND.Notification.applicationDidFinishLaunching" object:nil];
    //[nc addObserver:self selector:@selector(playerPlayingStateWasChangedNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(playerPlayingStateWasChangedNotification:) name:@"SND.Notification.PlayerStartedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(playlistPreviousNotification:) name:@"PlaylistPreviousKeyPressed" object:nil];
    //[nc addObserver:self selector:@selector(playlistNextNotification:) name:@"PlaylistNextKeyPressed" object:nil];
    
    [playlistTableView setTarget:self];
    [playlistTableView setDoubleAction:@selector(doubleClick:)];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObject:PBType]];
    [playlistTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    // some default data
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/file2.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/01 - Foxygen - In The Darkness.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/1 - Joy Orbison - Ellipsis.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/04 - DFRNT - That's Interesting.mp3"]]];
    
    NSInteger i;
    for(i = 0; i < 5; i++){
        SNDPlaylist *playlist = [[SNDPlaylist alloc] init];
        [self.playlists addObject:playlist];
    }
    
    self.currentSelectedPlaylist = [self.playlists objectAtIndex:0];
    
    
    
    
    //self.currentTrackIndex = [NSNumber numberWithInt:-1];
    
    [playlistTableView reloadData];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBType, NSFilenamesPboardType, @"public.utf8-plain-text", nil]];
	[playlistTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (IBAction) tabAction:(NSSegmentedControl *)sender {
    //NSLog(@"tab click: %ld", sender.selectedSegment);
    if([self.playlists indexOfObject:self.currentSelectedPlaylist] != sender.selectedSegment){
        //[self.currentPlaylist deactivate];
        self.currentSelectedPlaylist = [self.playlists objectAtIndex:sender.selectedSegment];
        [playlistTableView reloadData];
        [playlistTableView deselectAll:self];
    }
    //NSLog(@"%@", self.currentPlaylist.tracks);
}

- (void) save {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *tracks = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSManagedObject *trackMO = nil;
    
    // delete all data before saving new
    if([tracks count] > 0){
        //NSLog(@"found");
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            [self.appDelegate.managedObjectContext deleteObject:trackMO];
        }
    }
    
    NSInteger i;
    for (i = 0; i < [self.playlists count]; i++) {
        NSInteger k;
        SNDPlaylist *playlist = [self.playlists objectAtIndex:i];
        
        for (k = 0; k < [playlist.tracks count]; k++) {
            SNDTrack *t = [playlist.tracks objectAtIndex:k];
            trackMO = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
            [trackMO setValue:t.path forKey:@"path"];
            [trackMO setValue:[NSNumber numberWithInteger:k] forKey:@"row"];
            [trackMO setValue:[NSNumber numberWithInteger:i] forKey:@"memberOfPlaylist"];
        }
    }
      
    NSError *err = nil;
    if(![self.appDelegate.managedObjectContext save:&err]){
        NSLog(@"error %@, %@", err, [err userInfo]);
        abort();
    }
}

- (void) load {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *tracks = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSManagedObject *trackMO = nil;
    
    if([tracks count] > 0){
        NSMutableArray *rawTracks = [[NSMutableArray alloc] init];       
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            SNDTrack *t = [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:[trackMO valueForKey:@"path"]]];
            int rowIndex = [[trackMO valueForKey:@"row"] intValue];
            int memberOfPlaylist = [[trackMO valueForKey:@"memberOfPlaylist"] intValue];
            [rawTracks addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:memberOfPlaylist],[NSNumber numberWithInt:rowIndex],t, nil ]];
        }
        
        NSLog(@"found %ld raw tracks", [rawTracks count]);

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
        [playlistTableView reloadData];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == playlistTableView) {
        return [self.currentSelectedPlaylist.tracks count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
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

- (void)tableView:(NSTableView *)pTableView setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRowIndex {
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

- (NSDragOperation)tableView:(NSTableView*)pTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
    return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)pTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)pRow dropOperation:(NSTableViewDropOperation)operation {
	
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

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard {
	// declare our own pasteboard types
	NSArray *typesArray = [NSArray arrayWithObjects:PBType, nil];
	[pboard declareTypes:typesArray owner:self];
	// add rows array for local move
	[pboard setPropertyList:rows forType:PBType];
	return YES;
}

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows {
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSUInteger NSUI = 2;
    [indexSet addIndex:NSUI];
	return indexSet;
}


- (int)rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet {
	NSUInteger currentIndex = [indexSet firstIndex];
	int i = 0;
	while (currentIndex != NSNotFound) {
		if (currentIndex < row)
			i++;
		currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
	}
	return i;
}

- (void)playlistDeleteNotification:(NSNotification *)notification{
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
    [self save];
}

- (void)playerStoppedPlayingNotification:(NSNotification *)notification{
    self.currentPlayingPlaylist.currentTrack = nil;
    self.currentPlayingPlaylist.currentTrackIndex = [NSNumber numberWithInt:-1];
    self.currentPlayingPlaylist = nil;
    [playlistTableView reloadData];
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
    [self save];
}

// player will preload next track in queue for smooth track swithing
- (SNDTrack *)nextTrack {
    NSInteger current = self.currentPlayingPlaylist.currentTrackIndex.intValue;
    NSInteger total = [self.currentPlayingPlaylist.tracks count] - 1;
    if(current < total){
        SNDTrack *t = [self.currentPlayingPlaylist selectNextOrPreviousTrack:YES];
        if(t)
            [playlistTableView reloadData];
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

- (void) playTrack:(SNDTrack *)track {
    if(track){
        if(track.isAccessible){
            [self.sndPlayer playTrack:track];
            if(!self.currentPlayingPlaylist)
                self.currentPlayingPlaylist = self.currentSelectedPlaylist;
            [playlistTableView reloadData];
        }
    }
}

- (IBAction)controlAction:(NSSegmentedControl *)sender {
    switch(sender.selectedSegment) {
        // previous button
        case 0:
        {
            (self.currentPlayingPlaylist) ? [self playTrack:[self.currentPlayingPlaylist selectNextOrPreviousTrack:NO]] : [self playTrack:[self.currentSelectedPlaylist selectNextOrPreviousTrack:NO]];
            break;
        }
        // play/pause button
        case 1:
        {
            if(self.currentPlayingPlaylist){
                [self.sndPlayer playPauseAction];
                break;
            }
                
            if([self.currentSelectedPlaylist.tracks count] > 0){
                // if no selected track
                if(self.currentSelectedPlaylist.currentTrackIndex.integerValue == -1){
                    self.currentSelectedPlaylist.currentTrackIndex = [NSNumber numberWithInt:0];
                    [self.currentSelectedPlaylist setCurrentTrackByIndex:self.currentSelectedPlaylist.currentTrackIndex];
                    [self playTrack:[self.currentSelectedPlaylist selectItemAtRow:self.currentSelectedPlaylist.currentTrackIndex.intValue]];
                    self.currentPlayingPlaylist = self.currentSelectedPlaylist;
                    break;
                }
                [self.sndPlayer playPauseAction];
            }
            break;
        }
        // next button
        case 2:
        {
            (self.currentPlayingPlaylist) ? [self playTrack:[self.currentPlayingPlaylist selectNextOrPreviousTrack:YES]] : [self playTrack:[self.currentSelectedPlaylist selectNextOrPreviousTrack:YES]];
            break;
        }
    }
}

@end
