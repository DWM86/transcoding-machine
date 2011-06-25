//
//  TheTVDBProvider.h
//  TranscodingMachine
//
//  Created by Cory Powers on 1/15/10.
//  Copyright 2010 UversaInc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetadataProvider.h"

typedef enum {
	TTDBStateMirror = 1,
	TTDBStateUpdateTime,
	TTDBStateSeriesId,
	TTDBStateSeriesInfo,
	TTDBStateEpisodeInfo
} TTDBState;

@interface TheTVDBProvider : MetadataProvider {
	NSString *mirrorUrl;
	NSMutableString *currentResponse;
	int lastUpdateTime;
	int seriesId;	
	int currentState;
}
@property (nonatomic, retain) NSMutableString *currentResponse;
@property (nonatomic) int currentState;
- (void)getMirrorUrl;
- (void)processMirrorUrlData: (NSString *)responseData;
- (void)getLastUpdateTime;
- (void)processLastUpdateTime: (NSString *)responseData;
- (void)getSeriesId;
- (void)processSeriesId: (NSString *)responseData;
- (void)getSeriesInfo;
- (void)processSeriesInfo: (NSString *)responseData;
- (void)getEpisodeInfo;
- (void)processEpisodeInfo: (NSString *)responseData;

@end
