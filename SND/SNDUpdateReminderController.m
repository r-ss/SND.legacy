//
//  SNDUpdateReminderController.m
//  SND
//
//  Created by Alex Antipov on 5/11/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDUpdateReminderController.h"
#import "SNDAppDelegate.h"
#import "SNDLatestVersionXMLLoader.h"

@implementation SNDUpdateReminderController

@synthesize updateReminderWindow = _updateReminderWindow;
@synthesize updateInfoField = _updateInfoField;
@synthesize remindAboutUpdateCheck = _remindAboutUpdateCheck;

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void) show {
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    if(!self.updateReminderWindow)
        [NSBundle loadNibNamed:@"UpdateReminder" owner:self];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL remind = [userDefaults boolForKey:@"SNDPreferencesRemindAboutUpdates"];
    [self.remindAboutUpdateCheck setState:remind];
    
    NSString *txt = [NSString stringWithFormat:@"Update is available.\nYour version is %@\nNew version is %@", appDelegate.currentAppVersion, appDelegate.latestVersionXMLLoader.latestVersion];
    [self.updateInfoField setStringValue:txt];
    
    //self.nameField.stringValue = initialText;
    [NSApp beginSheet:self.updateReminderWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
}

- (IBAction) remindAboutUpdateAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[self.remindAboutUpdateCheck state] forKey:@"SNDPreferencesRemindAboutUpdates"];
    [userDefaults synchronize];
}

- (IBAction) downloadButton:(id)sender {
    [NSApp endSheet:self.updateReminderWindow returnCode:NSOKButton];
}
- (IBAction) cancelButton:(id)sender {
    [NSApp endSheet:self.updateReminderWindow returnCode:NSCancelButton];
}

- (void) sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
    //NSLog(@"return code: %ld", (long)returnCode);
    //NSLog(@"context info: %@", contextInfo);
    if (returnCode == NSOKButton) {
        SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
        [[NSWorkspace sharedWorkspace] openURL:[appDelegate.latestVersionXMLLoader latestVersionDownloadURL]];
    }
}

@end
