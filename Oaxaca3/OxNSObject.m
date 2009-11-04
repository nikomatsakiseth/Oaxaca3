//
//  OxNSObject.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSObject.h"
#import "OxNSArray.h"
#import "Ox.h"

@implementation NSObject (Oaxaca2)

- (NSString*) shortDescription
{
    return [self description];
}

- (void) performSelector:(SEL)selector forEachObjectIn:(id)objects
{
    for (id argument in objects)
        [self performSelector:selector withObject:argument];
}

- (BOOL) containedIn:(id)container 
{
	return [container containsObject:self];
}

- (BOOL) notContainedIn:(id)container 
{
	return ![self containedIn:container];
}

- (id) perform
{
	return [OxArr(self) performForEach];
}

#pragma mark -
#pragma mark Misc Key-Value

- (NSArray*) arrayWithValuesForKeys:(NSArray*)keys
{
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *key in keys) {
        [result addObject:[self valueForKey:key]];
    }
    return result;
}

- (NSArray*) arrayWithValuesForKeys2:(NSString*)firstKey, ...
{
    NSMutableArray *result = [NSMutableArray array];
    
    if (firstKey != nil) {
        [result addObject:[self valueForKey:firstKey]];
        va_list ap;
        va_start(ap, firstKey);
        NSString *nextKey;
        while ((nextKey = va_arg(ap, NSString*)))
            [result addObject:[self valueForKey:firstKey]];
        va_end(ap);
    }
    
    return result;
}

#pragma mark -
#pragma mark Tuples

- (NSArray*) pairedWith:(id)object {
    return [self tupleWith:object];
}

- (NSArray*) tupleWith:(id)object {
    return [NSArray arrayWithObjects:self, object, nil];
}

- (NSArray*) tupleWith:(id)object1 with:(id)object2 {
    return [NSArray arrayWithObjects:self, object1, object2, nil];
}


@end
