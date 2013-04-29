//
//  SNDAppDelegate.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDAppDelegate.h"

#import "SNDPlayer.h"

@implementation SNDAppDelegate

@synthesize sndPlaylist = _sndPlaylist;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.sndPlaylist.managedObjectContext = self.managedObjectContext;
    [self.sndPlaylist loadPlaylist];
    
    //NSLog(@"** %@", [[[NSProcessInfo processInfo] environment] allKeys]);
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(traceNotifications:) name:nil object:nil];
    
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc postNotificationName:@"SND.Notification.applicationDidFinishLaunching" object:self];
    
    
}

- (void)traceNotifications:(NSNotification *)notification
{
    NSLog(@"** %@", [notification name]);
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
