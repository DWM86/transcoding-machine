//
//  MediaItem.h
//  TranscodingMachine
//
//  Created by Cory Powers on 3/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+RevertChanges.h"

#define ItemTypeTV 1
#define ItemTypeMovie 2

@class QueueItem;


@interface MediaItem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * showName;
@property (nonatomic, retain) NSString * releaseDate;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * output;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSData * coverArt;
@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSString * input;
@property (nonatomic, retain) NSNumber * hdVideo;
@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * network;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * copyright;
@property (nonatomic, retain) NSString * genre;

@property (nonatomic, retain) QueueItem * queueItem;

@property (readonly) NSString *shortName;
@property (readonly) NSString *episodeId;
@property (readonly) NSImage *coverArtImage;

@end



