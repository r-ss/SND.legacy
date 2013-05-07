//
//  SNDPreferencesController.h
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNDPreferencesController : NSWindowController

@property (nonatomic, retain) IBOutlet NSButton *quitOnWindowCloseButton;
- (IBAction) quitOnWindowCloseAction:(id)sender;

@end
