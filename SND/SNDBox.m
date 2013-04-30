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

@synthesize managedObjectContext = _managedObjectContext;

NSString *const PBType = @"playlistRowDragDropType";

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sndWindow.windowDropDelegate = self;
    self.sndAppDelegate.dockDropDelegate = self;
    
    self.playlists = [[NSMutableArray alloc] init];
        
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(playlistDeleteNotification:) name:@"SND.Notification.PlaylistDeleteKeyPressed" object:nil];
    [nc addObserver:self selector:@selector(playerFinishedPlayingNotification:) name:@"SND.Notification.PlayerFinishedPlaying" object:nil];
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
    
    self.currentPlaylist = [self.playlists objectAtIndex:0];
    
    
    
    
    //self.currentTrackIndex = [NSNumber numberWithInt:-1];
    
    [playlistTableView reloadData];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBType, NSFilenamesPboardType, @"public.utf8-plain-text", nil]];
	[playlistTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (IBAction) tabAction:(NSSegmentedControl *)sender {
    NSLog(@"tab click: %ld", sender.selectedSegment);
    if([self.playlists indexOfObject:self.currentPlaylist] != sender.selectedSegment){
        //[self.currentPlaylist deactivate];
        self.currentPlaylist = [self.playlists objectAtIndex:sender.selectedSegment];
        [playlistTableView reloadData];
        [playlistTableView deselectAll:self];
    }
    //NSLog(@"%@", self.currentPlaylist.tracks);
}
/*
- (void) savePlaylist {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSArray *tracks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSManagedObject *trackMO = nil;
    
    // delete all data before saving new
    if([tracks count] > 0){
        //NSLog(@"found");
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            [self.managedObjectContext deleteObject:trackMO];
        }
    }
    
    NSInteger i;
    for (i = 0; i < [self.playlistData count]; i++) {
        SNDTrack *t = [self.playlistData objectAtIndex:i];
        trackMO = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
        [trackMO setValue:t.path forKey:@"path"];
        [trackMO setValue:[NSNumber numberWithInteger:i] forKey:@"row"];
    }
    
    NSError *err = nil;
    if(![self.managedObjectContext save:&err]){
        NSLog(@"error %@, %@", err, [err userInfo]);
        abort();
    }
}

- (void) loadPlaylist {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *tracks = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSManagedObject *trackMO = nil;
    
    if([tracks count] > 0){
        //NSLog(@"found");
        NSMutableArray *unsortedRows = [[NSMutableArray alloc] init];
        
        NSInteger i;
        for (i = 0; i < [tracks count]; i++) {
            trackMO = [tracks objectAtIndex:i];
            SNDTrack *t = [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:[trackMO valueForKey:@"path"]]];
            int rowIndex = [[trackMO valueForKey:@"row"] intValue];
            [unsortedRows addObject:[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:rowIndex],t, nil ]];
        }
        
        NSArray *sortedRows = [unsortedRows sortedArrayUsingComparator:^(id a, id b)
                               {
                                   NSNumber *n1 = [a objectAtIndex:0];
                                   NSNumber *n2 = [b objectAtIndex:0];
                                   if (n1.integerValue > n2.integerValue)
                                       return (NSComparisonResult)NSOrderedDescending;
                                   if (n1.integerValue < n2.integerValue)
                                       return (NSComparisonResult)NSOrderedAscending;
                                   return (NSComparisonResult)NSOrderedSame;
                               }];
        for (i = 0; i < [tracks count]; i++) {
            [self.playlistData addObject:[[sortedRows objectAtIndex:i] objectAtIndex:1]];
        }
        [playlistTableView reloadData];
    }
}*/

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == playlistTableView) {
        return [self.currentPlaylist.tracks count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == playlistTableView) {
        if([tableColumn.identifier isEqualToString:@"state"]){
            if (row == self.currentPlaylist.currentTrackIndex.intValue){
                return @">";
            } else {
                return @"";
            }
        }
        SNDTrack *t = [self.currentPlaylist.tracks objectAtIndex:row];
        NSString *identifier = tableColumn.identifier;
        return [t valueForKey:identifier];
	}
	return NULL;
}

