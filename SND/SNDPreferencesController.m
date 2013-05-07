//
//  SNDPreferencesController.m
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPreferencesController.h"
#import "SNDTotalPlaybackTimeCounter.h"


@interface SNDPreferencesController ()

@end

@implementation SNDPreferencesController

@synthesize quitOnWindowCloseButton = _quitOnWindowCloseButton;
@synthesize totalPlaybackTimeField = _totalPlaybackTimeField;
@synthesize playbackCounterTimer = _playbackCounterTimer;

- (void) setup {
    NSLog(@">> preferences setup");
    self.appDelegate = NSApplication.sharedApplication.delegate;
    self.window.delegate = self;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL quit = [userDefaults boolForKey:@"SNDPreferencesQuitOnWindowClose"];
    [self.quitOnWindowCloseButton setState:quit];
    
    [self.totalPlaybackTimeField setStringValue:[self.appDelegate.totalPlaybackTimeCounter getTotalPlaybackTime]];
    self.playbackCounterTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];    
}

- (void) timerTick: (NSTimer *)timer {
    //NSLog(@">> tick");
    //self.appDelegate = NSApplication.sharedApplication.delegate;
    [self.totalPlaybackTimeField setStringValue:[self.appDelegate.totalPlaybackTimeCounter getTotalPlaybackTime]];
}

- (void)windowWillClose:(NSNotification *)notification {
    NSLog(@">> windowWillClose");
    [self.playbackCounterTimer invalidate];
}

- (void) windowDidLoad {
    [super windowDidLoad];
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
