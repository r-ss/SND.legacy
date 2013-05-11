//
//  SNDInfoXMLLoader.m
//  SND
//
//  Created by Alex Antipov on 5/11/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDInfoXMLLoader.h"
#import "SNDAppDelegate.h"

// private part
@interface SNDInfoXMLLoader ()
@property (nonatomic) NSMutableData *xmlData;
@property (nonatomic) NSString *currentElement;
@end


@implementation SNDInfoXMLLoader

@synthesize xmlURL = _xmlURL;
@synthesize xmlData = _xmlData;

@synthesize latestVersion = _latestVersion;
@synthesize latestStatus = _latestStatus;

- (id) initAndLoad {
    self = [super init];
    if(self){
        self.xmlURL = [[NSURL alloc] initWithString:@"http://snd-app.com/latestversion.xml"];
        
        _latestVersion = [[NSMutableString alloc] initWithCapacity:50];
        _latestStatus = [[NSMutableString alloc] initWithCapacity:50];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:self.xmlURL];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection start];
    }
    return self;
}

- (BOOL) updateIsAvailable {
    if(self.latestVersion == nil)
        return NO;        
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;    
    if ([self.latestVersion compare:appDelegate.currentAppVersion options:NSNumericSearch] != NSOrderedAscending) {
        return NO;
    } else {
        return YES;
    }
}

- (NSString *) updateIsAvailableText {
    if(self.latestVersion == nil)
        return @"";
    if ([self updateIsAvailable]) {
        return @"Update is available";
    } else {
        return @"You are using the latest version";
    }
}

-(void)parseXML{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.xmlData];
    BOOL success = [xmlParser parse];
    if(success)
        NSLog(@"XML loaded and parsed");
    else
        NSLog(@"XML parsing error");
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

    //NSLog(@"parser didStartElement");
    if ([elementName isEqualToString:@"latestversion"]) {
        self.currentElement = @"latestversion";
    }
    else if ([elementName isEqualToString:@"lateststatus"]) {
        self.currentElement = @"lateststatus";
    }
    else {
        self.currentElement = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if([self.currentElement isEqualToString:@"latestversion"]){
        [_latestVersion appendString:string];
    }
    else if([self.currentElement isEqualToString:@"lateststatus"]){
        [_latestStatus appendString:string];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"> didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"> didReceiveData");
    if (self.xmlData)
        [self.xmlData appendData:data];
    else
        self.xmlData = [[NSMutableData alloc] initWithData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //NSLog(@"> connectionDidFinishLoading");
    [self parseXML];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"> connection:didFailWithError:");
}



@end
