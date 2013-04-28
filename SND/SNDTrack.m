//
//  SNDTrack.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDTrack.h"

@implementation SNDTrack


@synthesize artist = _artist;
@synthesize title = _title;
@synthesize url = _url;
@synthesize path = _path;
@synthesize filename = _filename;
@synthesize duration = _duration;
@synthesize formattedDuration = _formattedDuration;

- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        self.artist = @"n/a";
        self.title = @"n/a";
        [self setPath:self.url.path];
        [self setFilename:[NSString stringWithString:[self.url lastPathComponent]]];
        [self extractMetadata];
        [self getTrackDuration];
        self.formattedDuration = [self hhmmssFromSeconds:self.duration.integerValue];
    };
    return self;                            
}

// overriding synthesized setter for url
- (void) setUrl:(NSURL *)url {
    _url = url;
   [self setPath:url.path];
}

- (void) extractMetadata {
    AVAsset *assest;
    assest = [AVURLAsset URLAssetWithURL:self.url options:nil];
    for (NSString *format in [assest availableMetadataFormats]){
        for (AVMetadataItem *item in [assest metadataForFormat:format]) {
            if ([[item commonKey] isEqualToString:@"title"]) {
                self.title = (NSString *)[item value];
            }
            if ([[item commonKey] isEqualToString:@"artist"]) {
                self.artist = (NSString *)[item value];
            }
            //if ([[item commonKey] isEqualToString:@"albumName"]) {
                // _albumName = (NSString *)[item value];
            //}
        }
    }
}

- (NSString *)hhmmssFromSeconds:(NSInteger)s {
    NSInteger seconds = s % 60;
    NSInteger minutes = (s / 60) % 60;
    NSInteger hours = (s / 3600);
    if (hours > 0){
        return [NSString stringWithFormat:@"%li:%02li:%02li", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];
    }
}

-(void)getTrackDuration {
    NSError *err;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:&err];
    if (!err) {
        if (audioPlayer){
            self.duration = [NSNumber numberWithFloat:audioPlayer.duration];
            //NSLog(@"dur %ld", self.duration.longValue);
        }
    }else{
        //NSLog(@"can't get duration");
    }
}

//- (NSString*)description
//{
//    return [NSString stringWithFormat:@"SNDTrack: %@ - %@", self.artist, self.title];
//}


@end
