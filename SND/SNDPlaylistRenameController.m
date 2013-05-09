//
//  SNDPlaylistRenameController.m
//  SND
//
//  Created by Alex Antipov on 5/8/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaylistRenameController.h"

#import "SNDAppDelegate.h"

@implementation SNDPlaylistRenameController

//@synthesize playlistRename = _playlistRename;

//@synthesize stupid_ARC_or_Stupid_Me = _stupid_ARC_or_Stupid_Me;

- (id) init {
    self = [super init];
    if (self) {
        //[self.playlistRenameWindow display];
        //[self showModal];
        //self.stupid_ARC_or_Stupid_Me = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) showModal {
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    
    //[[NSApplication sharedApplication] beginSheet:self.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
    //NSLog(@"aa window: %@", playlistRename);
    //if(!playlistRename)
        //[NSBundle loadNibNamed:@"PlaylistRename" owner:self];
    //NSLog(@"aa window2: %@", playlistRename);
    //[self.stupid_ARC_or_Stupid_Me addObject:playlistRename];
    
    
    //NSLog(@"www: %@", playlistRenameWindow);
    
    
    
    [[NSApplication sharedApplication] beginSheet:appDelegate.playlistRenameWindow modalForWindow:appDelegate.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)(self)];
    
    NSLog(@">hhhmm");
}

- (void) closeSheet {
    NSLog(@">End sheet");
    //NSLog(@"window: %@", playlistRename);
    //if(!playlistRename)
        //[NSBundle loadNibNamed:@"PlaylistRename" owner:self];
    
    
    //self.playlistRename = [self.stupid_ARC_or_Stupid_Me lastObject];
    
    //NSLog(@"window2: %@", playlistRename);
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    [[NSApplication sharedApplication] endSheet:appDelegate.playlistRenameWindow];
    //[playlistRename orderOut:self];
    
    //playlistRename = nil;
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
     NSLog(@"> ko ko ko ");
	[sheet orderOut:self];
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
