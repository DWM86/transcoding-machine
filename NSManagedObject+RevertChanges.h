//
//  NSManagedObject+RevertChanges.h
//  TranscodingMachine
//
//  Created by Cory Powers on 3/31/13.
//  Copyright (c) 2013 UversaInc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (RevertChanges)
- (void) revertChanges;

@end