- (void)tableView:(NSTableView *)pTableView setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRowIndex {
    if (pTableView == playlistTableView) {
		SNDTrack * zData = [self.currentPlaylist.tracks objectAtIndex:pRowIndex];
		zData.path	= (NSString *)pObject;
        [self.currentPlaylist.tracks replaceObjectAtIndex:pRowIndex withObject:zData];
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
	SNDTrack * zDataObj	= [self.currentPlaylist.tracks objectAtIndex:zIndex];
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
			[zArySelectedElements addObject:[self.currentPlaylist.tracks objectAtIndex:i]];
		}
		NSMutableArray *zNewAry = [[NSMutableArray alloc]init];
        ////// TOP
		for (i = 0; i < pRow; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.currentPlaylist.tracks objectAtIndex:i]];
		}
		[zNewAry addObjectsFromArray:zArySelectedElements];
        ////// BOTTOM
		for (i = pRow; i < [self.currentPlaylist.tracks count]; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.currentPlaylist.tracks objectAtIndex:i]];
		}
        
		self.currentPlaylist.tracks = zNewAry;
        [self.currentPlaylist setCurrentTrackIndexByTrack:self.currentPlaylist.currentTrack];
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
		[self.currentPlaylist.tracks insertObject:zDataObj atIndex:pRow];
		[playlistTableView noteNumberOfRowsChanged];
        [playlistTableView deselectAll:self];
        [self.currentPlaylist setCurrentTrackIndexByTrack:self.currentPlaylist.currentTrack];
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
        if(index == self.currentPlaylist.currentTrackIndex.integerValue){
            self.currentPlaylist.currentTrackIndex = [NSNumber numberWithInteger: -1];
            self.currentPlaylist.currentTrack = nil;
        }
    }];
    [self.currentPlaylist.tracks removeObjectsAtIndexes:selectedRowIndexes];
    [playlistTableView deselectAll:self];
    [playlistTableView reloadData];
    //[self savePlaylist];
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
    //NSLog(@"> addFiles at row: %ld", (long)row);
    NSInteger i;
    for (i = 0; i < [filesURL count]; i++) {
        NSString * zStrFilePath	= [filesURL objectAtIndex:i];
        NSString * aStrPath = [zStrFilePath stringByStandardizingPath];
        
        BOOL isDir;
        if([[NSFileManager defaultManager] fileExistsAtPath: aStrPath isDirectory:&isDir] && isDir){
            //NSLog(@"is a directory");
            NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:aStrPath];
            
            NSMutableArray *unsortedFiles = [[NSMutableArray alloc] init];
            
            for (NSString *filepath in dirEnum) {
                //if ([[filepath pathExtension] isEqualToString: @"mp3"]) {
                if ([self.sndPlayer.acceptableFileExtensions containsObject:filepath.pathExtension]) {
                    NSString *path = [NSString stringWithFormat:@"%@/%@", aStrPath, filepath];
                    SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:path]];
                    [unsortedFiles addObject:zDataObj];
                }
            }
            
            NSArray *sortedFiles = [self sortSNDTracksByTrackNumber:unsortedFiles];
            for (i = 0; i < [sortedFiles count]; i++) {
                if(row != -1){
                    [self.currentPlaylist.tracks insertObject:[sortedFiles objectAtIndex:i] atIndex:row++];
                } else {
                    [self.currentPlaylist.tracks addObject:[sortedFiles objectAtIndex:i]];
                }
            }
            
        } else {
            //NSLog (@"is a file");
            if([self.sndPlayer.acceptableFileExtensions containsObject:aStrPath.pathExtension]){
                SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:aStrPath]];
                if(row != -1){
                    [self.currentPlaylist.tracks insertObject:zDataObj atIndex:row++];
                } else {
                    [self.currentPlaylist.tracks addObject:zDataObj];
                }
            }
        }
    }
    [playlistTableView noteNumberOfRowsChanged];
    [playlistTableView deselectAll:self];
    [self.currentPlaylist setCurrentTrackIndexByTrack:self.currentPlaylist.currentTrack];
    [playlistTableView reloadData];
    //[self savePlaylist];
}

// player will preload next track in queue for smooth track swithing
- (SNDTrack *)nextTrack {
    NSInteger current = self.currentPlaylist.currentTrackIndex.intValue;
    NSInteger total = [self.currentPlaylist.tracks count] - 1;
    NSLog(@"atata");
    if(current < total){
        SNDTrack *t = [self.currentPlaylist selectNextOrPreviousTrack:YES];
        if(t)
            [playlistTableView reloadData];
        return t;
    }
    return nil;
}

- (IBAction) doubleClick:(id)sender {
    //[self.currentPlaylist selectItemAtRow:[playlistTableView clickedRow]];
    [self.sndPlayer playTrack:[self.currentPlaylist selectItemAtRow:[playlistTableView clickedRow]]];
    [playlistTableView reloadData];
}

- (IBAction)controlAction:(NSSegmentedControl *)sender {
    switch(sender.selectedSegment) {
        // previous button
        case 0:
        {
            ////[self.currentPlaylist selectNextOrPreviousTrack:NO andPlay:YES];
            [self.sndPlayer playTrack:[self.currentPlaylist selectNextOrPreviousTrack:NO]];
            [playlistTableView reloadData];
            break;
        }
        // play/pause button
        case 1:
        {
            if([self.currentPlaylist.tracks count] > 0){
                // if no selected track
                if(self.currentPlaylist.currentTrackIndex.integerValue == -1){
                    self.currentPlaylist.currentTrackIndex = [NSNumber numberWithInt:0];
                    [self.currentPlaylist setCurrentTrackByIndex:self.currentPlaylist.currentTrackIndex];
                    [self.sndPlayer playTrack:[self.currentPlaylist selectItemAtRow:self.currentPlaylist.currentTrackIndex.intValue]];
                    break;
                }
                [self.sndPlayer playPauseAction];
                [playlistTableView reloadData];
            }
            break;
        }
        // next button
        case 2:
        {
            [self.sndPlayer playTrack:[self.currentPlaylist selectNextOrPreviousTrack:YES]];
            [playlistTableView reloadData];
            break;
        }
    }
}

@end
