//
//  SNDTrack.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SNDTrack : NSObject



//@property (nonatomic) BOOL isCurrent;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSString *path; // path from url
@property (nonatomic) NSString *filename;
@property (nonatomic) NSNumber *duration;
@property (nonatomic) NSString *formattedDuration;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *title;

- (id)initWithURL:(NSURL *)url;

@end
