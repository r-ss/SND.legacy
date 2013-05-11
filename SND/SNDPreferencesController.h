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

@property (nonatomic, retain) IBOutlet NSButton *quitOnWindowCloseButton;
@property (nonatomic, retain) IBOutlet NSTextField *totalPlaybackTimeField;

@property (nonatomic, retain) IBOutlet NSTextField *appUpdateField;


@property (nonatomic) SNDAppDelegate *appDelegate;
@property (nonatomic, strong) NSTimer *playbackCounterTimer;

- (IBAction) quitOnWindowCloseAction:(id)sender;

- (void) setupFieldsDefaults;
- (void) setup;

- (BOOL) quitOnWindowClose;

@end
