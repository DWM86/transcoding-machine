// 
//  MediaItem.m
//  TranscodingMachine
//
//  Created by Cory Powers on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MediaItem.h"


@implementation MediaItem 

@dynamic showName;
@dynamic releaseDate;
@dynamic message;
@dynamic output;
@dynamic type;
@dynamic coverArt;
@dynamic episode;
@dynamic season;
@dynamic input;
@dynamic hdVideo;
@dynamic longDescription;
@dynamic summary;
@dynamic network;
@dynamic title;
@dynamic copyright;
@dynamic genre;

@dynamic queueItem;

-(NSString *)shortName{
	NSString *shortName = [[self input] lastPathComponent];
	if ([[self type] intValue] == ItemTypeTV && ![[self showName] isEqualToString:@""]) {
		shortName = [NSString stringWithFormat:@"%@ S%.2dE%.2d - %@", [self showName], [[self season] intValue], [[self episode] intValue], [self title]];
	}else if([[self type] intValue] == ItemTypeMovie && ![[self title] isEqualToString:@""]) {
		shortName = [self title];
	}
	
	return shortName;
}

-(NSString *)episodeId{
	if ([self.type isEqualToNumber:@ItemTypeTV]) {
		return [NSString stringWithFormat:@"%d%.2d", [[self season] intValue], [[self episode] intValue]];
	}
	return [NSString string];
}

- (NSImage *)coverArtImage {
	if (self.coverArt) {
		return [[NSImage alloc] initWithData:self.coverArt];
	}
	
	return nil;
}

+ (NSSet *)keyPathsForValuesAffectingCoverArtImage {
	return [NSSet setWithObject:@"coverArt"];
}
@end
