//
//  OxNSMutableDictionary.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSMutableDictionary.h"

NSMutableArray *OxMutableArrayForKey(id self, id key) {
    NSMutableArray *res = [self objectForKey:key];
    if (res == nil) {
        res = [NSMutableArray array];
        [self setObject:res forKey:key];
    } else {
        assert([res isKindOfClass:[NSMutableArray class]]);
    }
    return res;
}

@implementation NSMutableDictionary (Oaxaca2)

- (NSMutableArray*) mutableArrayForKey:(id)key
{
    return OxMutableArrayForKey(self, key);
}

- (void) addObject:(id)object toMutableArrayForKey:(id)key
{
    [[self mutableArrayForKey:key] addObject:object];
}

@end
