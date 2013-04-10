//
//  PrefController.m
//  QueueManager
//
//  Created by Cory Powers on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PrefController.h"
#import "SystemEvents.h"
#import "AppController.h"

@implementation PrefController

+ (void)registerUserDefaults: (NSString *)appSupportDir {
	//TODO: Change to use NSSearchPathForDirectoriesInDomains
    NSString *desktopDirectory =  [@"~/Desktop/" stringByExpandingTildeInPath];

	// Make sure the debug level and log files settings are actually in the pref file
	// to ensure the applescript can read the values.
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"logFile"] == nil){
		[[NSUserDefaults standardUserDefaults] setObject:[appSupportDir stringByAppendingPathComponent:@"tm.log"] forKey:@"logFile"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"debugLevel"] == nil){
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"debugLevel"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"folderActionInstalled": @"NO",
				@"monitoredFolder": desktopDirectory,
				@"outputFolder": desktopDirectory,
				@"allowedExtensions": @"avi,m4v,mkv,mp4",
				@"ttdApiKey": @"87C0BA77037B5012",
				@"tmdApiKey": @"329edec1b30392adcc0a28f351b09336",
				@"transcoderPath": @"/Applications/HandBrakeCLI",
				@"transcoderArgs": @"-i |INPUT| -o |OUTPUT| -e x264  -q 20.0 -a 1,1 -E faac,ac3 -B 160,160 -6 dpl2,auto -R 48,Auto -D 0.0,0.0 -f mp4 -4 -X 1280 --loose-anamorphic -m -x cabac=0:ref=2:me=umh:b-adapt=2:weightb=0:trellis=0:weightp=0"}];	
}

- (id)initWithController:(AppController *)controller {
    if (self = [super initWithController: controller withNibName:@"Preferences"]){
        NSAssert([self window], @"[PrefController init] window outlet is not connected in Preferences.nib");
		[self setMonitorFields];
    }
    return self;
}

- (void)showWindow{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	NSWindow *window = [self window];
	// Set the fields to their current values
	[window center];
	[monitoredFolderField setStringValue:[standardDefaults objectForKey:@"monitoredFolder"]];
	[outputFolderField setStringValue:[standardDefaults objectForKey:@"outputFolder"]];
	[transcoderField setStringValue:[standardDefaults objectForKey:@"transcoderPath"]];
	[transcoderArgsField setStringValue:[standardDefaults objectForKey:@"transcoderArgs"]];
	[fileExtensionsField setStringValue:[standardDefaults objectForKey:@"allowedExtensions"]];
	[self setMonitorFields];

    [window makeKeyAndOrderFront: nil];
}

- (IBAction)closeWindow:(id)sender{
	NSWindow *window = [self window];
	[window orderOut:sender];
}

- (IBAction)savePrefs:(id)sender{
	BOOL isDir;
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	NSString *oldWatchedFolder = [[NSUserDefaults standardUserDefaults] stringForKey:@"monitoredFolder"];
	NSString *newWatchedFolder = [monitoredFolderField stringValue];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	// Add trailing slash
	if (![newWatchedFolder hasSuffix:@"/"]) {
		newWatchedFolder = [newWatchedFolder stringByAppendingString:@"/"];
		[monitoredFolderField setStringValue:newWatchedFolder];
	}

	if (![fileManager fileExistsAtPath:newWatchedFolder isDirectory:&isDir] || !isDir) {
		NSRunAlertPanel(@"Invalid monitored folder", @"Invalid monitored folder, make sure the directory exists and is readable", @"Ok", nil, nil);
		[monitoredFolderField selectText:sender];
		return;
	}

	if (![fileManager fileExistsAtPath:[outputFolderField stringValue] isDirectory:&isDir] || !isDir) {
		NSRunAlertPanel(@"Invalid output folder", @"Invalid output folder, make sure the directory exists and is writable", @"Ok", nil, nil);
		[outputFolderField selectText:sender];
		return;
	}

	if (![fileManager isExecutableFileAtPath:[transcoderField stringValue]]) {
		NSRunAlertPanel(@"Invalid transcoder path", @"Invalid transcoder path, make sure the file exists and is excutable", @"Ok", nil, nil);
		[transcoderField selectText:sender];
		return;
	}

	if(![oldWatchedFolder isEqual:newWatchedFolder]){
		// Remove folder action
		[self.appController disableFolderActionOn:oldWatchedFolder];
		// add new folder action
		[self.appController enableFolderActionOn:newWatchedFolder];
	}
	[standardDefaults setObject:[monitoredFolderField stringValue] forKey:@"monitoredFolder"];
	[standardDefaults setObject:[outputFolderField stringValue] forKey:@"outputFolder"];
	[standardDefaults setObject:[transcoderField stringValue] forKey:@"transcoderPath"];
	[standardDefaults setObject:[transcoderArgsField stringValue] forKey:@"transcoderArgs"];
	[standardDefaults setObject:[fileExtensionsField stringValue] forKey:@"allowedExtensions"];
	[self closeWindow:sender];
}

- (IBAction)toggleMonitoring:(id)sender{
	NSString *newWatchedFolder = [monitoredFolderField stringValue];

	// Add trailing slash
	if (![newWatchedFolder hasSuffix:@"/"]) {
		newWatchedFolder = [newWatchedFolder stringByAppendingString:@"/"];
		[monitoredFolderField setStringValue:newWatchedFolder];
	}

	// Validate path
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir;
	if ([fileManager fileExistsAtPath:newWatchedFolder isDirectory:&isDir] && isDir){
		if ([[monitoringButton title] isEqual:@"Enable"]) {
			[self.appController enableFolderActionOn: newWatchedFolder];
		}else{
			[self.appController disableFolderActionOn:newWatchedFolder];
		}
		[self setMonitorFields];
	}
}

- (void)setMonitorFields{
	NSString *watchedFolder = [monitoredFolderField stringValue];

	if ([self.appController areFolderActionsEnabledOn:watchedFolder]) {
		[enabledLabel setStringValue:@"Monitoring active"];
		[monitoringButton setTitle:@"Disable"];
	}else{
		[enabledLabel setStringValue:@"Monitoring not active"];
		[monitoringButton setTitle:@"Enable"];
	}
}

- (IBAction) browseDirectory: (id) sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
	[panel setAllowsMultipleSelection:FALSE];
	[panel setCanChooseFiles:FALSE];
	[panel setCanChooseDirectories:TRUE];

	NSString *panelDir = nil;
	if (sender == browseMonitoredButton) {
		panelDir = [monitoredFolderField stringValue];
	}else{
		panelDir = [outputFolderField stringValue];
	}

	/* We get the current file name and path from the destination field here */
	[panel beginSheetForDirectory: panelDir
							 file: nil
				   modalForWindow: [self window] modalDelegate: self
				   didEndSelector: @selector( browseDirectoryDone:returnCode:contextInfo: )
					  contextInfo: (__bridge void *)(sender)];
}

- (void) browseDirectoryDone: (NSSavePanel *) sheet
			  returnCode: (int) returnCode
			 contextInfo: (void *) contextInfo{
    if( returnCode == NSOKButton ){
		if (contextInfo == (__bridge void *)(browseMonitoredButton)) {
			[monitoredFolderField setStringValue:[sheet directory]];
		}else{
			[outputFolderField setStringValue:[sheet directory]];
		}

    }
}

@end
