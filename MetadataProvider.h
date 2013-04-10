//
//  MetadataProvider.h
//  TranscodingMachine
//
//  Created by Cory Powers on 1/15/10.
//  Copyright 2010 UversaInc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QueueItem.h"
#import "MediaItem.h"

@protocol MetadataProviderDelegate;

@interface MetadataProvider : NSObject {
}
@property (nonatomic, retain) MediaItem *item;
@property (nonatomic, assign) id<MetadataProviderDelegate> delegate;

- (id)initWithAnItem: (MediaItem *)anItem;
- (void)applyMetadata;
- (NSString *)stringFromNode: (NSXMLNode *)node usingXPath: (NSString *)xpath;
- (void)fireDidFinish;
- (void)fireHadError: (NSError *)anError;
@end

@protocol MetadataProviderDelegate
- (void)metadataProviderDidFinish: (MetadataProvider *)aProvider;
- (void)metadataProvider: (MetadataProvider *)aProvider hadError: (NSError *)anError;
@end
