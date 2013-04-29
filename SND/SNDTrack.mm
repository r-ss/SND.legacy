//
//  SNDTrack.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDTrack.h"

#import "TagLib/TagLib.h"
#include "TagLib/tag_c.h"

//#import "TagLib.h"
//#include "tag_c.h"

@implementation SNDTrack

//@synthesize artist = _artist;
//@synthesize title = _title;
@synthesize url = _url;
@synthesize path = _path;
@synthesize filename = _filename;
@synthesize duration = _duration;
@synthesize formattedDuration = _formattedDuration;

@synthesize validTags, validAudioProperties;

@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize comment;
@synthesize genre;
@synthesize track;
@synthesize year;


- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        self.artist = @"n/a";
        self.title = @"n/a";
        [self setPath:self.url.path];
        [self setFilename:[NSString stringWithString:[self.url lastPathComponent]]];
        //[self extractMetadata];
        [self getTrackDuration];
        self.formattedDuration = [self hhmmssFromSeconds:self.duration.integerValue];
        
        
        
        // Initialisation as per the TagLib example C code
        TagLib_File *file;
        TagLib_Tag *tag;
        // Initialisation as per the TagLib example C code
        // We want UTF8 strings out of TagLib
        taglib_set_strings_unicode(TRUE);
        
        file = taglib_file_new([self.path cStringUsingEncoding:NSUTF8StringEncoding]);
        
        //self.path = filePath;
        
        if (file != NULL) {
            tag = taglib_file_tag(file);
            
            if (tag != NULL) {
                // Collect title, artist, album, comment, genre, track and year in turn.
                // Sanity check them for presence, and length
                
                self.validTags = YES;
                
                if (taglib_tag_title(tag) != NULL &&
                    strlen(taglib_tag_title(tag)) > 0) {
                    self.title = [NSString stringWithCString:taglib_tag_title(tag)
                                                    encoding:NSUTF8StringEncoding];
                }
                
                if (taglib_tag_artist(tag) != NULL &&
                    strlen(taglib_tag_artist(tag)) > 0) {
                    self.artist = [NSString stringWithCString:taglib_tag_artist(tag)
                                                     encoding:NSUTF8StringEncoding];
                }
                
                if (taglib_tag_album(tag) != NULL &&
                    strlen(taglib_tag_album(tag)) > 0) {
                    self.album = [NSString stringWithCString:taglib_tag_album(tag)
                                                    encoding:NSUTF8StringEncoding];
                }
                
                if (taglib_tag_comment(tag) != NULL &&
                    strlen(taglib_tag_comment(tag)) > 0) {
                    self.comment = [NSString stringWithCString:taglib_tag_comment(tag)
                                                      encoding:NSUTF8StringEncoding];
                }
                
                if (taglib_tag_genre(tag) != NULL &&
                    strlen(taglib_tag_genre(tag)) > 0) {
                    self.genre = [NSString stringWithCString:taglib_tag_genre(tag)
                                                    encoding:NSUTF8StringEncoding];
                }
                
                // Year and track are uints
                if (taglib_tag_year(tag) > 0) {
                    self.year = [NSNumber numberWithUnsignedInt:taglib_tag_year(tag)];
                }
                
                if (taglib_tag_track(tag) > 0) {
                    self.track = [NSNumber numberWithUnsignedInt:taglib_tag_track(tag)];
                }
            } else {
                self.validTags = NO;
            }
            
            const TagLib_AudioProperties *properties = taglib_file_audioproperties(file);
            
            if (properties != NULL) {
                
                self.validAudioProperties = YES;
                
                if (taglib_audioproperties_length(properties) > 0) {
                    self.length = [NSNumber numberWithInt:taglib_audioproperties_length(properties)];
                }
            } else {
                self.validAudioProperties = NO;
            }
            
            // Free up our used memory so far
            taglib_tag_free_strings();
            taglib_file_free(file);
        };

        
    };
    return self;                            
}

// overriding synthesized setter for url
- (void) setUrl:(NSURL *)url {
    _url = url;
   [self setPath:url.path];
}

/*- (void) extractMetadata {
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
}*/

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
