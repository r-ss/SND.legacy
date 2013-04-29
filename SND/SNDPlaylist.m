//
//  SNDPlaylist.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaylist.h"
#import "SNDPlayer.h"

@implementation SNDPlaylist

@synthesize playlistData = _playlistData;
@synthesize currentTrack = _currentTrack;
@synthesize currentTrackIndex = _currentTrackIndex;

@synthesize managedObjectContext = _managedObjectContext;

- (id)init {
    self = [super init];
    if (self) {
        self.playlistData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
  


    // registering in notification center
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc addObserver:self selector:@selector(playlistDeleteNotification:) name:@"SND.Notification.PlaylistDeleteKeyPressed" object:nil];
    //[nc addObserver:self selector:@selector(playerFinishedPlayingNotification:) //name:@"SND.Notification.PlayerFinishedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(applicationDidFinishLaunchingNotification:) name:@"SND.Notification.applicationDidFinishLaunching" object:nil];
    //[nc addObserver:self selector:@selector(playerPlayingStateWasChangedNotification:) name:@"SND.Notification.PlayerStoppedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(playerPlayingStateWasChangedNotification:) name:@"SND.Notification.PlayerStartedPlaying" object:nil];
    //[nc addObserver:self selector:@selector(playlistPreviousNotification:) name:@"PlaylistPreviousKeyPressed" object:nil];
    //[nc addObserver:self selector:@selector(playlistNextNotification:) name:@"PlaylistNextKeyPressed" object:nil];

    //[playlistTableView setTarget:self];
    //[playlistTableView setDoubleAction:@selector(doubleClick:)];
    //[playlistTableView registerForDraggedTypes:[NSArray arrayWithObject:PBType]];
    //[playlistTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    // some default data
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/file2.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/01 - Foxygen - In The Darkness.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/1 - Joy Orbison - Ellipsis.mp3"]]];
    //[self.playlistData addObject:[[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:@"/Users/ress/Desktop/sndmp3/04 - DFRNT - That's Interesting.mp3"]]];

    
    self.currentTrackIndex = [NSNumber numberWithInt:-1];

    //[playlistTableView reloadData];
    //[playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBType, NSFilenamesPboardType, @"public.utf8-plain-text", nil]];
	//[playlistTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

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
}

- (void) setCurrentTrackByIndex:(NSNumber *)index {
    self.currentTrackIndex = index;
    self.currentTrack = [self.playlistData objectAtIndex:index.integerValue];
}

- (void) setCurrentTrackIndexByTrack:(SNDTrack *)currentTrack {
    self.currentTrackIndex = [NSNumber numberWithInteger:[self.playlistData indexOfObject:currentTrack]];
}

-(void) selectNextOrPreviousTrack:(BOOL)next andPlay:(BOOL)play {
    if(self.currentTrackIndex.integerValue == -1){
        self.currentTrackIndex = [NSNumber numberWithInt:0];
        [self setCurrentTrackByIndex:self.currentTrackIndex];
        [self selectItemAtRow:self.currentTrackIndex.intValue andPlay:YES];
        return;
    }
    NSInteger current = self.currentTrackIndex.intValue;
    NSInteger total = [self.playlistData count] - 1;
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
            [self selectItemAtRow:current andPlay:play];
    }
}

- (void)playlistDeleteNotification:(NSNotification *)notification{
    [playlistTableView abortEditing];
    
    NSIndexSet *selectedRowIndexes = [playlistTableView selectedRowIndexes];
    
    [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop){
        if(index == self.currentTrackIndex.integerValue){
            self.currentTrackIndex = [NSNumber numberWithInteger: -1];
            self.currentTrack = nil;
        }
    }];
    [self.playlistData removeObjectsAtIndexes:selectedRowIndexes];
    [playlistTableView deselectAll:self];
    [playlistTableView reloadData];
    [self savePlaylist];
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
                    [self.playlistData insertObject:[sortedFiles objectAtIndex:i] atIndex:row++];
                } else {
                    [self.playlistData addObject:[sortedFiles objectAtIndex:i]];
                }
            }          
            
        } else {
            //NSLog (@"is a file");
            if([self.sndPlayer.acceptableFileExtensions containsObject:aStrPath.pathExtension]){
                SNDTrack * zDataObj	= [[SNDTrack alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:aStrPath]];
                if(row != -1){
                    [self.playlistData insertObject:zDataObj atIndex:row++];
                } else {
                    [self.playlistData addObject:zDataObj];
                }
            }
        }
    }
    [playlistTableView noteNumberOfRowsChanged];
    [playlistTableView deselectAll:self];
    [self setCurrentTrackIndexByTrack:self.currentTrack];
    [playlistTableView reloadData];
    [self savePlaylist];
}

// player will preload next track in queue for smooth track swithing
- (SNDTrack *)nextTrack {
    NSInteger current = self.currentTrackIndex.intValue;
    NSInteger total = [self.playlistData count] - 1;
    if(current < total){
        SNDTrack *t = [self.playlistData objectAtIndex:current + 1];
        [self selectNextOrPreviousTrack:YES andPlay:NO];
        return t;
    }
    return nil;
}


-(void)selectItemAtRow:(NSInteger)rowIndex andPlay:(BOOL)play {
    SNDTrack *t = [self.playlistData objectAtIndex:rowIndex];
    self.currentTrackIndex = [NSNumber numberWithInt:rowIndex];
    [self setCurrentTrackByIndex:self.currentTrackIndex];
    [playlistTableView reloadData];
    if(play)
        [self.sndPlayer playTrack:t];
}

- (IBAction) doubleClick:(id)sender {
    [self selectItemAtRow:[playlistTableView clickedRow] andPlay:YES];
}

- (IBAction)controlAction:(NSSegmentedControl *)sender {
    switch(sender.selectedSegment) {
        // previous button
        case 0:
        {
            [self selectNextOrPreviousTrack:NO andPlay:YES];
            break;
        }
        // play/pause button
        case 1:
        {
            if([self.playlistData count] > 0){
                // if no selected track
                if(self.currentTrackIndex.integerValue == -1){
                    self.currentTrackIndex = [NSNumber numberWithInt:0];
                    [self setCurrentTrackByIndex:self.currentTrackIndex];
                    [self selectItemAtRow:self.currentTrackIndex.intValue andPlay:YES];
                    break;
                }
                [self.sndPlayer playPauseAction];
            }
            break;
        }
        // next button
        case 2:
        {
            [self selectNextOrPreviousTrack:YES andPlay:YES];
            break;
        }
    }
}

@end