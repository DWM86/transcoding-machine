//
//  StringToNumberTransformer.m
//  VideoManager
//
//  Created by Cory Powers on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StringToNumberTransformer.h"


@implementation StringToNumberTransformer
+ (Class)transformedValueClass{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation{
    return YES;
}

- (id)transformedValue:(id)value{
	int newValue = 0;
	
    if (value == nil) return nil;

    // Attempt to get a reasonable value from the
    // value object.
    if ([value respondsToSelector: @selector(intValue)]) {
		// handles NSString and NSNumber
        newValue = [value intValue];
    } else {
        [NSException raise: NSInternalInconsistencyException
                    format: @"Value (%@) does not respond to -intValue.", [value class]];
    }
	

    return @(newValue);
}
@end
