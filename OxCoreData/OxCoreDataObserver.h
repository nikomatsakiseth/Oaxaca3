//
//  OxCoreDataObserver.h
//  Flash2
//
//  Created by Niko Matsakis on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Ox.h"

@protocol OxCoreDataObserver

// A test to run on each changed instance to decide if you
// are intered.
- (BOOL(^)(NSManagedObject *))observedObjectsOfInterest;

// Invoked when instances matching observedObjectsOfInterest are updated.
- (void)didUpdate:(NSSet*)instances;

// Invoked when instances matching observedObjectsOfInterest are inserted.
- (void)didInsert:(NSSet*)instances;

// Invoked when instances matching observedObjectsOfInterest are deleted.
- (void)didDelete:(NSSet*)instances;

@end

@interface NSManagedObjectContext (OxCoreDataObserver)
- (void)addOxCoreDataObserver:(id<OxCoreDataObserver>)observer;
- (void)removeOxCoreDataObserver:(id)observer;
@end
