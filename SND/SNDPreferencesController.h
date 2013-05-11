//
//  SNDPreferencesController.h
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SNDAppDelegate.h"

@interface SNDPreferencesController : NSWindowController <NSWindowDelegate>

@property (assign) IBOutlet NSWindow *preferencesWindow;

@property (nonatomic, retain) IBOutlet NSButton *quitOnWindowCloseButton;
- (IBAction) quitOnWindowCloseAction:(id)sender;

@property (nonatomic, retain) IBOutlet NSButton *remindAboutUpdatesCheck;
- (IBAction) remindAboutUpdatesAction:(id)sender;

@property (nonatomic, retain) IBOutlet NSTextField *totalPlaybackTimeField;

@property (nonatomic) SNDAppDelegate *appDelegate;
@property (nonatomic, strong) NSTimer *playbackCounterTimer;

- (IBAction) visitWebsite:(id)sender;
- (IBAction) closeButton:(id)sender;

- (void) show;
- (BOOL) quitOnWindowClose;
- (BOOL) remindAboutUpdates;

@end
