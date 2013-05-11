//
//  SNDAppDelegate.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDAppDelegate.h"
#import "SNDBox.h"
#import "SNDPreferencesController.h"
#import "SNDTotalPlaybackTimeCounter.h"

#import "SNDInfoXMLLoader.h"

@implementation SNDAppDelegate

@synthesize sndBox = _sndBox;
@synthesize preferencesController = _preferencesController;
@synthesize totalPlaybackTimeCounter = _totalPlaybackTimeCounter;
@synthesize infoXMLLoader = _infoXMLLoader;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize currentAppVersion = _currentAppVersion;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //self.sndBox = [[SNDBox alloc] init];
    //self.sndBox.managedObjectContext = self.managedObjectContext;
    _currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    self.preferencesController = [[SNDPreferencesController alloc] init];
    self.totalPlaybackTimeCounter = [[SNDTotalPlaybackTimeCounter alloc] init];
    
    [self.sndBox load];
    self.infoXMLLoader = [[SNDInfoXMLLoader alloc] initAndLoad];

    NSLog(@"total playback time: %@", [self.totalPlaybackTimeCounter getTotalPlaybackTime]);
}

- (IBAction) showPreferences:(id)sender {
    [self.preferencesController show];
}

- (IBAction) openWebsite:(id)sender {
    [self openWebsite];
}
- (void) openWebsite {
    NSLog(@"Opening snd-app.com");
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://snd-app.com/"]];
}

// CoreData gogogo
- (NSManagedObjectModel *)managedObjectModel {
    if(_managedObjectModel != nil){
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator != nil){
        return _persistentStoreCoordinator;
    }
    NSString *homeDir = NSHomeDirectory();
    //NSString *path = [homeDir stringByAppendingString:@"/Music/snd.sqlite"];
    NSString *path = [homeDir stringByAppendingString:@"/Desktop/snd.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext != nil){
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if(coordinator != nil){
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
    
}




// To enable window reopen after close
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    if (flag) {
        [self.window orderFront:self];
    } else {
        [self.window makeKeyAndOrderFront:self];
    }    
    return YES;
}

- (void) application:(NSApplication *)sender openFiles:(NSArray *)files {
    //NSLog(@"BB %@", filenames);
    [self.dockDropDelegate filesDroppedIntoDock:files];
}

@end
