//
//  SNDAppDelegate.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SNDBox;

@protocol DockDropDelegate <NSObject>
- (void) filesDroppedIntoDock:(NSArray *)filesURL;
@end

@interface SNDAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet SNDBox *sndBox;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, weak) id <DockDropDelegate> dockDropDelegate;

@end
