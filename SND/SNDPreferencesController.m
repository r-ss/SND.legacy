//
//  SNDPreferencesController.m
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPreferencesController.h"
#import "SNDTotalPlaybackTimeCounter.h"
#import "SNDInfoXMLLoader.h"

@interface SNDPreferencesController ()

@end

@implementation SNDPreferencesController

@synthesize preferencesWindow = _preferencesWindow;

@synthesize quitOnWindowCloseButton = _quitOnWindowCloseButton;
@synthesize totalPlaybackTimeField = _totalPlaybackTimeField;
@synthesize playbackCounterTimer = _playbackCounterTimer;

- (id) init {
    self = [super init];
    if (self) {
        self.appDelegate = NSApplication.sharedApplication.delegate;
    }
    return self;
}


- (void) show {    
    if(!self.preferencesWindow)
        [NSBundle loadNibNamed:@"Preferences" owner:self];    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL quit = [userDefaults boolForKey:@"SNDPreferencesQuitOnWindowClose"];
    [self.quitOnWindowCloseButton setState:quit];
    
    [self.totalPlaybackTimeField setStringValue:[self.appDelegate.totalPlaybackTimeCounter getTotalPlaybackTime]];
    self.playbackCounterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    
    [self.appUpdateField setStringValue:[self.appDelegate.infoXMLLoader updateIsAvailableText]];

    [NSApp beginSheet:self.preferencesWindow modalForWindow:self.appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
}

- (IBAction) closeButton:(id)sender {
    [NSApp endSheet:self.preferencesWindow returnCode:NSOKButton];
}

- (IBAction) visitWebsite:(id)sender {
    [self.appDelegate openWebsite];
}

- (void) sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
    if (returnCode == NSOKButton) {
        [self.playbackCounterTimer invalidate];
    }
}

- (void) timerTick: (NSTimer *)timer {
    //NSLog(@">> tick");
    //self.appDelegate = NSApplication.sharedApplication.delegate;
    [self.totalPlaybackTimeField setStringValue:[self.appDelegate.totalPlaybackTimeCounter getTotalPlaybackTime]];
}

- (IBAction) quitOnWindowCloseAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[self.quitOnWindowCloseButton state] forKey:@"SNDPreferencesQuitOnWindowClose"];
    [userDefaults synchronize];
}

- (BOOL) quitOnWindowClose {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"SNDPreferencesQuitOnWindowClose"];
}

@end
