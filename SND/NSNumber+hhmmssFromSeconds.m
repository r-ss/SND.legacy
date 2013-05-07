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
	NSString		*result			= nil;
	unsigned		value;
	unsigned		days			= 0;
	unsigned		hours			= 0;
	unsigned		minutes			= 0;
	unsigned		seconds			= 0;
    
	value		= (unsigned)([s doubleValue]);
    
	seconds		= value % 60;
	minutes		= value / 60;
	
	while(60 <= minutes) {
		minutes -= 60;
		++hours;
	}
	
	while(24 <= hours) {
		hours -= 24;
		++days;
	}
    
	if(0 < days) {
		result = [NSString stringWithFormat:@"%u:%.2u:%.2u:%.2u", days, hours, minutes, seconds];
	}
	else if(0 < hours) {
		result = [NSString stringWithFormat:@"%.2u:%.2u:%.2u", hours, minutes, seconds];
	}
	else if(0 < minutes) {
		result = [NSString stringWithFormat:@"%.2u:%.2u", minutes, seconds];
	}
	else {
		result = [NSString stringWithFormat:@"00:%.2u", seconds];
	}
	
	return result;
}

@end