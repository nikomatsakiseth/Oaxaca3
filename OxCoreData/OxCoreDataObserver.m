//
//  OxCoreDataObserver.m
//  Flash2
//
//  Created by Niko Matsakis on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OxCoreDataObserver.h"

@interface NSObject (OxCoreDataObserver)
- (void)OxCoreDataObserver:(NSNotification*)notification;
@end

@implementation NSObject (OxCoreDataObserver)

NSMutableSet *filter(NSSet *objects, BOOL (^ofInterest)(NSManagedObject*)) {
	NSMutableSet *result = nil;
	for(NSManagedObject *object in objects) {
		if(ofInterest(object)) {
			if(result == nil)
				result = [NSMutableSet setWithCapacity:[objects count]];
			[result addObject:object];
		}			
	}
	return result;
}

- (void)OxCoreDataObserver:(NSNotification*)notification
{
	id<OxCoreDataObserver> observer = (id)self;
	
	BOOL (^ofInterest)(NSManagedObject *object) = [observer observedObjectsOfInterest];
	
	NSDictionary *userInfo = [notification userInfo];
	
	{
		NSSet *insertedObjects = [userInfo objectForKey:NSInsertedObjectsKey];
		NSMutableSet *filteredInsertedObjects = filter(insertedObjects, ofInterest);
		if(filteredInsertedObjects)
			[observer didInsert:filteredInsertedObjects];
	}
	
	{
		NSSet *updatedObjects = [userInfo objectForKey:NSUpdatedObjectsKey];
		NSMutableSet *filteredUpdatedObjects = filter(updatedObjects, ofInterest);
		if(filteredUpdatedObjects)
			[observer didUpdate:filteredUpdatedObjects];
	}
	
	{
		NSSet *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
		NSMutableSet *filteredDeletedObjects = filter(deletedObjects, ofInterest);
		if(filteredDeletedObjects)
			[observer didDelete:filteredDeletedObjects];
	}		
}

@end

@implementation NSManagedObjectContext (OxCoreDataObserver)

- (void)addOxCoreDataObserver:(id<OxCoreDataObserver>)observer
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:observer selector:@selector(OxCoreDataObserver:) name:NSManagedObjectContextObjectsDidChangeNotification object:self];
}

- (void)removeOxCoreDataObserver:(id)observer
{
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:observer name:NSManagedObjectContextObjectsDidChangeNotification object:self];
}

@end
