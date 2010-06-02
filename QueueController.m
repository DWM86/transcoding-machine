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
		[statusViewHolder addSubview:statusNoItemView];
		[[self window] registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void)awakeFromNib{
	NSLog(@"I have awoke from the nib");

	[queueItemsTable setDoubleAction:@selector(editRow:)];
}

- (NSArray *)genreList{
	return [NSArray arrayWithObjects:@"Comedy", @"Drama", @"Nonfiction", @"Other", @"Sports", nil];
}

- (NSArray *)typeList{
	return [NSArray arrayWithObjects:@"TV Show", @"Movie", nil];
}

- (IBAction) browseInput: (id) sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:FALSE];
	[panel setCanChooseFiles:TRUE];
	[panel setCanChooseDirectories:FALSE];

	NSString *panelDir = nil;
	if (sender == addItemButton) {
		panelDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"monitoredFolder"];
	}else{
		panelDir = [[NSUserDefaults standardUserDefaults] stringForKey:@"tagFileFolder"];
	}

	/* We get the current file name and path from the destination field here */
	[panel beginSheetForDirectory: panelDir
							 file: nil
				   modalForWindow: [self window] modalDelegate: self
				   didEndSelector: @selector( browseInputDone:returnCode:contextInfo: )
					  contextInfo: sender];
}

- (void) browseInputDone: (NSSavePanel *) sheet
			  returnCode: (int) returnCode
			 contextInfo: (void *) contextInfo{
    if( returnCode == NSOKButton ){
		NSError *error;
		if (contextInfo == addItemButton) {
			[appController addFileToQueue:[sheet filename] error:&error];
		}else if (contextInfo == tagFileButton) {
			NSLog(@"browse completed for tag file button");
			NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
			[standardDefaults setObject:[sheet directory] forKey:@"tagFileFolder"];
			tagItem = [[appController mediaItemFromFile:[sheet filename] error:&error] retain];
			if (tagItem == nil) {
				[NSApp presentError:error];
			}else {
				[appController updateMetadata:tagItem error:&error];
				[self populateTagWindowFields:tagItem];
				[tagFileWindow makeKeyAndOrderFront:nil];
			}
		}

    }
}

- (void) metadataDidComplete: (MediaItem *) anItem{
	if (tagItem != nil) {
		NSManagedObjectContext *moc = [appController managedObjectContext];
		[moc deleteObject:tagItem];

		[appController saveAction:nil];
	}
	[tagFileButton setEnabled:YES];
}

#pragma mark Item Window Methods

- (void)populateItemWindowFields: (MediaItem *)anItem {
	NSString *input = [anItem input];
	if (input == nil) {
		input = [NSString string];
	}
	[itemInputField setStringValue:input];

	NSString *output = [anItem output];
	if (output == nil) {
		output = [NSString string];
	}
	[itemOutputField setStringValue:output];

	NSString *title = [anItem title];
	if (title == nil) {
		title = [NSString string];
	}
	[itemTitleField setStringValue:title];

	NSString *showName = [anItem showName];
	if (showName == nil) {
		showName = [NSString string];
	}
	[itemShowField setStringValue:showName];

	NSString *season = [[anItem season] stringValue];
	if (season == nil) {
		season = [NSString string];
	}
	[itemSeasonField setStringValue:season];

	NSString *episode = [[anItem episode] stringValue];
	if (episode == nil) {
		episode = [NSString string];
	}
	[itemEpisodeField setStringValue:episode];

	NSString *summary = [anItem summary];
	if (summary == nil) {
		summary = [NSString string];
	}
	[itemSummaryField setStringValue:summary];

	NSImage *coverArt = [[NSImage alloc] initWithData:[anItem coverArt]];
	[itemCoverArtField setImage:coverArt];

	NSString *longDesc = [anItem longDescription];
	if (longDesc == nil) {
		longDesc = [NSString string];
	}
	[itemDescriptionField setStringValue:longDesc];

	NSString *copyright = [anItem copyright];
	if (copyright == nil) {
		copyright = [NSString string];
	}
	[itemCopyrightField setStringValue:copyright];

	NSString *network = [anItem network];
	if (network == nil) {
		network = [NSString string];
	}
	[itemNetworkField setStringValue:network];

	NSString *releaseDate = [anItem releaseDate];
	if (releaseDate == nil) {
		releaseDate = [NSString string];
	}
	[itemReleaseDateField setStringValue:releaseDate];

	NSNumber *type = [anItem type];
	[itemTypePopUp selectItemWithTitle:nil];
	if ([type intValue] == 1) {
		[itemTypePopUp selectItemWithTitle:@"TV Show"];
	}else if ([type intValue] == 2) {
		[itemTypePopUp selectItemWithTitle:@"Movie"];
	}

	[itemGenrePopUp selectItemWithTitle: [anItem genre]];

	NSString *message = [anItem message];
	if (message == nil) {
		message = [NSString string];
	}
	[itemMessageField setStringValue:message];
}

