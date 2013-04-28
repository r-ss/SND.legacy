//
//  SNDWindow.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol WindowDropDelegate <NSObject>
- (void) filesDroppedIntoWindow:(NSArray *)filesURL;
@end

@interface SNDWindow : NSWindow <NSDraggingDestination>

@property (nonatomic, weak) id <WindowDropDelegate> windowDropDelegate;

@end