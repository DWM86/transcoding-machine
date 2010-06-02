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
	IBOutlet NSView *statusViewHolder;
	IBOutlet NSView *statusProgressView;
	IBOutlet NSView *statusNoItemView;
	IBOutlet NSProgressIndicator *statusProgressField;
	IBOutlet NSTextField *statusField;
	IBOutlet NSTextField *etaField;

	IBOutlet NSArrayController *queueItems;
	IBOutlet NSButton *addItemButton;
	IBOutlet NSButton *tagFileButton;
	IBOutlet NSButton *editItemButton;
	IBOutlet NSButton *startEndcodeButton;
	IBOutlet NSButton *cancelEncodeButton;
	IBOutlet NSTableView *queueItemsTable;
	IBOutlet NSButton *itemUpButton;
	IBOutlet NSButton *itemDownButton;

	// Item window outlets
	MediaItem *editingItem;
	IBOutlet NSWindow *itemWindow;
	IBOutlet NSTextField *itemInputField;
	IBOutlet NSTextField *itemOutputField;
	IBOutlet NSTextField *itemTitleField;
	IBOutlet NSTextField *itemShowField;
	IBOutlet NSTextField *itemSeasonField;
	IBOutlet NSTextField *itemEpisodeField;
	IBOutlet NSTextField *itemSummaryField;
	IBOutlet NSTextField *itemDescriptionField;
	IBOutlet NSTextField *itemReleaseDateField;
	IBOutlet NSTextField *itemCopyrightField;
	IBOutlet NSTextField *itemNetworkField;
	IBOutlet NSButton *itemHDVideoButton;
	IBOutlet NSPopUpButton *itemTypePopUp;
	IBOutlet NSPopUpButton *itemGenrePopUp;
	IBOutlet NSTabView *itemTabView;
	IBOutlet NSTextField *itemMessageField;
	IBOutlet NSImageView *itemCoverArtField;
	IBOutlet NSButton *itemSaveButton;
	IBOutlet NSButton *itemCancelButton;
	IBOutlet NSButton *itemProcess;

	// Tag File window
	MediaItem *tagItem;
	IBOutlet NSWindow *tagFileWindow;
	IBOutlet NSTextField *tagFileField;
	IBOutlet NSTextField *tagTitleField;
	IBOutlet NSTextField *tagShowField;
	IBOutlet NSTextField *tagSeasonField;
	IBOutlet NSTextField *tagEpisodeField;
	IBOutlet NSTextField *tagSummaryField;
	IBOutlet NSTextField *tagDescriptionField;
	IBOutlet NSTextField *tagReleaseDateField;
	IBOutlet NSTextField *tagCopyrightField;
	IBOutlet NSTextField *tagNetworkField;
	IBOutlet NSButton *tagHDVideoButton;
	IBOutlet NSPopUpButton *tagTypePopUp;
	IBOutlet NSPopUpButton *tagGenrePopUp;
	IBOutlet NSTabView *tagTabView;
	IBOutlet NSImageView *tagCoverArtField;
	IBOutlet NSButton *tagWriteButton;
	IBOutlet NSButton *tagCancelButton;
	IBOutlet NSButton *tagUpdateButton;

}

@property (readonly) NSArray *queueItems;
@property (readonly) NSArray *tableSortDescriptors;
@property (readonly) NSArray *genreList;
@property (readonly) NSArray *typeList;

- (id)initWithController: (AppController *)controller;
- (IBAction) browseInput: (id) sender;
- (void)     browseInputDone: (NSSavePanel *) sheet
				   returnCode: (int) returnCode
				  contextInfo: (void *) contextInfo;
- (void) metadataDidComplete: (MediaItem *) anItem;


// Item window functions
- (void)populateItemWindowFields: (MediaItem *)anItem;
- (IBAction)showItemWindow: (id)sender;
- (IBAction)updateMetadata: (id)sender;
- (IBAction)closeItemWindow: (id)sender;
- (BOOL)saveItem;
- (IBAction)writeMetadata: (id)sender;
- (IBAction) browseOutput: (id) sender;
- (void)     browseOutputDone: (NSSavePanel *) sheet
				   returnCode: (int) returnCode
				  contextInfo: (void *) contextInfo;

// Tag window functions
- (void)populateTagWindowFields: (MediaItem *)anItem;
- (IBAction)updateTagMetadata: (id)sender;
- (BOOL)saveTagItem;
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
