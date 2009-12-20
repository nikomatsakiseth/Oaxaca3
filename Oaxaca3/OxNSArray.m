//
//  OxNSArray.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSArray.h"
#import "OxNSObject.h"

@implementation NSArray (Oaxaca2)

#pragma mark -
#pragma mark Sorted Arrays

- (NSArray*) sortedArrayUsingKey:(NSString*)key {
    return [self sortedArrayUsingKey:key ascending:YES];
}

- (NSArray*) sortedArrayUsingKey:(NSString*)key ascending:(BOOL)ascending {
    return [self sortedArrayUsingKey:key ascending:YES compareSelector:@selector(compare:)];
}

- (NSArray*) sortedArrayUsingKey:(NSString*)key ascending:(BOOL)ascending compareSelector:(SEL)sel {
    NSSortDescriptor *sortDes = [[[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:sel] autorelease];
    return [self sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDes]];
}

#pragma mark -
#pragma mark Python style slices

- (NSArray*) sliceFrom:(int)index {
    return [self sliceFrom:index to:[self count]];
}

- (NSArray*) sliceTo:(int)index {
    return [self sliceFrom:0 to:index];
}

- (NSArray*) sliceFrom:(int)fromIndex to:(int)toIndex {
	int count = [self count];
	
    if (fromIndex < 0) 
        fromIndex = count + fromIndex;
	if (fromIndex > count)
		fromIndex = count;
	
    if (toIndex < 0)
        toIndex = count + toIndex;
	if (toIndex > count)
		toIndex = count;
    
    if (fromIndex >= toIndex)
        return [NSArray array];
    
    NSRange range = { .location = fromIndex, .length = toIndex - fromIndex };
    return [self subarrayWithRange:range];
}

#pragma mark -
#pragma mark Misc

- (NSArray*) reversedArray
{
    NSMutableArray *reversedArray = [NSMutableArray arrayWithCapacity:[self count]];
    for (int i = [self count]-1; i >= 0; i--)
        [reversedArray addObject:[self objectAtIndex:i]];
    return reversedArray;
}

- (BOOL) isEmpty
{
    return [self count] == 0;
}

- (id) anyObject
{
    if ([self isEmpty])
        return nil;
    return [self objectAtIndex:0];
}

- (id) randomObject
{
	int count = [self count];
	if (count == 0) 
		return nil;
	int r = random();
	return [self objectAtIndex:(r % count)];
}

- (NSIndexSet*) indexSetWithAllIndices
{
	return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self count])];
}

- (BOOL) containsObjectMatchingPredicateFormat:(NSString *)format, ...
{
	va_list ap;
    va_start(ap, format);    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];    
    va_end(ap);
	for(id object in self) {
		if([predicate evaluateWithObject:object])
			return YES;
	}
	return NO;
}

- (NSArray *)filteredArrayUsingPredicateFormat:(NSString *)format, ...
{
	va_list ap;
    va_start(ap, format);    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];    
    va_end(ap);
    return [self filteredArrayUsingPredicate:predicate];
}

- (NSArray*) arrayByInsertingObject:(id)object atIndex:(int)index
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:self];
	[result insertObject:object atIndex:index];
	return result;
}

- (NSArray*) arrayByReplacingObjectAtIndex:(int)index withObject:(id)object
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:self];
	[result replaceObjectAtIndex:index withObject:object];
	return result;
}

- (NSArray*) arrayByIntersectingWithContainer:(id)array
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
	
	for(id object in self) {
		if([array containsObject:object])
			[result addObject:object];
	}
	
	return result;
}

- (id) objectMatchingPredicate:(NSPredicate *)predicate
{
	NSArray *array = [self filteredArrayUsingPredicate:predicate];
	return [array anyObject];
}
	
- (id) objectMatchingPredicateFormat:(NSString *)format, ...
{
	va_list ap;
    va_start(ap, format);    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format arguments:ap];    
    va_end(ap);
    return [self objectMatchingPredicate:predicate];
}

