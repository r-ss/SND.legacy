//
//  SNDWindow.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDWindow.h"
#import "SNDAppDelegate.h"
#import "SNDPreferencesController.h"

@implementation SNDWindow

- (void)awakeFromNib
{
    [super awakeFromNib];
    //NSLog(@"Init");
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSURLPboardType]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowClosing:) name:NSWindowWillCloseNotification object:self];
    
}

- (void)windowClosing:(NSNotification*)aNotification {
    NSLog(@">> windowClosing");
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    if([appDelegate.preferencesController quitOnWindowClose]){
        [[NSApplication sharedApplication] terminate:self];
    }
}

// NSDraggingDestination methods
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"STARTED");
    
    // for show "+" icon on curson while dragging - MODIFY LATER FOR NOT USE NSIMAGE HERE
    if ([NSImage canInitWithPasteboard:[sender draggingPasteboard]] && [sender draggingSourceOperationMask] & NSDragOperationCopy) {
        return NSDragOperationCopy;
    }
    
    
    return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    //NSLog(@"DRAGGING");
    return NSDragOperationCopy;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    NSLog(@"ENDED");
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    NSLog(@"EXITED");
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSURL* fileURL;
    fileURL=[NSURL URLFromPasteboard: [sender draggingPasteboard]];
    NSArray *arr = [NSArray arrayWithObject:fileURL.path];
    [self.windowDropDelegate filesDroppedIntoWindow:arr];
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
    
}
/// NSDraggingDestination methods


@end
