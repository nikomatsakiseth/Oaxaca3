//
//  OxNSArray.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "Ox.h"

@interface NSArray (Oaxaca2) 

#pragma mark -
#pragma mark Sorted Arrays

- (NSArray*) sortedArrayUsingKey:(NSString*)key;
- (NSArray*) sortedArrayUsingKey:(NSString*)key ascending:(BOOL)ascending;
- (NSArray*) sortedArrayUsingKey:(NSString*)key ascending:(BOOL)ascending compareSelector:(SEL)sel;

#pragma mark -
#pragma mark Python style slices

- (NSArray*) sliceFrom:(int)index;
- (NSArray*) sliceTo:(int)index;
- (NSArray*) sliceFrom:(int)index to:(int)index;

#pragma mark -
#pragma mark Misc

- (NSArray*) reversedArray;
- (BOOL) isEmpty;
- (id) anyObject;
- (id) randomObject; // you must seed random() appropriately!
- (NSIndexSet*) indexSetWithAllIndices;
- (BOOL)containsObjectMatchingPredicateFormat:(NSString *)format, ...;
- (NSArray *)filteredArrayUsingPredicateFormat:(NSString *)format, ...;
- (NSArray*) arrayByInsertingObject:(id)object atIndex:(int)index;
- (NSArray*) arrayByReplacingObjectAtIndex:(int)index withObject:(id)object;
- (NSArray*) arrayByIntersectingWithContainer:(id)array; // all x in self for which [array containsObject:x] returns true
- (id) objectMatchingPredicate:(NSPredicate *)predicate;
- (id) objectMatchingPredicateFormat:(NSString *)format, ...;
- (NSArray*) arrayByRemovingObjectsFromArray:(NSArray*)array;
- (NSString*) shortDescription;

#pragma mark -
#pragma mark Map, Filter, Do

- (NSArray*) mapByPerformingSelector:(SEL)sel;

#ifdef OX_BLOCKS_AVAILABLE
- (NSArray*) filterWithBlock:(int (^)(id obj))block;      // if returns NO, omit
- (NSArray*) mapWithBlock:(id (^)(id obj))block;          // replace with whatever is returned
- (NSArray*) filterAndMapWithBlock:(id (^)(id obj))block; // if returns nil, omit
#endif

#pragma mark -
#pragma mark Zip

- (NSArray*) zippedArrayWith:(NSArray*)array;

#pragma mark -
#pragma mark Quick Indices

// Quick access to certain indices. 
// Particularly useful with NSObject pairedWith:.
- (id) _0;
- (id) _1;
- (id) _2;
- (id) _3;

@end
