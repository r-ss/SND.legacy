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

- (id) init {
    self = [super init];
    if (self) {
        //[self.playlistRenameWindow display];
        //[self showModal];
        //self.stupid_ARC_or_Stupid_Me = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) show {
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    
    //[[NSApplication sharedApplication] beginSheet:self.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
    //NSLog(@"aa window: %@", playlistRename);
    if(!self.playlistRenameWindow)
        //NSLog(@">Loading");
        [NSBundle loadNibNamed:@"PlaylistRename" owner:self];
        //self.playlistRenameWindow = [[NSWindow alloc] initWithWindowNibName:@"mainMenu"];
    //NSLog(@"aa window2: %@", playlistRename);
    //[self.stupid_ARC_or_Stupid_Me addObject:playlistRename];
    
    
    //NSLog(@"window at opening: %@", self.playlistRenameWindow);
    
    
    
    [[NSApplication sharedApplication] beginSheet:self.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
    
    //[[NSApplication sharedApplication] beginSheet:self.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:nil didEndSelector:@selector(sheetDidEnd) contextInfo:nil];
    
    //NSLog(@">hhhmm");
}

- (IBAction) renameButton:(id)sender {
    [[NSApplication sharedApplication] endSheet:self.playlistRenameWindow returnCode:NSOKButton];
}
- (IBAction) cancelButton:(id)sender {
    [[NSApplication sharedApplication] endSheet:self.playlistRenameWindow returnCode:NSCancelButton];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    //NSLog(@"> ko ko ko ");
	[sheet orderOut:self];
    
    NSLog(@"return code: %ld", (long)returnCode);
    NSLog(@"context info: %@", contextInfo);
    
    if (returnCode == NSOKButton) {
        //NSLog(@"field value: %@", self.nameField.stringValue);
    
        SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    
        [appDelegate.sndBox renamePlaylist:self.nameField.stringValue];
    }
    
    
    //[[NSApplication sharedApplication] endSheet:self.playlistRenameWindow];
//    
//	if (returnCode == NSOKButton) {
//		NSString *fullName = [_addIdentityFullName stringValue];
//		
//		if ([fullName length]) {
//			CFErrorRef error;
//			CSIdentityClass class = [_addIdentityClassPopUp indexOfSelectedItem] + 1;
//			CFStringRef posixName = [_generatePosixNameButton state] ? kCSIdentityGeneratePosixName : (CFStringRef)[_addIdentityPosixName stringValue];
//			
//			/* Create a brand new identity */
//			CSIdentityRef identity = CSIdentityCreate(NULL, class, (CFStringRef)fullName, posixName, kCSIdentityFlagNone, CSGetLocalIdentityAuthority());
//			if (class == kCSIdentityClassUser) {
//				/* If this is a user identity, add a password */
//				CSIdentitySetPassword(identity, (CFStringRef)[_addIdentityPassword stringValue]);
//			}
//			
//			/* Commit the new identity to the identity store */
//			if (!CSIdentityCommit(identity, NULL, &error)) {
//				NSLog(@"CSIdentityCommit returned error %@ userInfo %@)", error, [(NSError*)error userInfo] );
//			}
//			[self queryForIdentitiesByName:[_searchText stringValue]];
//		}
//    }
//	
//	[_addIdentityFullName setStringValue:@""];
//	[_addIdentityPosixName setStringValue:@""];
//	[_addIdentityPassword setStringValue:@""];
//	[_addIdentityVerify setStringValue:@""];
//	[_generatePosixNameButton setState:YES];
}

@end
