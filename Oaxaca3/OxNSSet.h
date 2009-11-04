//
//  OxNSSet.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@interface NSSet (Oaxaca2) 

+ (id) setWithUnionOfArrays:(NSArray*)array, ...;
+ (id) setWithUnionOfSets:(NSSet*)set, ...;

#pragma mark -
#pragma mark Higher Order Messaging (see OxHom.h for more!)

- (id) perform;

#pragma mark Misc

- (NSString*) shortDescription;
- (BOOL) isEmpty;
- (NSArray*) toArray;

@end
