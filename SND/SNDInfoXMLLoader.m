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
        self.xmlURL = [[NSURL alloc] initWithString:@"http://snd-app.com/app.xml"];
        
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
    NSLog(@">> SELF LATEST: %@", self.latestVersion);
    if(self.latestVersion == nil)
        return NO;
        
    SNDAppDelegate *appDelegate = NSApplication.sharedApplication.delegate;
    if ([self.latestVersion compare:appDelegate.currentAppVersion options:NSNumericSearch] == NSOrderedDescending) {
        NSLog(@">> UPDATE");
        return YES;
    } else {
        
        NSLog(@">> NOOO UPDATE, a: %@, b: %@", self.latestVersion, appDelegate.currentAppVersion);
        return NO;
    }
}

-(void)parseXML{
    
    //NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *fullName = [NSString stringWithFormat:@"xmlfile.xml"];
    
    //NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@",docDir,fullName];
    //NSData *myData = [NSData dataWithContentsOfFile:fullFilePath];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:self.xmlData];
    
    [xmlParser setDelegate:self];
    
    //Start parsing the XML file.
    BOOL success = [xmlParser parse];
    
    if(success)
        NSLog(@"No Errors");
    else
        NSLog(@"Error Error Error!!!");
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
    
    
    
    //NSLog(@"parser foundCharacters");
    if([self.currentElement isEqualToString:@"latestversion"]){
        //NSLog(@"found: %@", string);
        [_latestVersion appendString:string];
    }
    else if([self.currentElement isEqualToString:@"lateststatus"]){
        //NSLog(@"found status: %@", string);
        [_latestStatus appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"parser didEndElement");
    
    //NSLog(@"latest version: %@", self.latestVersion);
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"> didReceiveResponse");
    // create
    //[[NSFileManager defaultManager] createFileAtPath:strFilePath contents:nil attributes:nil];
    //file = [[NSFileHandle fileHandleForUpdatingAtPath:strFilePath] retain];// read more about file handle
    //if (file)   {
    //    [file seekToEndOfFile];
    //}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"> didReceiveData");
    if (self.xmlData)
        [self.xmlData appendData:data];
    else
        self.xmlData = [[NSMutableData alloc] initWithData:data];
    //write each data received
    //if( receivedata != nil){
    //    if (file)  {
    //        [file seekToEndOfFile];
    //    }
    //    [file writeData:receivedata];
    //}
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    NSLog(@"> connectionDidFinishLoading");
    [self parseXML];
    //NSLog(@"data: %@", self.xmlData);
    //close file after finish getting data;
    //[file closeFile];
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"> didFailWithError");
    //do something when downloading failed
}



@end
