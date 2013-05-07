//
//  SNDPreferencesController.m
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPreferencesController.h"

#import "SNDAppDelegate.h"
#import "SNDTotalPlaybackTimeCounter.h"


@interface SNDPreferencesController ()

@end

@implementation SNDPreferencesController

@synthesize quitOnWindowCloseButton = _quitOnWindowCloseButton;
@synthesize totalPlaybackTimeField = _totalPlaybackTimeField;

- (id) init
{
    //self = [super initWithWindowNibName:@"Preferences"];
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) awakeFromNib {
    NSLog(@">> Preferences awakeFromNib");
    
    // temp total time view solution
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //NSNumber *totalTime = [NSNumber numberWithDouble:[userDefaults doubleForKey:@"SNDTotalPlaybackTime"]];
    //[self.totalPlaybackTimeField setDoubleValue:totalTime.doubleValue];
    
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    [self.totalPlaybackTimeField setStringValue:[appDelegate.totalPlaybackTimeCounter getTotalPlaybackTime]];
    
}

- (void) windowDidLoad {
    NSLog(@">> Preferences windowDidLoad");
    [super windowDidLoad];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL quit = [userDefaults boolForKey:@"SNDPreferencesQuitOnWindowClose"];
    quit ? NSLog(@">> YES") : NSLog(@">> NO");
    [self.quitOnWindowCloseButton setState:quit];
}

- (IBAction) quitOnWindowCloseAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[self.quitOnWindowCloseButton state] forKey:@"SNDPreferencesQuitOnWindowClose"];
    [userDefaults synchronize];
}

@end