- (IBAction)showItemWindow: (id)sender{
	// Setup fields with selected object
	// Populate item values
	QueueItem *selectedItem = [[queueItems selectedObjects] objectAtIndex:0];
	editingItem = selectedItem.mediaItem;
	[self populateItemWindowFields:editingItem];
	[itemWindow makeKeyAndOrderFront:sender];
}

- (IBAction)closeItemWindow: (id)sender{
	// Setup fields with selected object
	if (sender == itemSaveButton) {
		NSString *input = [itemInputField stringValue];
		// Validate the input file
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:input] || ![fileManager isReadableFileAtPath:input]){
			NSRunAlertPanel(@"Invalid input file", @"Invalid input file, make sure the file exists and is readable", @"Ok", nil, nil);
			[itemInputField selectText:sender];
			return;
		}

		// Save the object
		[self saveItem];
	}

	[itemWindow orderOut:sender];
}

- (BOOL)saveItem {
	NSNumberFormatter *numFormatter = [NSNumberFormatter alloc];
	if (editingItem == nil) {
		NSLog(@"Somehow save was called without a current editingItem");
		return NO;
	}
	editingItem.input = [itemInputField stringValue];
	editingItem.output = [itemOutputField stringValue];
	editingItem.showName = [itemShowField stringValue];
	editingItem.title = [itemTitleField stringValue];
	editingItem.season = [numFormatter numberFromString:[itemSeasonField stringValue]];
	editingItem.episode = [numFormatter numberFromString:[itemEpisodeField stringValue]];
	editingItem.summary = [itemSummaryField stringValue];
	if ([itemCoverArtField image] != nil) {
		editingItem.coverArt = [NSBitmapImageRep representationOfImageRepsInArray:[[itemCoverArtField image] representations]
																usingType:NSJPEGFileType
															   properties:nil];
	}else{
		editingItem.coverArt = nil;
	}
	editingItem.longDescription = [itemDescriptionField stringValue];
	editingItem.copyright = [itemCopyrightField stringValue];
	editingItem.network = [itemNetworkField stringValue];
	editingItem.releaseDate	= [itemReleaseDateField stringValue];
	if([itemHDVideoButton state] == NSOnState){
		editingItem.hdVideo = [NSNumber numberWithInt:1];
	}else{
		editingItem.hdVideo = [NSNumber numberWithInt:0];
	}
	if ([[[itemTypePopUp selectedItem] title] isEqualToString:@"TV Show"]) {
		editingItem.type = [NSNumber numberWithInt:ItemTypeTV];
	}else {
		editingItem.type = [NSNumber numberWithInt:ItemTypeMovie];
	}

	editingItem.genre = [[itemGenrePopUp selectedItem] title];
	[appController saveAction:nil];

	return YES;
}

- (IBAction) browseOutput: (id) sender{
    NSSavePanel * panel = [NSSavePanel savePanel];
	/* We get the current file name and path from the destination field here */
	[panel beginSheetForDirectory: [[itemOutputField stringValue] stringByDeletingLastPathComponent]
							 file: [[itemOutputField stringValue] lastPathComponent]
				   modalForWindow: itemWindow modalDelegate: self
				   didEndSelector: @selector( browseOutputDone:returnCode:contextInfo: )
					  contextInfo: NULL];
}

- (void) browseOutputDone: (NSSavePanel *) sheet
             returnCode: (int) returnCode
			contextInfo: (void *) contextInfo{
    if( returnCode == NSOKButton ){
        [itemOutputField setStringValue: [sheet filename]];
    }
}

