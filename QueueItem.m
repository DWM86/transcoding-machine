// 
//  QueueItem.m
//  TranscodingMachine
//
//  Created by Cory Powers on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QueueItem.h"
#import "AppController.h"
#import "MediaItem.h"

@implementation QueueItem 

@dynamic status;
@dynamic sortOrder;
@dynamic mediaItem;

- (NSData *)statusImage{
	NSString* imageName;
	if([[self status] intValue] == 0){
		imageName = [[NSBundle mainBundle] pathForResource:@"EncodePending" ofType:@"png"];
	}else if ([[self status] intValue] == 1) {
		imageName = [[NSBundle mainBundle] pathForResource:@"EncodeWorking" ofType:@"png"];
	}else if ([[self status] intValue] == 255) {
		imageName = [[NSBundle mainBundle] pathForResource:@"EncodeComplete" ofType:@"png"];
	}else{
		imageName = [[NSBundle mainBundle] pathForResource:@"EncodeCanceled" ofType:@"png"];
	}
	return [NSData dataWithContentsOfFile:imageName];
}

- (NSScriptObjectSpecifier *)objectSpecifier{
	
	NSLog(@"Object specifier was called");
	
	AppController *appController = [NSApp delegate];
    NSArray *queueItems = [appController queueItems];
    NSUInteger index = [queueItems indexOfObjectIdenticalTo:self];
	
	NSScriptClassDescription *appClassDesc = (NSScriptClassDescription *)[NSScriptClassDescription classDescriptionForClass:[NSApp class]];
	
	NSIndexSpecifier *indexSpecifier = [[NSIndexSpecifier alloc] 
										initWithContainerClassDescription:appClassDesc 
										containerSpecifier:nil 
										key:@"queueItems" 
										index:index];
	NSLog(@"Sending specifier: %@", indexSpecifier);
	return indexSpecifier;
	
}

@end
