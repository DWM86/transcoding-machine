//
//  AppWindowController.m
//  QueueManager
//
//  Created by Cory Powers on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppWindowController.h"
#import "AppController.h"

@interface AppWindowController ()
@property (nonatomic, strong) AppController *appController;

@end

@implementation AppWindowController
- (id)initWithController: (AppController *)controller withNibName: (NSString *)nibName {
	if (self = [super initWithWindowNibName:nibName]){
		self.appController = controller;
	}
	return self;
}

- (id)initWithController: (AppController *)controller {
	if (self = [super init]){
		self.appController = controller;
	}
	return self;
}

- (NSManagedObjectContext *)managedObjectContext{
	return [self.appController managedObjectContext];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window{
	return [self.appController windowWillReturnUndoManager:window];
}
@end
