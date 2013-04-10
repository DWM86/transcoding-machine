//
//  QueueItem.h
//  TranscodingMachine
//
//  Created by Cory Powers on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+RevertChanges.h"

@class MediaItem;

@interface QueueItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) MediaItem * mediaItem;

@property (readonly) NSData *statusImage;

- (NSScriptObjectSpecifier *)objectSpecifier;

@end



