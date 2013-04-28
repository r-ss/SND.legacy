//
//  SNDPlaylistView.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPlaylistView.h"

@implementation SNDPlaylistView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.        
    }    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void) keyDown:(NSEvent *)theEvent {
    //NSLog(@"%hu", theEvent.keyCode);
    // delete (117) or backspace (51)
    if (theEvent.keyCode == 117 || theEvent.keyCode == 51) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"SND.Notification.PlaylistDeleteKeyPressed" object:self];
    }
    /*if (theEvent.keyCode == 43 || theEvent.keyCode == 116 || theEvent.keyCode == 123) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"SND.Notification.PlaylistPreviousKeyPressed" object:self];
    }
    if (theEvent.keyCode == 47 || theEvent.keyCode == 121 || theEvent.keyCode == 124) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"SND.Notification.PlaylistNextKeyPressed" object:self];
    }*/
}

@end
