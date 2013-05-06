//
//  SNDPreferencesController.m
//  SND
//
//  Created by Alex Antipov on 5/6/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDPreferencesController.h"

@interface SNDPreferencesController ()

@end

@implementation SNDPreferencesController

@synthesize quitOnWindowCloseButton = _quitOnWindowCloseButton;

- (id)init
{
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
    }    
    return self;
}

- (void) awakeFromNib {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL quit = [userDefaults boolForKey:@"SNDPreferencesQuitOnWindowClose"];
    quit ? NSLog(@">> YES") : NSLog(@">> NO");
    [self.quitOnWindowCloseButton setState:quit];
}

- (void)windowDidLoad {    
    [super windowDidLoad];
}

- (IBAction) quitOnWindowCloseAction:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:[self.quitOnWindowCloseButton state] forKey:@"SNDPreferencesQuitOnWindowClose"];
    [userDefaults synchronize];
}

@end
