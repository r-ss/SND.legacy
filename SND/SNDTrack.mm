//
//  SNDTrack.m
//  SND
//
//  Created by Alex Antipov on 4/17/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDTrack.h"

#import "NSNumber+hhmmssFromSeconds.h"

#import "TagLib/TagLib.h"
#include "TagLib/tag_c.h"

@implementation SNDTrack

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
@synthesize tracknumber;
@synthesize year;

@synthesize isAccessible = _isAccessible;


- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
        self.artist = @"n/a";
        self.album = @"n/a";
        self.title = @"n/a";
        [self setPath:self.url.path];
        [self setFilename:[NSString stringWithString:[self.url lastPathComponent]]];

        // Initialisation as per the TagLib example C code
        TagLib_File *file;
        TagLib_Tag *tag;
        // Initialisation as per the TagLib example C code
        // We want UTF8 strings out of TagLib
        taglib_set_strings_unicode(TRUE);
        
        file = taglib_file_new([self.path cStringUsingEncoding:NSUTF8StringEncoding]);
                
        if (file != NULL) {
            tag = taglib_file_tag(file);
            
            if (tag != NULL) {
                // Collect title, artist, album, comment, genre, track and year in turn.
                // Sanity check them for presence, and length                
                self.validTags = YES;
                
                if (taglib_tag_title(tag) != NULL && strlen(taglib_tag_title(tag)) > 0) {
                    self.title = [NSString stringWithCString:taglib_tag_title(tag) encoding:NSUTF8StringEncoding];
                }                
                if (taglib_tag_artist(tag) != NULL && strlen(taglib_tag_artist(tag)) > 0) {
                    self.artist = [NSString stringWithCString:taglib_tag_artist(tag) encoding:NSUTF8StringEncoding];
                }                
                if (taglib_tag_album(tag) != NULL && strlen(taglib_tag_album(tag)) > 0) {
                    self.album = [NSString stringWithCString:taglib_tag_album(tag) encoding:NSUTF8StringEncoding];
                }                
                if (taglib_tag_comment(tag) != NULL && strlen(taglib_tag_comment(tag)) > 0) {
                    self.comment = [NSString stringWithCString:taglib_tag_comment(tag) encoding:NSUTF8StringEncoding];
                }                
                if (taglib_tag_genre(tag) != NULL && strlen(taglib_tag_genre(tag)) > 0) {
                    self.genre = [NSString stringWithCString:taglib_tag_genre(tag) encoding:NSUTF8StringEncoding];
                }               
                // Year and track are uints
                if (taglib_tag_year(tag) > 0) {
                    self.year = [NSNumber numberWithUnsignedInt:taglib_tag_year(tag)];
                }                
                if (taglib_tag_track(tag) > 0) {
                    self.tracknumber = [NSNumber numberWithUnsignedInt:taglib_tag_track(tag)];
                }
            } else {
                self.validTags = NO;
            }
            
            const TagLib_AudioProperties *properties = taglib_file_audioproperties(file);
            
            if (properties != NULL) {                
                self.validAudioProperties = YES;                
                if (taglib_audioproperties_length(properties) > 0) {
                    self.duration = [NSNumber numberWithInt:taglib_audioproperties_length(properties)];
                }
            } else {
                self.validAudioProperties = NO;
            }
            
            // Free up our used memory so far
            taglib_tag_free_strings();
            taglib_file_free(file);
        };        
        
        //self.formattedDuration = [self.duration hhmmssFromSeconds:self.duration];
        self.formattedDuration = [self.duration hhmmssFromSeconds:self.duration];
    };
    return self;
}

// overriding synthesized setter for url
- (void) setUrl:(NSURL *)url {
    _url = url;
   [self setPath:url.path];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"SNDTrack: %@ - %@", self.artist, self.title];
}

// Overriding isAccessible getter
// lowercase 'bool' here because c++
- (bool) isAccessible {    
    if([[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        return YES;
    } else {        
        return NO;
    }    
}


@end
