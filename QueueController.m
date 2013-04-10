//
//  QueueController.m
//  QueueManager
//
//  Created by Cory Powers on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "QueueController.h"
#import "AppController.h"

@implementation QueueController
- (id)init{
	NSLog(@"init called on queue controller");
	return nil;
}

- (id)initWithController:(AppController *)controller {
    if (self = [super initWithController: controller withNibName:@"Queue"]){
        NSAssert([self window], @"[QueueController init] window outlet is not connected in Preferences.nib");

		controller.delegate = self;
		[self.statusViewHolder addSubview:self.statusNoItemView];
		[[self window] registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (void)awakeFromNib{
	[self.queueItemsTable setDoubleAction:@selector(editRow:)];
}

- (NSArray *)genreList{
	return @[@"Comedy", @"Drama", @"Nonfiction", @"Other", @"Sports"];
}

- (NSArray *)typeList{
	return @[@"TV Show", @"Movie"];
}

- (IBAction) browseInput: (id) sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:FALSE];
	[panel setCanChooseFiles:TRUE];
	[panel setCanChooseDirectories:FALSE];

	NSString *panelDir = nil;
	if (sender == self.addItemButton) {
		panelDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"monitoredFolder"];
	}else{
		panelDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"tagFileFolder"];
	}

	/* We get the current file name and path from the destination field here */
	[panel beginSheetForDirectory: panelDir
							 file: nil
				   modalForWindow: [self window] modalDelegate: self
				   didEndSelector: @selector( browseInputDone:returnCode:contextInfo: )
					  contextInfo: (__bridge void *)(sender)];
}

- (void) browseInputDone: (NSSavePanel *) sheet
			  returnCode: (int) returnCode
			 contextInfo: (void *) contextInfo{
    if( returnCode == NSOKButton ){
		NSError *error;
		if (contextInfo == (__bridge void *)(self.addItemButton)) {
			[self.appController addFileToQueue:[sheet filename] error:&error];
		}else if (contextInfo == (__bridge void *)(self.tagFileButton)) {
			NSLog(@"browse completed for tag file button");
			NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
			[standardDefaults setObject:[sheet directory] forKey:@"tagFileFolder"];
			self.tagItem = [self.appController mediaItemFromFile:[sheet filename] error:&error];
			if (self.tagItem == nil) {
				[NSApp presentError:error];
			}else {
				[self.appController updateMetadata:self.tagItem error:&error];
//				[self populateTagWindowFields:self.tagItem];
				[self.tagFileWindow makeKeyAndOrderFront:nil];
			}
		}

    }
}

- (void) metadataDidComplete: (MediaItem *) anItem{
	if (self.tagItem != nil) {
		NSManagedObjectContext *moc = [self.appController managedObjectContext];
		[moc deleteObject:self.tagItem];

		[self.appController saveAction:nil];
		self.tagItem = nil;
	}
	[self.tagFileButton setEnabled:YES];
}

#pragma mark - Item Window Methods
- (IBAction)showItemWindow: (id)sender{
	// Setup fields with selected object
	// Populate item values
	QueueItem *selectedItem = [self.queueItemController selectedObjects][0];
	if (!selectedItem) {
		return;
	}
	
	[[[self.appController managedObjectContext] undoManager] beginUndoGrouping];
	[[[self.appController managedObjectContext] undoManager] setActionName:[NSString stringWithFormat:@"Editing of %@", selectedItem.mediaItem.shortName]];
	self.editingItem = selectedItem.mediaItem;
	[self.itemWindow makeKeyAndOrderFront:sender];
}

- (IBAction)closeItemWindow: (id)sender{
	// Setup fields with selected object
	if (sender == self.itemSaveButton) {
		[[[self.appController managedObjectContext] undoManager] endUndoGrouping];
		NSString *input = [self.itemInputField stringValue];
		// Validate the input file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:input] || ![fileManager isReadableFileAtPath:input]){
			NSRunAlertPanel(@"Invalid input file", @"Invalid input file, make sure the file exists and is readable", @"Ok", nil, nil);
			[self.itemInputField selectText:sender];
			return;
		}

		// Save the object
		[self.appController saveAction:nil];
	}else if (sender == self.itemCancelButton) {
		[[[self.appController managedObjectContext] undoManager] endUndoGrouping];
		[[[self.appController managedObjectContext] undoManager] undo];

	}

	self.editingItem = nil;
	[self.itemWindow orderOut:sender];
}

- (IBAction) browseOutput: (id) sender{
    NSSavePanel * panel = [NSSavePanel savePanel];
	/* We get the current file name and path from the destination field here */
	[panel beginSheetForDirectory: [[self.itemOutputField stringValue] stringByDeletingLastPathComponent]
							 file: [[self.itemOutputField stringValue] lastPathComponent]
				   modalForWindow: self.itemWindow modalDelegate: self
				   didEndSelector: @selector( browseOutputDone:returnCode:contextInfo: )
					  contextInfo: NULL];
}

- (void) browseOutputDone: (NSSavePanel *) sheet
             returnCode: (int) returnCode
			contextInfo: (void *) contextInfo{
    if( returnCode == NSOKButton ){
        [self.itemOutputField setStringValue: [sheet filename]];
    }
}

