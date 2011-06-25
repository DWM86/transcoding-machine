//
//  TheMovieDBProvider.m
//  TranscodingMachine
//
//  Created by Cory Powers on 3/29/10.
//  Copyright 2010 UversaInc. All rights reserved.
//

#import "TheMovieDBProvider.h"


@interface TheMovieDBProvider (hidden) 
- (BOOL)searchMovie;
- (BOOL)getMovieInfo;
@end


@implementation TheMovieDBProvider

- (void)applyMetadata{
	// We only handle Movies
	if ([[item type] intValue] != ItemTypeMovie) {
		return;
	}
	
	if ([item title] == nil) {
		return;
	}
	
	if ([self searchMovie] == NO){
		return;
	}
	
	if ([self getMovieInfo] == NO){
		return;
	}
		
}

- (void)dealloc{
	[super dealloc];
}

@end

@implementation TheMovieDBProvider (hidden)

- (BOOL)searchMovie{
	NSXMLDocument *doc;
	NSArray *movies;
	NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"tmdApiKey"];
	NSString *urlString = [NSString stringWithFormat:@"http://api.themoviedb.org/2.1/Movie.search/en/xml/%@/%@", apiKey, [[item title] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSLog(@"Searching for movie with url %@", urlString);
	NSURL *url = [NSURL URLWithString:urlString];
	
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url 
												cachePolicy:NSURLRequestReturnCacheDataElseLoad
											timeoutInterval:30];
	
	NSData *urlData;
	NSURLResponse *response;
	NSError *error;
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	if(!urlData){
		NSLog(@"Error searching for movie: %@", error);
		return NO;
	}
	
	doc = [[NSXMLDocument alloc] initWithData:urlData options:0 error:&error];
	NSLog(@"Result Document\n%@", doc);
	if(!doc){
		NSLog(@"Error processing xml: %@", error);
		return NO;
	}
	
	movies = [[doc nodesForXPath:@"OpenSearchDescription/movies/movie" error:&error] retain];
	if(!movies){
		NSLog(@"Error extracting movies from result: %@", error);
		return NO;
	}
	
	for (NSXMLNode *node in movies) {
		// Assume first is best for now
		NSString *title = [self stringFromNode:doc usingXPath:@"OpenSearchDescription/movies/movie[1]/name"];
		item.showName = title;
		item.title = title;

		item.releaseDate = [self stringFromNode:doc usingXPath:@"OpenSearchDescription/movies/movie[1]/released"];
		
		NSString *summary = [self stringFromNode:doc usingXPath:@"OpenSearchDescription/movies/movie[1]/overview"];
		item.summary = summary;
		item.longDescription = summary;
		
		NSArray *images = [[doc nodesForXPath:@"OpenSearchDescription/movies/movie[1]/images/image" error:&error] retain];
		if(!images || [images count] == 0){
			NSLog(@"Could not find any images for movie");
		}
		NSString *imageUrlString;
		for(NSXMLNode *imageNode in images){
			NSString *imageType;
			NSString *imageSize;
			NSString *tempUrl;
			NSString *nodeString = [imageNode XMLString];

			if ([nodeString getCapturesWithRegexAndReferences:@"type=\"([a-zA-Z0-9]+)\".+url=\"([^\"]+)\".+size=\"([a-zA-Z0-9]+)\"", @"${1}", &imageType, @"${2}", &tempUrl, @"${3}", &imageSize, nil]) {
				NSLog(@"Found image size %@ with a type of %@", imageSize, imageType);
				if([imageType isEqualToString:@"poster"]){
					if([imageSize isEqualToString:@"original"]){
						imageUrlString = tempUrl;
						break;
					}else if([imageType isEqualToString:@"cover"] && imageUrlString == nil){
						imageUrlString = tempUrl;
					}
				}
			}
		}
		
		NSLog(@"Using Image URL: %@", imageUrlString);
		if (imageUrlString != nil) {
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

		return YES;
	}
	
	return NO;
}

- (BOOL)getMovieInfo{
	return YES;
}

@end