- (NSArray*) arrayByRemovingObjectsFromArray:(NSArray*)array
{
	NSMutableArray *result = [NSMutableArray arrayWithArray:self];
	[result removeObjectsInArray:array];
	return result;
}

- (NSArray*) zippedArrayWith:(NSArray*)array
{
	int selfcnt = [self count];
	int arraycnt = [array count];
	int cnt = (selfcnt < arraycnt ? selfcnt : arraycnt);
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:cnt];
	for (int idx = 0; idx < cnt; idx++)
		[result addObject:[[self objectAtIndex:idx] pairedWith:[array objectAtIndex:idx]]];
	return result;
}

#ifdef OX_BLOCKS_AVAILABLE
- (NSArray*) filterWithBlock:(int (^)(id obj))block
{
	int cnt = [self count];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:cnt];
	for(id obj in self)
		if(block(obj))
			[result addObject:obj];
	return result;
}
#endif

#ifdef OX_BLOCKS_AVAILABLE
- (NSArray*) filterAndMapWithBlock:(id (^)(id obj))block
{
	int cnt = [self count];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:cnt];
	for(id obj in self) {
		id obj2 = block(obj);
		if(obj2)
			[result addObject:obj2];
	}
	return result;
}
#endif

#ifdef OX_BLOCKS_AVAILABLE
- (NSArray*) mapWithBlock:(id (^)(id obj))block
{
	int cnt = [self count];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:cnt];
	for(id obj in self)
		[result addObject:block(obj)];
	return result;
}
#endif

#ifdef GCD_AVAILABLE

struct OxParMapContext {
	NSArray *array;
	dispatch_group_t group;
	dispatch_queue_t queue;
	id (^block)(id obj);
	id *results;
	int thold;
};

static void OxParMap(int minIdx, int maxIdx, struct OxParMapContext *ctx) 
{
	int cnt = maxIdx - minIdx;
	if(cnt < ctx->thold) {
		for(int i = minIdx; i < maxIdx; i++)
			ctx->results[i] = ctx->block([ctx->array objectAtIndex:i]);
	} else {
		dispatch_group_async(ctx->group, ctx->queue, ^{
			OxParMap(minIdx + cnt/2, maxIdx, ctx);
		});
		OxParMap(minIdx, minIdx + cnt/2, ctx);
	}
}

- (NSArray*) parMapWithBlock:(id (^)(id obj))block
{
	int cnt = [self count];
	
	struct OxParMapContext ctx = {
		.array = self,
		.group = dispatch_group_create(),
		.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
		.block = block,
		.results = malloc(sizeof(id) * cnt),
		.thold = 20 // XXX
	};
	OxParMap(0, cnt, &ctx);
	
	dispatch_group_wait(ctx.group, DISPATCH_TIME_FOREVER);		
	dispatch_release(ctx.group);
	NSArray *result = [NSArray arrayWithObjects:ctx.results count:cnt];
	free(ctx.results);
	return result;
}
							 
#endif

- (NSArray*) mapByPerformingSelector:(SEL)sel
{
	// Don't use mapWithBlock: here because blocks might not be available.
	int cnt = [self count];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:cnt];
	for(id obj in self)
		[result addObject:[obj performSelector:sel]];
	return result;
}

- (NSString*) shortDescription
{
	if([self isEmpty]) return @"";
	
	NSMutableString *str = [NSMutableString string];
	[str appendString:@"[ "];
	for(id object in self) {
		[str appendString:[object shortDescription]];
		[str appendString:@", "];
	}
	[str replaceCharactersInRange:NSMakeRange([str length] - 2, 2) withString:@" ]"];
	return str;
}

#pragma mark -
#pragma mark Quick Indices

- (id) _0 {
    return [self objectAtIndex:0];
}

- (id) _1 {
    return [self objectAtIndex:1];
}

- (id) _2 {
    return [self objectAtIndex:2];
}

- (id) _3 {
    return [self objectAtIndex:2];
}

@end
