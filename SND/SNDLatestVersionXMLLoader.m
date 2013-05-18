//
//  SNDInfoXMLLoader.m
//  SND
//
//  Created by Alex Antipov on 5/11/13.
//  Copyright (c) 2013 Alex Antipov. All rights reserved.
//

#import "SNDLatestVersionXMLLoader.h"
#import "SNDAppDelegate.h"
#import "NSString+versionsCompare.h"

// private part
@interface SNDLatestVersionXMLLoader ()
@property (nonatomic) NSMutableData *xmlData;
@property (nonatomic) NSString *currentElement;
@end


@implementation SNDLatestVersionXMLLoader

@synthesize xmlURL = _xmlURL;
@synthesize xmlData = _xmlData;

@synthesize latestVersion = _latestVersion;
@synthesize latestStatus = _latestStatus;
@synthesize latestURL = _latestURL;

- (id) initAndLoad {
    self = [super init];
    if(self){
        self.xmlURL = [[NSURL alloc] initWithString:@"http://snd-app.com/latestversion.xml"];
        
        _latestVersion = [[NSMutableString alloc] initWithCapacity:50];
        _latestStatus = [[NSMutableString alloc] initWithCapacity:50];
        _latestURL = [[NSMutableString alloc] initWithCapacity:100];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:self.xmlURL];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection start];
    }
    return self;
}

// Overriding latestVersion getter
- (NSString *) latestVersion {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,."] invertedSet];
    return [[_latestVersion componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

// Overriding latestStatus getter
- (NSString *) latestStatus {
    return [self filterXMLString:_latestStatus];
}

// Overriding latestURL getter
- (NSString *) latestURL {
    return [self filterXMLString:_latestURL];
}


- (NSString *) filterXMLString:(NSString *)unfilteredString {
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.,.<>-_:;/&$#@!^*(){}[]'+"] invertedSet];
    return [[unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

- (BOOL) updateIsAvailable {
    if(self.latestVersion == nil)
        return NO;
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    NSLog(@"versions compare: latest:%@, current:%@", self.latestVersion, appDelegate.currentAppVersion);
    
    NSString *a = self.latestVersion;
    NSString *b = appDelegate.currentAppVersion;
    
    if([a isVersion:a higherThan:b]){
        //NSLog(@"YES");
        return YES;
    } else {
        //NSLog(@"NO");
        return NO;
    }
}

- (NSURL *) latestVersionDownloadURL {
    if(self.latestURL){
        return [NSURL URLWithString:self.latestURL];
    } else {
        return nil;
    }
}

-(void)parseXML{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.xmlData];
    [xmlParser setDelegate:self];
    BOOL success = [xmlParser parse];
    if(success){
        NSLog(@"XML loaded and parsed");
    
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"SND.Notification.LatestVersionXMLLoaded" object:self];
    } else {
        NSLog(@"XML parsing error");
    }
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {

    //NSLog(@"parser didStartElement");
    if ([elementName isEqualToString:@"latestversion"]) {
        self.currentElement = @"latestversion";
    }
    else if ([elementName isEqualToString:@"lateststatus"]) {
        self.currentElement = @"lateststatus";
    }
    else if ([elementName isEqualToString:@"latesturl"]) {
        self.currentElement = @"latesturl";
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
    else if([self.currentElement isEqualToString:@"latesturl"]){
        [_latestURL appendString:string];
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
