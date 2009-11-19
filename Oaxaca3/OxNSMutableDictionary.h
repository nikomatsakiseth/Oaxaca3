//
//  OxNSMutableDictionary.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Oaxaca2)

// Looks up key and returns its value, which must be a mutable array.
// If no value is present, creates an inserts a new mutable array, and
// returns that.  Useful when maintaining a dictionary that maps from
// one key to many values.
- (NSMutableArray*) mutableArrayForKey:(id)key;
- (void) addObject:(id)object toMutableArrayForKey:(id)key;

@end

#pragma mark Shared Impl. Routines

// These C functions implement some of the extensions above.  They
// are shared between NSMutableDictionary and NSMapTable, etc.

NSMutableArray *OxMutableArrayForKey(id dict, id key);
