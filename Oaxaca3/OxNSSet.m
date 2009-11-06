//
//  OxNSSet.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSSet.h"

@implementation NSSet (Oaxaca2)

+ (id) setWithUnionOfArrays:(NSArray*)array, ...
{
	va_list ap;    
    va_start(ap, array);    
	
	NSMutableSet *result = [NSMutableSet set];
	while (array != nil) {
		[result addObjectsFromArray:array];
		array = va_arg(ap, NSArray*);
	}
	va_end(ap);
	
	return [self setWithSet:result];
}

+ (id) setWithUnionOfSets:(NSSet*)set, ...
{
	va_list ap;    
    va_start(ap, set);    
	
	NSMutableSet *result = [NSMutableSet set];
	while (set != nil) {
		[result unionSet:set];
		set = va_arg(ap, NSSet*);
	}
	va_end(ap);
	
	return [self setWithSet:result];
}

#pragma mark -
#pragma mark Misc

- (NSString*) shortDescription {
    NSMutableString *res = [NSMutableString string];

    [res appendString:@"{"];
    for (id obj in self) {
        [res appendFormat:@" %@", [obj shortDescription]];
    }
    [res appendString:@" }"];
    
    return res;
}

- (BOOL) isEmpty {
    return [self count] == 0;
}

- (NSArray*) toArray {
	NSMutableArray *array = [NSMutableArray array];
	for(id obj in self)
		[array addObject:obj];
	return array;
}

@end
