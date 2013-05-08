//
//  SNDTrack.h
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDTrack : NSObject

@property (nonatomic) NSURL *url;
@property (nonatomic) NSString *path; // path from url
@property (nonatomic) NSString *filename;
@property (nonatomic) NSNumber *duration;
@property (nonatomic) NSString *formattedDuration;

@property (nonatomic) BOOL validTags;
@property (nonatomic) BOOL validAudioProperties;

@property (nonatomic, readonly) bool isAccessible;

// Tags
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, retain) NSNumber *tracknumber;
@property (nonatomic, retain) NSNumber *year;

// Audio properties
//@property (nonatomic, retain) NSNumber *length;
//@property (nonatomic, retain) NSNumber *sampleRate;
//@property (nonatomic, retain) NSNumber *bitRate;


- (id)initWithURL:(NSURL *)url;


@end
