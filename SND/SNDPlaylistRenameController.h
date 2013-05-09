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

@property (strong) NSNumber *sessionForTab;

- (void) showWithInitialName:(NSString *)initialText forTab:(NSInteger)tab;

- (IBAction) renameButton:(id)sender;
- (IBAction) cancelButton:(id)sender;

@end
