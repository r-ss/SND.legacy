//
//  SNDBox.m
//  SND
//
//  Created by Alex Antipov on 4/29/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDBox.h"
#import "SNDPlayer.h"

@implementation SNDBox

NSString *const PBType = @"playlistRowDragDropType";

- (void)awakeFromNib {
    [super awakeFromNib];
    self.sndWindow.windowDropDelegate = self;
    self.sndAppDelegate.dockDropDelegate = self;
    
    [playlistTableView setTarget:self];
    [playlistTableView setDoubleAction:@selector(doubleClick:)];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObject:PBType]];
    [playlistTableView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
        
    [playlistTableView reloadData];
    [playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:PBType, NSFilenamesPboardType, @"public.utf8-plain-text", nil]];
	[playlistTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
}


////////////////////////////////////////////////////////////
///// All about Rows
////////////////////////////////////////////////////////////
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == playlistTableView) {
        return [self.playlistData count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == playlistTableView) {
        if([tableColumn.identifier isEqualToString:@"state"]){
            if (row == self.currentTrackIndex.intValue){
                return @">";
            } else {
                return @"";
            }
        }
        SNDTrack *t = [self.playlistData objectAtIndex:row];
        NSString *identifier = tableColumn.identifier;
        return [t valueForKey:identifier];
	}
	return NULL;
}

- (void)tableView:(NSTableView *)pTableView setObjectValue:(id)pObject forTableColumn:(NSTableColumn *)pTableColumn row:(NSInteger)pRowIndex {
    if (pTableView == playlistTableView) {
		SNDTrack * zData = [self.playlistData objectAtIndex:pRowIndex];
		zData.path	= (NSString *)pObject;
        [self.playlistData replaceObjectAtIndex:pRowIndex withObject:zData];
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
	SNDTrack * zDataObj	= [self.playlistData objectAtIndex:zIndex];
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
			[zArySelectedElements addObject:[self.playlistData objectAtIndex:i]];
		}
		NSMutableArray *zNewAry = [[NSMutableArray alloc]init];
        ////// TOP
		for (i = 0; i < pRow; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.playlistData objectAtIndex:i]];
		}
		[zNewAry addObjectsFromArray:zArySelectedElements];
        ////// BOTTOM
		for (i = pRow; i < [self.playlistData count]; i++) {
			if ([zNSIndexSetRows containsIndex:i]) {
				continue;
			}
			[zNewAry addObject:[self.playlistData objectAtIndex:i]];
		}
        
		self.playlistData = zNewAry;
        [self setCurrentTrackIndexByTrack:self.currentTrack];
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
		[self.playlistData insertObject:zDataObj atIndex:pRow];
		[playlistTableView noteNumberOfRowsChanged];
        [playlistTableView deselectAll:self];
        [self setCurrentTrackIndexByTrack:self.currentTrack];
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
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////




@end
