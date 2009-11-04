//
//  OxNSObject.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@interface NSObject (Oaxaca2)

#pragma mark -
#pragma mark Debugging output

// Similar to description, but overload to provide a short name for use
// in debugging messages.
- (NSString*) shortDescription;

#pragma mark -
#pragma mark Inverting the NSArray methods

- (void) performSelector:(SEL)selector forEachObjectIn:(id)objects;
- (BOOL) containedIn:(id)container;
- (BOOL) notContainedIn:(id)container;
- (id) perform; // HOM

#pragma mark -
#pragma mark Misc Key-Value

// analagous to dictionaryWithValuesForKeys:
- (NSArray*) arrayWithValuesForKeys:(NSArray*)keys;

// for want of a better name, a valist version:
- (NSArray*) arrayWithValuesForKeys2:(NSString*)keys, ...;

#pragma mark -
#pragma mark Tuples

- (NSArray*) pairedWith:(id)object; // equiv. to tupleWith: just reads nicer.
- (NSArray*) tupleWith:(id)object;
- (NSArray*) tupleWith:(id)object with:(id)object;

@end
