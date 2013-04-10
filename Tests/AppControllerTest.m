//
//  AppControllerTest.m
//  TranscodingMachine
//
//  Created by Cory Powers on 3/31/13.
//  Copyright (c) 2013 UversaInc. All rights reserved.
//

#import "AppControllerTest.h"
#import "AppController.h"
#import "MediaItem.h"

@implementation AppControllerTest
- (void)testFilenameParsing {
	AppController *myAppController = [[AppController alloc] init];
	
	MediaItem *simpleTVShowNameTest = [[MediaItem alloc] init];
	simpleTVShowNameTest.input = @"/tmp/TVShow-S01E02.mkv";
	NSError *error;
	
	[myAppController processFileName:simpleTVShowNameTest error:&error];
	STAssertNil(error, @"Error from processFilename not nil.");
}
@end