- (IBAction)updateMetadata: (id)sender{
	NSError *anError;
	[self.appController updateMetadata: self.editingItem error:&anError];
}

- (IBAction)writeMetadata: (id)sender{
	NSError *anError;
	[self.appController setHDFlag: self.editingItem error:&anError];
	[self.appController writeMetadata: self.editingItem error:&anError];
}

#pragma mark - Tag Window Methods
- (IBAction)closeTagWindow: (id)sender{
	NSError *anError;
	if (sender == self.tagWriteButton) {
		[self.appController writeMetadata:self.tagItem error:&anError];
		[self.tagFileButton setEnabled:NO];
	}else if (sender == self.tagCancelButton) {
		// Get rid of transient tagItem in core data
		NSManagedObjectContext *moc = [self.appController managedObjectContext];
		[moc deleteObject:self.tagItem];
		
		[self.appController saveAction:nil];
		self.tagItem = nil;		
	}

	[self.tagFileWindow orderOut:sender];
}

- (IBAction)updateTagMetadata: (id)sender{
	NSError *anError;
	[self.appController updateMetadata: self.tagItem error:&anError];
}


#pragma mark - Queue Window Methods
- (NSArray *)queueItems{
	return [self.appController queueItems];
}

- (void)windowDidBecomeMain:(NSNotification *)notification{
	NSArray *subviews = [self.statusViewHolder subviews];
	if ([subviews count] > 0) {
		NSView *currentView = subviews[0];
		[self.statusViewHolder resizeSubviewsWithOldSize:[currentView bounds].size];
	}
}

- (void)setViewTo:(NSView *)view{
	NSArray *subviews = [self.statusViewHolder subviews];
	NSView *currentView = subviews[0];
	if (currentView != view ) {
		[currentView removeFromSuperview];
		[self.statusViewHolder addSubview:view];
		[self.statusViewHolder resizeSubviewsWithOldSize:[view bounds].size];
	}
}

- (IBAction)startEncode: (id)sender{
	QueueItem *selectedItem = [self.queueItemController selectedObjects][0];
	[self.appController startEncode:selectedItem];
}

- (void)updateEncodeProgress: (double)progress withEta: (NSString *) eta ofItem: (QueueItem *)item{
	[self setViewTo:self.statusProgressView];

	// Refresh table for icon update
	[self.queueItemsTable reloadData];
	[self.queueItemsTable setNeedsDisplay];

	// Disable start button if needed
	if ([self.startEndcodeButton isEnabled]) {
		[self.startEndcodeButton setEnabled:FALSE];
	}
	[self.statusField setStringValue:item.mediaItem.shortName];
	if (eta == nil) {
		[self.etaField setStringValue:@"--h--m--s"];
	}else{
		[self.etaField setStringValue:eta];
	}
	[self.statusProgressField setDoubleValue:progress];
}

- (void)encodeEnded{
	[self.queueItemsTable reloadData];
	[self.queueItemsTable setNeedsDisplay];
	[self setViewTo: self.statusNoItemView];
	[self.startEndcodeButton setEnabled:TRUE];
}

- (IBAction)stopEncode: (id)sender{
	[self.appController stopEncode];
}

- (NSArray *)tableSortDescriptors{
	NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc]
								   initWithKey: @"sortOrder" ascending:YES] ;
	return @[sortOrder];
}

- (void) rearrangeTable{
	[self.queueItemController didChangeArrangementCriteria];
}

- (void) editRow:(id)sender{
	NSInteger row = [self.queueItemsTable clickedRow];
	if(row == -1){
		return;
	}

	[self showItemWindow:sender];
}

- (IBAction) moveItemUp: (id)sender{
	QueueItem *selectedItem = [self.queueItemController selectedObjects][0];
	if ([self.appController moveItemUp:selectedItem]) {
		[self rearrangeTable];
	};
}

- (IBAction) moveItemDown: (id)sender{
	QueueItem *selectedItem = [self.queueItemController selectedObjects][0];
	if ([self.appController moveItemDown:selectedItem]) {
		[self rearrangeTable];
	};
}

#pragma mark Drag-n-Drop Support
- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender{
	NSLog(@"draggingEntered");
	NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation mask = [sender draggingSourceOperationMask];
    unsigned int ret = (NSDragOperationCopy & mask);

    if ([[pboard types] indexOfObject:NSFilenamesPboardType] == NSNotFound) {
        ret = NSDragOperationNone;
		NSLog(@"Unsupported drag source");
    }
    return ret;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation mask = [sender draggingSourceOperationMask];
    unsigned int ret = (NSDragOperationCopy & mask);

    if ([[pboard types] indexOfObject:NSFilenamesPboardType] == NSNotFound) {
        ret = NSDragOperationNone;
		NSLog(@"Unsupported drag source");
    }
    return ret;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender{

}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender{
	return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender{
	NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
	NSError *anError;
	for(NSString *filename in files){
		NSLog(@"Adding file %@", filename);
		[self.appController addFileToQueue:filename error:&anError];
	}

    return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender{

}


@end
