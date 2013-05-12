//
//  NSString+versionsCompare.m
//  SND
//
//  Created by Alex Antipov on 5/12/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "NSString+versionsCompare.h"

@implementation NSString (versionsCompare)

- (BOOL) isVersion:(NSString *)a higherThan:(NSString *)b {
    // LOWER
    if ([a compare:b options:NSNumericSearch] == NSOrderedAscending) {
        //NSLog(@"%@ < %@", thisVersionString, thatVersionString);
        return NO;
    }
    // EQUAL
    if ([a compare:b options:NSNumericSearch] == NSOrderedSame) {
        //NSLog(@"%@ == %@", thisVersionString, thatVersionString);
        return NO;
    }
    // HIGHER
    return YES;
}

@end
