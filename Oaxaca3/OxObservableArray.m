//
//  OxObservableArray.m
//  Flash2
//
//  Created by Nicholas Matsakis on 10/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "OxObservableArray.h"
#import "OxNSArray.h"
#import "OxNSMutableDictionary.h"
#import "OxNSString.h"
#import "OxNSObject.h"

@interface ListenerInfo : NSObject {
	id m_observer;
	NSKeyValueObservingOptions m_options;
	void *m_context;
	NSString *m_keyPath;
	NSString *m_key;
}
- initWithObserver:(id)observer options:(NSKeyValueObservingOptions)options context:(void*)context keyPath:(NSString*)keyPath;
- (void) dealloc;
- (void) observe:(id)object;
- (void) unobserve:(id)object;
- (void) willChange:(id)array;
- (void) didChange:(id)array;
- (BOOL) appliesToObserver:(id)object keyPath:(NSString*)keyPath;
@end

@implementation ListenerInfo

- initWithObserver:(id)observer options:(NSKeyValueObservingOptions)options context:(void*)context keyPath:(NSString*)keyPath
{
	if ((self = [super init])) {
		m_observer = [observer retain];
		m_options = options;
		m_context = context;
		m_keyPath = [keyPath retain];
		m_key = [m_keyPath stringBefore:@"."];
	}
	return self;
}

- (void) dealloc {
	[m_observer release];
	[m_keyPath release];
	[super dealloc];
}

- (void) observe:(id)object {
	[object addObserver:m_observer forKeyPath:m_keyPath options:m_options context:m_context];
}

- (void) unobserve:(id)object {
	[object removeObserver:m_observer forKeyPath:m_keyPath];
}

- (void) willChange:(id)array {
	[array willChangeValueForKey:m_key];
}

- (void) didChange:(id)array {
	[array didChangeValueForKey:m_key];
}

- (BOOL) appliesToObserver:(id)object keyPath:(NSString*)keyPath {
	return m_observer == object && [m_keyPath isEqual:keyPath];
}

@end

// Basic idea: maintain class invariant that all objects are being observed.

@interface OxObservableArray (Private)
- (void) unobserve:(id)object;
@end

@implementation OxObservableArray

- init {
	if ((self = [super init])) {
		m_array = [[NSMutableArray alloc] init];
		m_observers = [[NSMutableArray alloc] init];
	}
	return self;
}

- initWithCapacity:(NSUInteger)capacity
{
	return [self init];
}

- (void) finalize {
	[self performSelector:@selector(unobserve:)	forEachObjectIn:m_array];
	[super finalize];
}

- (void) dealloc {
	[self performSelector:@selector(unobserve:)	forEachObjectIn:m_array];
	[m_array release];
	[m_observers release];
	[super dealloc];
}

#pragma mark Observer management:

- (void)addObserver:(NSObject *)observer
		 forKeyPath:(NSString *)keyPath
			options:(NSKeyValueObservingOptions)options
			context:(void *)context
{
	ListenerInfo *info = [[[ListenerInfo alloc] initWithObserver:observer options:options context:context keyPath:keyPath] autorelease];
	[m_observers addObject:info];
	NSIndexSet *allIndices = [m_array indexSetWithAllIndices];
	[m_array addObserver:observer toObjectsAtIndexes:allIndices forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath
{
	NSIndexSet *allIndices = [m_array indexSetWithAllIndices];
	[m_array removeObserver:observer fromObjectsAtIndexes:allIndices forKeyPath:keyPath];
	
	// for some reason, the predice version caused trouble with GC complaining about resurrected objects
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"m_observer != %@ OR m_keyPath != %@", observer, keyPath];
	//[m_observers filterUsingPredicate:predicate];
	for (int i = 0; i < [m_observers count]; i++) {
		ListenerInfo *info = [m_observers objectAtIndex:i];
		if ([info appliesToObserver:observer keyPath:keyPath])
			[m_observers removeObjectAtIndex:i--];
	}
}

- (void) observe:(id)object
{
	[m_observers makeObjectsPerformSelector:@selector(observe:) withObject:object];
}

- (void) unobserve:(id)object
{
	[m_observers makeObjectsPerformSelector:@selector(unobserve:) withObject:object];
}

- (void) willChange
{
	[m_observers makeObjectsPerformSelector:@selector(willChange:) withObject:self];	
}

- (void) didChange
{
	[m_observers makeObjectsPerformSelector:@selector(didChange:) withObject:self];	
}

#pragma mark Minimum methods for NSArray which must be overridden:

- (int) count 
{
	return [m_array count];
}

- objectAtIndex:(int)index 
{
	return [m_array objectAtIndex:index];
}

#pragma mark Minimum methods for NSMutableArray which must be overridden:

- (void) insertObject:(id)object atIndex:(int)index {
	[self observe:object];
	[self willChange];
	[m_array insertObject:object atIndex:index];
	[self didChange];
}

- (void) removeObjectAtIndex:(int)index {
	[self unobserve:[m_array objectAtIndex:index]];
	[self willChange];
	[m_array removeObjectAtIndex:index];
	[self didChange];
}

- (void) addObject:(id)object {
	[self observe:object];
	[self willChange];
	[m_array addObject:object];
	[self didChange];
}

- (void) removeLastObject {
	[self unobserve:[m_array lastObject]];
	[self willChange];
	[m_array removeLastObject];
	[self didChange];
}

- (void) replaceObjectAtIndex:(int)index withObject:(id)object {
	[self unobserve:[m_array objectAtIndex:index]];
	[self observe:object];
	[self willChange];
	[m_array replaceObjectAtIndex:index withObject:object];
	[self didChange];
}

#pragma mark Misc.

- (NSArray*) arrayByAddingObject:(id)object {
	OxObservableArray *res = [[[OxObservableArray alloc] initWithCapacity:[self count]+1] autorelease];
	[res addObjectsFromArray:self];
	[res addObject:object];
	return res;
}

@end
