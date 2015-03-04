//
//  SNDPlaylistRenameController.m
//  SND
//
//  Created by Alex Antipov on 5/8/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaylistRenameController.h"
#import "SNDAppDelegate.h"
#import "SNDBox.h"

@implementation SNDPlaylistRenameController

@synthesize playlistRenameWindow = _playlistRenameWindow;
@synthesize nameField = _nameField;
@synthesize sessionForTab = _sessionForTab;

- (id) init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (void) showWithInitialName:(NSString *)initialText forTab:(NSInteger)tab {
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    if(!self.playlistRenameWindow)
        //[NSBundle loadNibNamed:@"PlaylistRename" owner:self];
        [[NSBundle mainBundle] loadNibNamed:@"PlaylistRename" owner:self topLevelObjects:nil];
    self.sessionForTab = [NSNumber numberWithInteger:tab];
    self.nameField.stringValue = initialText;
    [NSApp beginSheet:self.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
}

- (IBAction) renameButton:(id)sender {
    [NSApp endSheet:self.playlistRenameWindow returnCode:NSOKButton];
}
- (IBAction) cancelButton:(id)sender {
    [NSApp endSheet:self.playlistRenameWindow returnCode:NSCancelButton];
}

- (void) sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
    //NSLog(@"return code: %ld", (long)returnCode);
    //NSLog(@"context info: %@", contextInfo);
    if (returnCode == NSOKButton) {
        SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
        [appDelegate.sndBox renamePlaylist:self.sessionForTab.integerValue withName:self.nameField.stringValue];
    }
}

@end