- (IBAction)updateMetadata: (id)sender{
	[self saveItem];
	NSError *anError;
	[appController updateMetadata: editingItem error:&anError];
	[self populateItemWindowFields:editingItem];
}

- (IBAction)writeMetadata: (id)sender{
	NSError *anError;
	[appController setHDFlag: editingItem error:&anError];
	[appController writeMetadata: editingItem error:&anError];
}

#pragma mark Tag Window Methods

- (void)populateTagWindowFields: (MediaItem *)anItem {
	NSString *output = [anItem output];
	if (output == nil) {
		output = [NSString string];
	}
	[tagFileField setStringValue:output];

	NSString *title = [anItem title];
	if (title == nil) {
		title = [NSString string];
	}
	[tagTitleField setStringValue:title];

	NSString *showName = [anItem showName];
	if (showName == nil) {
		showName = [NSString string];
	}
	[tagShowField setStringValue:showName];

	NSString *season = [[anItem season] stringValue];
	if (season == nil) {
		season = [NSString string];
	}
	[tagSeasonField setStringValue:season];

	NSString *episode = [[anItem episode] stringValue];
	if (episode == nil) {
		episode = [NSString string];
	}
	[tagEpisodeField setStringValue:episode];

	NSString *summary = [anItem summary];
	if (summary == nil) {
		summary = [NSString string];
	}
	[tagSummaryField setStringValue:summary];

	NSImage *coverArt = [[NSImage alloc] initWithData:[anItem coverArt]];
	[tagCoverArtField setImage:coverArt];

	NSString *longDesc = [anItem longDescription];
	if (longDesc == nil) {
		longDesc = [NSString string];
	}
	[tagDescriptionField setStringValue:longDesc];

	NSString *copyright = [anItem copyright];
	if (copyright == nil) {
		copyright = [NSString string];
	}
	[tagCopyrightField setStringValue:copyright];

	NSString *network = [anItem network];
	if (network == nil) {
		network = [NSString string];
	}
	[tagNetworkField setStringValue:network];

	NSString *releaseDate = [anItem releaseDate];
	if (releaseDate == nil) {
		releaseDate = [NSString string];
	}
	[tagReleaseDateField setStringValue:releaseDate];

	NSNumber *type = [anItem type];
	[tagTypePopUp selectItemWithTitle:nil];
	if ([type intValue] == 1) {
		[tagTypePopUp selectItemWithTitle:@"TV Show"];
	}else if ([type intValue] == 2) {
		[tagTypePopUp selectItemWithTitle:@"Movie"];
	}

	[tagGenrePopUp selectItemWithTitle: [anItem genre]];
}

- (BOOL)saveTagItem {
	NSNumberFormatter *numFormatter = [NSNumberFormatter alloc];
	if (tagItem == nil) {
		NSLog(@"Somehow saveTagItem was called without a current tagItem");
		return NO;
	}
	tagItem.showName = [tagShowField stringValue];
	tagItem.title = [tagTitleField stringValue];
	tagItem.season = [numFormatter numberFromString:[tagSeasonField stringValue]];
	tagItem.episode = [numFormatter numberFromString:[tagEpisodeField stringValue]];
	tagItem.summary = [tagSummaryField stringValue];
	if ([tagCoverArtField image] != nil) {
		tagItem.coverArt = [NSBitmapImageRep representationOfImageRepsInArray:[[tagCoverArtField image] representations]
																	usingType:NSJPEGFileType
																   properties:nil];
	}else {
		tagItem.coverArt = nil;
	}


	tagItem.longDescription = [tagDescriptionField stringValue];
	tagItem.copyright = [tagCopyrightField stringValue];
	tagItem.network = [tagNetworkField stringValue];
	tagItem.releaseDate	= [tagReleaseDateField stringValue];
	if([tagHDVideoButton state] == NSOnState){
		tagItem.hdVideo = [NSNumber numberWithInt:1];
	}else{
		tagItem.hdVideo = [NSNumber numberWithInt:0];
	}
	if ([[[tagTypePopUp selectedItem] title] isEqualToString:@"TV Show"]) {
		tagItem.type = [NSNumber numberWithInt:ItemTypeTV];
	}else {
		tagItem.type = [NSNumber numberWithInt:ItemTypeMovie];
	}

	tagItem.genre = [[tagGenrePopUp selectedItem] title];
	[appController saveAction:nil];

	return YES;
}

