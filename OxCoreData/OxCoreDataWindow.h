//
//  OxCoreDataWindow.h
//  Flash2
//
//  Created by Niko Matsakis on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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
