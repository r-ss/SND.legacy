//
//  SNDPlaylistRenameController.h
//  SND
//
//  Created by Alex Antipov on 5/8/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNDPlaylistRenameController : NSObject

@property (assign) IBOutlet NSWindow *playlistRenameWindow;

@property (assign) IBOutlet NSTextField *nameField;


- (void) show;

- (IBAction) renameButton:(id)sender;
- (IBAction) cancelButton:(id)sender;

@end