- (IBAction)closeTagWindow: (id)sender{
	NSError *anError;
	if (sender == tagWriteButton) {
		[self saveTagItem];
		[appController writeMetadata:tagItem error:&anError];
		[tagFileButton setEnabled:NO];
	}

	[tagFileWindow orderOut:sender];
}

- (IBAction)updateTagMetadata: (id)sender{
	[self saveTagItem];
	NSError *anError;
	[appController updateMetadata: tagItem error:&anError];
	[self populateTagWindowFields:tagItem];
}


#pragma mark Queue Window Methods

- (NSArray *)queueItems{
	return [appController queueItems];
}

- (void)windowDidBecomeMain:(NSNotification *)notification{
	NSArray *subviews = [statusViewHolder subviews];
	if ([subviews count] > 0) {
		NSView *currentView = [subviews objectAtIndex:0];
		[statusViewHolder resizeSubviewsWithOldSize:[currentView bounds].size];
	}
}

- (void)setViewTo:(NSView *)view{
	NSArray *subviews = [statusViewHolder subviews];
	NSView *currentView = [subviews objectAtIndex:0];
	if (currentView != view ) {
		[currentView removeFromSuperview];
		[statusViewHolder addSubview:view];
		[statusViewHolder resizeSubviewsWithOldSize:[view bounds].size];
	}
}

- (IBAction)startEncode: (id)sender{
	QueueItem *selectedItem = [[queueItems selectedObjects] objectAtIndex:0];
	[appController startEncode:selectedItem];
}

- (void)updateEncodeProgress: (double)progress withEta: (NSString *) eta ofItem: (QueueItem *)item{
	[self setViewTo:statusProgressView];

	// Refresh table for icon update
	[queueItemsTable reloadData];
	[queueItemsTable setNeedsDisplay];

	// Disable start button if needed
	if ([startEndcodeButton isEnabled]) {
		[startEndcodeButton setEnabled:FALSE];
	}
	[statusField setStringValue:item.mediaItem.shortName];
	if (eta == nil) {
		[etaField setStringValue:@"--h--m--s"];
	}else{
		[etaField setStringValue:eta];
	}
	[statusProgressField setDoubleValue:progress];
}

- (void)encodeEnded{
	[queueItemsTable reloadData];
	[queueItemsTable setNeedsDisplay];
	[self setViewTo:statusNoItemView];
	[startEndcodeButton setEnabled:TRUE];
}

- (IBAction)stopEncode: (id)sender{
	[appController stopEncode];
}

- (NSArray *)tableSortDescriptors{
	NSSortDescriptor *sortOrder = [[NSSortDescriptor alloc]
								   initWithKey: @"sortOrder" ascending:YES] ;
	return [NSArray arrayWithObjects: sortOrder, nil];
}

- (void) rearrangeTable{
	[queueItems didChangeArrangementCriteria];
}

- (void) editRow:(id)sender{
	int row = [queueItemsTable clickedRow];
	if(row == -1){
		return;
	}

	[self showItemWindow:sender];
}

- (IBAction) moveItemUp: (id)sender{
	QueueItem *selectedItem = [[queueItems selectedObjects] objectAtIndex:0];
	if ([appController moveItemUp:selectedItem]) {
		[self rearrangeTable];
	};
}

- (IBAction) moveItemDown: (id)sender{
	QueueItem *selectedItem = [[queueItems selectedObjects] objectAtIndex:0];
	if ([appController moveItemDown:selectedItem]) {
		[self rearrangeTable];
	};
}

#pragma mark Drag-n-Drop Support
- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender{
	NSLog(@"draggingEntered");
	NSPasteboard *pboard = [sender draggingPasteboard];
    unsigned int mask = [sender draggingSourceOperationMask];
    unsigned int ret = (NSDragOperationCopy & mask);

    if ([[pboard types] indexOfObject:NSFilenamesPboardType] == NSNotFound) {
        ret = NSDragOperationNone;
		NSLog(@"Unsupported drag source");
    }
    return ret;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender{
	NSPasteboard *pboard = [sender draggingPasteboard];
    unsigned int mask = [sender draggingSourceOperationMask];
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
		[appController addFileToQueue:filename error:&anError];
	}

    return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender{

}

@end
