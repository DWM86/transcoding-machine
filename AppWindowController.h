//
//  AppWindowController.h
//  QueueManager
//
//  Created by Cory Powers on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AppController;

@interface AppWindowController : NSWindowController <NSWindowDelegate> {
}
@property (readonly) AppController *appController;
@property (readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithController:(AppController *)controller withNibName:(NSString *)nibName;
- (id)initWithController:(AppController *)controller;
@end
