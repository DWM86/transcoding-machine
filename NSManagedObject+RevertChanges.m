//
//  NSManagedObject+RevertChanges.m
//  TranscodingMachine
//
//  Created by Cory Powers on 3/31/13.
//  Copyright (c) 2013 UversaInc. All rights reserved.
//

#import "NSManagedObject+RevertChanges.h"

@implementation NSManagedObject (RevertChanges)

- (void) revertChanges {
    // Revert to original Values
    NSDictionary *changedValues = [self changedValues];
    NSDictionary *committedValues = [self committedValuesForKeys:[changedValues allKeys]];
    NSEnumerator *enumerator;
    id key;
    enumerator = [changedValues keyEnumerator];
	
    while ((key = [enumerator nextObject])) {
		if ([[committedValues objectForKey:key] class] != [NSNull class]) {
			[self setValue:[committedValues objectForKey:key] forKey:key];
		}else{
			[self setValue:nil forKey:key];
		}
    }
}

@end
