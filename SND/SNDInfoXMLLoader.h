//
//  SNDInfoXMLLoader.h
//  SND
//
//  Created by Alex Antipov on 5/11/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDInfoXMLLoader : NSObject <NSXMLParserDelegate>

@property (nonatomic) NSURL *xmlURL;

@property (nonatomic, strong, readonly) NSMutableString *latestVersion;
@property (nonatomic, strong, readonly) NSMutableString *latestStatus;

- (id) initAndLoad;

- (BOOL) updateIsAvailable;


@end
