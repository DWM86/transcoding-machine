//
//  TheTVDBProvider.m
//  TranscodingMachine
//
//  Created by Cory Powers on 1/15/10.
//  Copyright 2010 UversaInc. All rights reserved.
//

#import "TheTVDBProvider.h"


@implementation TheTVDBProvider
@synthesize currentState;
@synthesize currentResponse;

- (id)initWithAnItem:(MediaItem *)anItem{
    self = [super initWithAnItem:anItem];
    if( !self ){
        return nil;
    }
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	NSLog(@"currentResponse has %lu bytes of data", [self.currentResponse length]);
	self.currentState = 0;
	return self;
}

- (void)applyMetadata{
	// We only handle TV shows
	if ([[item type] intValue] != ItemTypeTV ) {
		return;
	}
	
	[self getMirrorUrl];
}

- (void)dealloc{
	if(mirrorUrl){
		[mirrorUrl release];
	}
	[super dealloc];
}

- (void)getMirrorUrl{
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"ttdApiKey"];
	NSString *urlString = [NSString stringWithFormat:@"http://www.thetvdb.com/api/%@/mirrors.xml", apiKey];
	NSLog(@"Downloading mirrors from %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	self.currentState = TTDBStateMirror;
	[NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void)processMirrorUrlData: (NSString *) responseString{
	NSError *error;
	NSLog(@"Current response\n%@", responseString);
	
	NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData: [responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
	NSLog(@"Mirror Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
		return;
	}
	
	NSArray *mirrors = [[doc nodesForXPath:@"Mirrors/Mirror" error:&error] retain];
	if(!mirrors){
		NSLog(@"Error extracting mirrors: %@", error);
		return;
	}
	
	for (NSXMLNode *node in mirrors) {
		NSArray *mpNodes = [node nodesForXPath:@"mirrorpath" error:&error];
		if(!mpNodes){
			NSLog(@"Error extracting mirrorpath: %@", error);
			return;
		}
		
		if([mpNodes count] > 0){
			mirrorUrl = [[[mpNodes objectAtIndex:0] stringValue] retain];
			NSLog(@"Using mirror url: %@", mirrorUrl);
			[self getLastUpdateTime];
			return;
		}
	}
	
}

- (void)getLastUpdateTime{
	NSURL *url = [NSURL URLWithString:@"http://www.thetvdb.com/api/Updates.php?type=none"];
	

	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	self.currentState = TTDBStateUpdateTime;
	[NSURLConnection connectionWithRequest:urlRequest delegate:self];

}

- (void)processLastUpdateTime: (NSString *) responseString{
	NSXMLDocument *doc;
	NSArray *items;
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	NSError *error;
	doc = [[NSXMLDocument alloc] initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
	NSLog(@"Last Update Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
	}
	
	items = [[doc nodesForXPath:@"Items" error:&error] retain];
	if(!items){
		NSLog(@"Error extracting items: %@", error);
	}
	
	for (NSXMLNode *node in items) {
		NSArray *timeNodes = [node nodesForXPath:@"Time" error:&error];
		if(!timeNodes){
			NSLog(@"Error extracting Time: %@", error);
		}
		
		if([timeNodes count] > 0){
			lastUpdateTime = [[formatter numberFromString:[[timeNodes objectAtIndex:0] stringValue]] intValue];
			NSLog(@"Using last update time: %d", lastUpdateTime);
			[self getSeriesId];
		}
		
	}
	
}

- (void)getSeriesId{
	NSString *urlString = [NSString stringWithFormat:@"http://www.thetvdb.com/api/GetSeries.php?seriesname=%@", [[item showName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"Downloading series from %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	self.currentState = TTDBStateSeriesId;
	[NSURLConnection connectionWithRequest:urlRequest delegate:self];
	
}

- (void)processSeriesId: (NSString *) responseString{
	NSXMLDocument *doc;
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	NSArray *series;
	NSError *error;

	doc = [[NSXMLDocument alloc] initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
	NSLog(@"Series Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
		return;
	}
	
	series = [[doc nodesForXPath:@"Data/Series" error:&error] retain];
	if(!series || [series count] == 0){
		NSLog(@"Error extracting series: %@", error);
		return;
	}

	NSLog(@"Recieved %d series ids", [series count]);
	for (NSXMLNode *node in series) {
		NSArray *seriesIdNodes = [node nodesForXPath:@"seriesid" error:&error];
		if(!seriesIdNodes){
			NSLog(@"Error extracting seriesid: %@", error);
			return;
		}
		
		if([seriesIdNodes count] > 0){
			seriesId = [[formatter numberFromString:[[seriesIdNodes objectAtIndex:0] stringValue]] intValue];
			NSLog(@"Using series id: %d", seriesId);
			[self getSeriesInfo];
			return;
		}
		
	}
	
}

- (void)getSeriesInfo{
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"ttdApiKey"];
	NSString *urlString = [NSString stringWithFormat:@"http://www.thetvdb.com/api/%@/series/%d/en.xml", apiKey, seriesId];
	NSLog(@"Downloading series info from %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	self.currentState = TTDBStateSeriesInfo;
	[NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void)processSeriesInfo: (NSString *) responseString{
	NSXMLDocument *doc;
	NSError *error;
	doc = [[NSXMLDocument alloc] initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
	NSLog(@"Series Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
		return;
	}
	
	[item setShowName: [self stringFromNode:doc usingXPath:@"Data/Series/SeriesName"]];
	
	[item setSummary: [self stringFromNode:doc usingXPath:@"Data/Series/Overview"]];
	
	[item setNetwork: [self stringFromNode:doc usingXPath:@"Data/Series/Network"]];
	
	[self getEpisodeInfo];
}

- (void)getEpisodeInfo{
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"ttdApiKey"];
	NSString *urlString = [NSString stringWithFormat:@"http://www.thetvdb.com/api/%@/series/%d/default/%d/%d/en.xml", apiKey, seriesId, [[item season] intValue], [[item episode] intValue]];
	NSLog(@"Downloading episode info from %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	self.currentState = TTDBStateEpisodeInfo;
	[NSURLConnection connectionWithRequest:urlRequest delegate:self];
}

- (void)processEpisodeInfo: (NSString *) responseString{
	NSXMLDocument *doc;
	NSError *error;

	doc = [[NSXMLDocument alloc] initWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
	NSLog(@"Episode Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
		return;
	}
	
	[item setLongDescription: [self stringFromNode:doc usingXPath:@"Data/Episode/Overview"]];
	
	[item setTitle: [self stringFromNode:doc usingXPath:@"Data/Episode/EpisodeName"]];
	
	[item setReleaseDate: [self stringFromNode:doc usingXPath:@"Data/Episode/FirstAired"]];
	
	// Download image
	NSString *imageUrl = [self stringFromNode:doc usingXPath:@"Data/Episode/filename"];
	if (imageUrl != nil && ![imageUrl isEqual:[NSString string]]) {
		NSString *imageUrlString = [NSString stringWithFormat:@"http://www.thetvdb.com/banners/%@", imageUrl];
		NSLog(@"Downloading episode image from %@", imageUrlString);
		NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
		
		NSURLRequest *imageUrlRequest = [NSURLRequest requestWithURL:imageUrl 
														 cachePolicy:NSURLRequestReturnCacheDataElseLoad
													 timeoutInterval:30];
		NSData *imageData;
		NSURLResponse *response;
		imageData = [NSURLConnection sendSynchronousRequest:imageUrlRequest returningResponse:&response error:&error];
		if (imageData) {
			[item setCoverArt:imageData];
		}
	}
	
	[self fireDidFinish];
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	if (data == nil) {
		NSLog(@"data is nil");
		return;
	}
	NSString *dataString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	NSLog(@"Got Data %d bytes of data", [data length]);
	NSLog(@"Data String:\n%@", dataString);
	if (self.currentResponse == nil) {
		NSLog(@"Current response is nil!");
	}
	[self.currentResponse appendString:dataString];
	NSLog(@"currentResponse has %d bytes of data", [self.currentResponse length]);
	NSLog(@"After copy:\n%@", self.currentResponse);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	NSLog(@"currentResponse has %d bytes of data", [self.currentResponse length]);
	NSLog(@"Current Response:\n%@", self.currentResponse);
	if (self.currentState == TTDBStateMirror) {
		[self processMirrorUrlData: self.currentResponse];
	}else if (self.currentState == TTDBStateUpdateTime) {
		[self processLastUpdateTime: self.currentResponse];
	}else if (self.currentState == TTDBStateSeriesId) {
		[self processSeriesId: self.currentResponse];
	}else if (self.currentState == TTDBStateSeriesInfo) {
		[self processSeriesInfo: self.currentResponse];
	}else if (self.currentState == TTDBStateEpisodeInfo) {
		[self processEpisodeInfo: self.currentResponse];
	}
								
	self.currentResponse = [NSMutableString stringWithCapacity:100];
	
}
#pragma mark -

@end
