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

@implementation SNDAppDelegate

@synthesize sndBox = _sndBox;
@synthesize preferencesController = _preferencesController;
@synthesize totalPlaybackTimeCounter = _totalPlaybackTimeCounter;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //self.sndBox = [[SNDBox alloc] init];
    
    
    //self.sndBox.managedObjectContext = self.managedObjectContext;
    [self.sndBox load];
    
    self.preferencesController = [[SNDPreferencesController alloc] initWithWindowNibName:@"Preferences"];
    
    
    self.totalPlaybackTimeCounter = [[SNDTotalPlaybackTimeCounter alloc] init];
    
    NSLog(@"total playback time: %@", [self.totalPlaybackTimeCounter getTotalPlaybackTime]);
    

    
    //NSString *currentFullName = (NSString *)CSIdentityGetFullName((CSIdentityRef)[_identities objectAtIndex:[_identityTableView selectedRow]]);
	
    
    
    //self.preferencesController = [[SNDPreferencesController alloc] init];
    //[self.preferencesController showWindow:self];
}


- (IBAction) showPreferencesPanel:(id)sender {
    //if(!self.preferencesController){
       //self.preferencesController = [[SNDPreferencesController alloc] initWithWindowNibName:@"Preferences"];
    //}
    [self.preferencesController showWindow:self];
    [self.preferencesController setup];
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
