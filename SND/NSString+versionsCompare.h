//
//  NSString+versionsCompare.h
//  SND
//
//  Created by Alex Antipov on 5/12/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (versionsCompare)

- (BOOL) isVersion:(NSString *)a higherThan:(NSString *)b;

@end