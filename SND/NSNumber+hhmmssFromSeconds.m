//
//  NSNumber+hhmmssFromSeconds.m
//  SND
//
//  Created by Alex Antipov on 4/30/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "NSNumber+hhmmssFromSeconds.h"

@implementation NSNumber (hhmmssFromSeconds)

- (NSString *)hhmmssFromSeconds:(NSNumber *)s {
    NSInteger seconds = s.integerValue % 60;
    NSInteger minutes = (s.integerValue / 60) % 60;
    NSInteger hours = (s.integerValue / 3600);
    if (hours > 0){
        return [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

@end