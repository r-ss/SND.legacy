//
//  SNDUpdateReminderController.h
//  SND
//
//  Created by Alex Antipov on 5/11/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDUpdateReminderController : NSObject

@property (assign) IBOutlet NSWindow *updateReminderWindow;
@property (assign) IBOutlet NSTextField *updateInfoField;

@property (nonatomic, retain) IBOutlet NSButton *remindAboutUpdateCheck;
- (IBAction) remindAboutUpdateAction:(id)sender;

- (IBAction) downloadButton:(id)sender;
- (IBAction) cancelButton:(id)sender;

- (void) show;

@end
