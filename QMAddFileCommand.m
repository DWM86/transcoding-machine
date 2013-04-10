//
//  QMAddFileCommand.m
//  QueueManager
//
//  Created by Cory Powers on 1/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QMAddFileCommand.h"
#import "AppController.h"


@implementation QMAddFileCommand : NSScriptCommand
-(id)performDefaultImplementation
{
	NSLog(@"AddFileCommand performDefaultImplementation");
	
	AppController *appController = [NSApp delegate];
	NSError *anError;
	NSInteger	theError = noErr;
	id		directParameter = [self directParameter];
	if([appController addFileToQueue:directParameter error:&anError] == nil){
		theError = [anError code];
	}
	
	NSLog(@"AddFileCommand performDefaultImplementation directParameter = %@",directParameter);
	
	if ( theError != noErr ){
		//ME	report the error, if any
		[self setScriptErrorNumber:theError];
	}
		
	return nil;
}	
@end
