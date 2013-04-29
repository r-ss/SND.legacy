//
//  SNDBox.h
//  SND
//
//  Created by Alex Antipov on 4/29/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDAppDelegate.h"
#import "SNDWindow.h"

@class SNDPlayer;

@interface SNDBox : NSObject <WindowDropDelegate, DockDropDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView *playlistTableView;
}

@property (nonatomic, assign) IBOutlet SNDWindow *sndWindow;
@property (nonatomic, assign) IBOutlet SNDAppDelegate *sndAppDelegate;
@property (nonatomic, assign) IBOutlet SNDPlayer *sndPlayer;

@end
