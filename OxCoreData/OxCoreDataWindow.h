//
//  Copyright 2009 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//


#import <Cocoa/Cocoa.h>


@interface OxCoreDataWindow : NSWindowController {
	NSTreeController *treeController;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectModel *managedObjectModel;
	NSArray *contentArray;
}
@property(retain) IBOutlet NSTreeController *treeController;
@property(retain) NSManagedObjectContext *managedObjectContext;
@property(retain) NSManagedObjectModel *managedObjectModel;
@property(retain) NSArray *contentArray;

+ openedCoreDataWindowWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
							managedObjectModel:(NSManagedObjectModel*)aManagedObjectModel;

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
			managedObjectModel:(NSManagedObjectModel*)aManagedObjectModel;

@end
