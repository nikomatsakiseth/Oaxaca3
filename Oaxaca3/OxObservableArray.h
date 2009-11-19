//
//  OxObservableArray.h
//  Flash2
//
//  Created by Nicholas Matsakis on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OxObservableArray : NSMutableArray {
	NSMutableArray *m_array;
	NSMutableArray *m_observers;
}

- init;

#pragma mark Minimum methods for NSArray which must be overridden:
- (int) count;
- objectAtIndex:(int)index;

#pragma mark Minimum methods for NSMutableArray which must be overridden:
- (void) insertObject:(id)object atIndex:(int)index;
- (void) removeObjectAtIndex:(int)index;
- (void) addObject:(id)object;
- (void) removeLastObject;
- (void) replaceObjectAtIndex:(int)index withObject:(id)object;

#pragma mark Misc

// Behaves like the normal arrayByAddingObject:, except that it always returns
// an OxObservableArray instance.
- (NSArray*) arrayByAddingObject:(id)object;

@end
