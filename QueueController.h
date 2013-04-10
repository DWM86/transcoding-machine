//
//  QueueController.h
//  QueueManager
//
//  Created by Cory Powers on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppController.h"
#import "AppWindowController.h"
#import "QueueItem.h"
#import "MediaItem.h"

@interface QueueController : AppWindowController <TMAppDelegate> {

}

// Progress releated properties
@property (nonatomic, strong) IBOutlet NSView *statusViewHolder;
@property (nonatomic, strong) IBOutlet NSView *statusProgressView;
@property (nonatomic, strong) IBOutlet NSView *statusNoItemView;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *statusProgressField;
@property (nonatomic, strong) IBOutlet NSTextField *statusField;
@property (nonatomic, strong) IBOutlet NSTextField *etaField;

// Queue related properties
@property (nonatomic, strong) IBOutlet NSArrayController *queueItemController;
@property (nonatomic, strong) IBOutlet NSButton *addItemButton;
@property (nonatomic, strong) IBOutlet NSButton *tagFileButton;
@property (nonatomic, strong) IBOutlet NSButton *editItemButton;
@property (nonatomic, strong) IBOutlet NSButton *startEndcodeButton;
@property (nonatomic, strong) IBOutlet NSButton *cancelEncodeButton;
@property (nonatomic, strong) IBOutlet NSTableView *queueItemsTable;

@property (readonly) NSArray *queueItem;
@property (readonly) NSArray *tableSortDescriptors;
@property (readonly) NSArray *genreList;
@property (readonly) NSArray *typeList;

// Item window properties
@property (nonatomic, strong) MediaItem *editingItem;
@property (nonatomic, strong) IBOutlet NSWindow *itemWindow;
@property (nonatomic, strong) IBOutlet NSTextField *itemInputField;
@property (nonatomic, strong) IBOutlet NSTextField *itemOutputField;
@property (nonatomic, strong) IBOutlet NSButton *itemSaveButton;
@property (nonatomic, strong) IBOutlet NSButton *itemCancelButton;

// Tag window properties
@property (nonatomic, strong) MediaItem *tagItem;
@property (nonatomic, strong) IBOutlet NSWindow *tagFileWindow;
@property (nonatomic, strong) IBOutlet NSButton *tagWriteButton;
@property (nonatomic, strong) IBOutlet NSButton *tagCancelButton;



- (id)initWithController: (AppController *)controller;
- (IBAction) browseInput: (id) sender;
- (void)     browseInputDone: (NSSavePanel *) sheet
				   returnCode: (int) returnCode
				  contextInfo: (void *) contextInfo;
- (void) metadataDidComplete: (MediaItem *) anItem;


// Item window functions
- (IBAction)showItemWindow: (id)sender;
- (IBAction)updateMetadata: (id)sender;
- (IBAction)closeItemWindow: (id)sender;
- (IBAction)writeMetadata: (id)sender;
- (IBAction) browseOutput: (id) sender;
- (void)     browseOutputDone: (NSSavePanel *) sheet
				   returnCode: (int) returnCode
				  contextInfo: (void *) contextInfo;

// Tag window functions
- (IBAction)updateTagMetadata: (id)sender;
- (IBAction)closeTagWindow: (id)sender;

// Queue Window functions
- (IBAction)startEncode: (id)sender;
- (void)updateEncodeProgress: (double)progress withEta: (NSString *) eta ofItem: (QueueItem *)item;
- (void)encodeEnded;
- (IBAction)stopEncode: (id)sender;
- (void)windowDidBecomeMain:(NSNotification *)notification;
- (void) editRow: (id)sender;
- (void) rearrangeTable;
- (IBAction)moveItemUp: (id)sender;
- (IBAction)moveItemDown: (id)sender;
- (void)setViewTo: (NSView *)view;

// Drag and drop methods
- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender;
- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender;
- (void)draggingExited:(id < NSDraggingInfo >)sender;
- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender;
- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender;
- (void)concludeDragOperation:(id < NSDraggingInfo >)sender;


@end
