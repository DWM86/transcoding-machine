//
//  MetadataProvider.m
//  TranscodingMachine
//
//  Created by Cory Powers on 1/15/10.
//  Copyright 2010 UversaInc. All rights reserved.
//

#import "MetadataProvider.h"


@implementation MetadataProvider

- (id)init{
	return nil;
}

- (id)initWithAnItem:(MediaItem *)anItem{
    self = [super init];
    if( !self ){
        return nil;
    }
	
	self.item = anItem;
	return self;
}

- (void)applyMetadata{
}

- (NSString *)stringFromNode: (NSXMLNode *)node usingXPath: (NSString *)xpath{
	NSArray *nodes;
	NSError *error;
	nodes = [node nodesForXPath:xpath error:&error];
	if(!nodes || [nodes count] == 0){
		NSLog(@"Error extracting string from xpath %@: %@", xpath, error);
		return [NSString string];
	}
	return [nodes[0] stringValue];
	
}

- (void)fireDidFinish{
	if (self.delegate != nil) {
		[self.delegate metadataProviderDidFinish:self];
	}
}

- (void)fireHadError: (NSError *)anError{
	if (self.delegate != nil) {
		[self.delegate metadataProvider:self hadError:anError];
	}	
}

@end
