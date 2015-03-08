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
#import "SNDUpdateReminderController.h"
#import "SNDLatestVersionXMLLoader.h"


// CocoaLumberjack Logger - https://github.com/CocoaLumberjack/CocoaLumberjack
#import <CocoaLumberjack/CocoaLumberjack.h>
// Debug levels: off, error, warn, info, verbose
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


@implementation SNDAppDelegate

@synthesize sndBox = _sndBox;
@synthesize preferencesController = _preferencesController;
@synthesize totalPlaybackTimeCounter = _totalPlaybackTimeCounter;
@synthesize latestVersionXMLLoader = _latestVersionXMLLoader;
@synthesize updateReminderController = _updateReminderController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize currentAppVersion = _currentAppVersion;
@synthesize databaseStoreURL = _databaseStoreURL;
@synthesize websiteURL = _websiteURL;

@synthesize mainMenu = _mainMenu;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //self.sndBox = [[SNDBox alloc] init];
    //self.sndBox.managedObjectContext = self.managedObjectContext;
    
    //NSLog(@"hey");
   
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    //[[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    
    

//    DDLogError(@"This is an error.");
//    DDLogWarn(@"This is a warning.");
//    DDLogInfo(@"This is just a message.");
//    DDLogVerbose(@"This is a verbose message.");
    
    
    _currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //_currentAppVersion = @"0.6.6";

    self.preferencesController = [[SNDPreferencesController alloc] init];
    self.totalPlaybackTimeCounter = [[SNDTotalPlaybackTimeCounter alloc] init];
    
    // setting database path
    NSString *homeDir = NSHomeDirectory();
    //NSString *path = [homeDir stringByAppendingString:@"/Music/snd.sqlite"];
    NSString *path = [homeDir stringByAppendingString:@"/Music/snd_dev.sqlite"];
    _databaseStoreURL = [NSURL fileURLWithPath:path];
    
    _websiteURL = [NSURL URLWithString:@"http://snd-app.com/"];
    
    
    // registering in notification center
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(latestVersionXMLLoaded:) name:@"SND.Notification.LatestVersionXMLLoaded" object:nil];
    
    
    self.latestVersionXMLLoader = [[SNDLatestVersionXMLLoader alloc] initAndLoad];

    DDLogInfo(@"total playback time: %@", [self.totalPlaybackTimeCounter getTotalPlaybackTime]);
    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *latestStartTime = (NSDate *)[userDefaults objectForKey:@"SNDLatestStartTime"];
    // if latestStartTime = nil, than application is started first time
    if(latestStartTime == nil)
        [self firstStartRoutine];
    
    NSString *latestStartedVersion = (NSString *)[userDefaults objectForKey:@"SNDLatestStartedVersion"];
    //DDLogInfo(@">>>> versions compare: latest started:%@, current:%@", latestStartedVersion, self.currentAppVersion);
    if((latestStartedVersion != nil) && (![latestStartedVersion isEqualToString: self.currentAppVersion])){
        [self updateRoutine];
    }
    
    [userDefaults setObject:[NSDate date] forKey:@"SNDLatestStartTime"];
    [userDefaults setObject:self.currentAppVersion forKey:@"SNDLatestStartedVersion"];
    [userDefaults synchronize];

    DDLogInfo(@"Latest app start time: %@", latestStartTime);
    
    [self.sndBox load];
}

- (void) latestVersionXMLLoaded:(NSNotification *)notification {
    if([self.latestVersionXMLLoader updateIsAvailable] && [self.preferencesController remindAboutUpdates]){
        self.updateReminderController = [[SNDUpdateReminderController alloc] init];
        [self.updateReminderController show];
    }
}

- (void) firstStartRoutine {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"SNDPreferencesRemindAboutUpdates"];
    [userDefaults setBool:NO forKey:@"SNDPreferencesQuitOnWindowClose"];    
    [userDefaults setDouble:100.0 forKey:@"SNDVolume"];
    [userDefaults synchronize];
}

- (void) updateRoutine {
    DDLogInfo(@"> updateRoutine");
    
    // removing database sqlite file for prevent CoreData entities conflicts
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:self.databaseStoreURL.path]) {
        [fm removeItemAtPath:self.databaseStoreURL.path error:&error];
        if(error)
            DDLogInfo(@"Can't remove database file: %@",error);
    }
}

- (IBAction) showPreferences:(id)sender {
    [self.preferencesController show];
}

- (IBAction) openWebsite:(id)sender {
    [self openWebsite];
}
- (void) openWebsite {
    DDLogInfo(@"Opening snd-app.com");
    [[NSWorkspace sharedWorkspace] openURL:self.websiteURL];
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
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.databaseStoreURL options:nil error:&error]) {
        DDLogInfo(@"Unresolved error %@, %@", error, [error userInfo]);
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
    //DDLogInfo(@"BB %@", filenames);
    [self.dockDropDelegate filesDroppedIntoDock:files];
}

@end
