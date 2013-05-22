//
//  SNDAppDelegate.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//#import "SNDBox.h"

@class SNDBox;

@class SNDPlaylist;
@class SNDPreferencesController;
@class SNDTotalPlaybackTimeCounter;
@class SNDLatestVersionXMLLoader;
@class SNDUpdateReminderController;

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
@property (strong) SNDPreferencesController *preferencesController;
@property (strong) SNDUpdateReminderController *updateReminderController;
@property (strong) SNDTotalPlaybackTimeCounter *totalPlaybackTimeCounter;
@property (strong) SNDLatestVersionXMLLoader *latestVersionXMLLoader;


@property (nonatomic, readonly) NSString *currentAppVersion;
@property (nonatomic, readonly) NSURL *databaseStoreURL;
@property (nonatomic, readonly) NSURL *websiteURL;


@property (nonatomic, assign) IBOutlet NSMenu *mainMenu;

- (IBAction) showPreferences:(id)sender;

- (IBAction) openWebsite:(id)sender;
- (void) openWebsite;

@end
