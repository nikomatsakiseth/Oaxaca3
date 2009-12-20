//
//  Copyright 2009 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//


#import "OxCoreDataWindow.h"
#import "OxCoreData.h"
#import "OxNSArray.h"
#import "OxNSMutableArray.h"
#import "OxDebug.h"

#pragma mark -

@interface OxTreeNode : NSObject {
	NSArray *children;
}
@property(retain) NSArray *children; // must be immutable once assigned
@property(readonly) int count;
@property(readonly) BOOL leaf;
@property(readonly) NSString *stringValue;
- (void)initChildren;
@end

@interface OxEntityTreeNode : OxTreeNode {
	NSEntityDescription *entityDescription;
	NSManagedObjectContext *managedObjectContext;
}
- initWithEntityDescription:(NSEntityDescription*)anEntityDescription
	   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext;
- (void)updateArray:(NSArray*)current insertedObjects:(NSArray*)insertedObjects;
- stringValue;
@end

@interface OxToManyTreeNode : OxTreeNode {
	NSString *key;
	id ownerObject;
}

- initWithKey:(NSString*)key ownerObject:(id)object;
- stringValue;
@end

@interface OxToOneTreeNode : OxTreeNode {
	NSString *key;
	id object;
}
@property(copy) NSString *key;
@property(retain) id object;
- initWithKey:(NSString*)key object:(id)object;
- stringValue;
@end

@interface OxManagedObjectTreeNode : OxToOneTreeNode {
}
- (BOOL)isDeleted;
@end

@interface OxOtherObjectTreeNode : OxToOneTreeNode {
}
@end

#pragma mark -

@implementation OxCoreDataWindow

@synthesize treeController, managedObjectContext, managedObjectModel, contentArray;

+ openedCoreDataWindowWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
						  managedObjectModel:(NSManagedObjectModel*)aManagedObjectModel
{
	OxCoreDataWindow *window = [[self alloc] initWithManagedObjectContext:aManagedObjectContext managedObjectModel:aManagedObjectModel];
	[[window window] makeKeyAndOrderFront:self];
	return [window autorelease];						
}

- initWithManagedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
			managedObjectModel:(NSManagedObjectModel*)aManagedObjectModel
{
	if((self = [super initWithWindowNibName:@"OxCoreDataWindow"])) {
		self.managedObjectContext = aManagedObjectContext;
		self.managedObjectModel = aManagedObjectModel;
		
		NSMutableArray *entityNodes = [NSMutableArray array];
		for(NSEntityDescription *entity in [[managedObjectModel entities] sortedArrayUsingKey:@"name"]) 
		{
			OxEntityTreeNode *treeNode = [[OxEntityTreeNode alloc] initWithEntityDescription:entity
																		managedObjectContext:managedObjectContext];
			[entityNodes addObject:treeNode];
			[treeNode release];
		}
		self.contentArray = entityNodes;
	}
	return self;
}

- (void)dealloc
{
	self.managedObjectContext = nil;
	self.managedObjectModel = nil;
	self.treeController = nil;
	self.contentArray = nil;
	[super dealloc];
}

@end

#pragma mark -

@implementation OxTreeNode

@synthesize children;

- init
{
	if((self = [super init])) {
	}
	return self;
}

- (void)dealloc
{
	self.children = nil;
	[super dealloc];
}

- (NSArray *) children
{
	if(children == nil)
		[self initChildren];
	return children;
}

+ (NSSet *) keyPathsForValuesAffectingCount
{
	return OxSet(@"children");
}

- (int)count
{
	return [self.children count];
}

- (void)initChildren
{
	OxAbstract();
}

- (NSString*)stringValue
{
	return OxAbstract();
}

- (BOOL)leaf
{
	return NO;
}

@end

@implementation OxEntityTreeNode

- initWithEntityDescription:(NSEntityDescription*)anEntityDescription
	   managedObjectContext:(NSManagedObjectContext*)aManagedObjectContext
{
	if((self = [super init])) {
		entityDescription = [anEntityDescription retain];
		managedObjectContext = [aManagedObjectContext retain];
		
	}
	return self;
}

- (void)dealloc
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	
	[entityDescription release];
	[managedObjectContext release];
	[super dealloc];	 
}

- (NSString*)stringValue
{
	return [entityDescription name];
}

- (void)initChildren
{
	NSArray *objects = [managedObjectContext allObjectsOfEntityType:[entityDescription name]];
	[self updateArray:[NSArray array] insertedObjects:objects];
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(objectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:managedObjectContext];	
}

- (void)objectsDidChange:(NSNotification*)notification
{
	NSDictionary *userInfo = [notification userInfo];	
	NSSet *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
	NSSet *insertedObjects = [userInfo objectForKey:NSInsertedObjectsKey];
	
	if([insertedObjects count] || [deletedObjects count])
		[self updateArray:self.children insertedObjects:[insertedObjects allObjects]];
}

- (void)updateArray:(NSArray*)current insertedObjects:(NSArray*)insertedObjects
{
	OxLog(@"Entity %@: Updating array with %d inserted objects.", [entityDescription name], [insertedObjects count]);
	
	NSArray *retained = [current filteredArrayUsingBlock:^(id obj) {
		return ![obj isDeleted];
	}];
	
	NSArray *created = [insertedObjects mappedArrayUsingBlock:^id (id obj) {
		return [[[OxManagedObjectTreeNode alloc] initWithKey:nil object:obj] autorelease];
	}];
	
	self.children = [retained arrayByAddingObjectsFromArray:created];
}

@end
	
@implementation OxToOneTreeNode

@synthesize key, object;

- initWithKey:(NSString*)aKey object:(id)anObject
{
	if((self = [super init])) {
		self.key = aKey;
		self.object = anObject;
	}
	return self;
}

- (void)dealloc
{
	self.key = nil;
	self.object = nil;
	[super dealloc];
}

// In general, description is not observable, but if it is:
+ (NSSet *) keyPathsForValuesAffectingStringValue
{
	return OxSet(@"object.description");
}

- (NSString*)stringValue
{
	if(key)
		return OxFmt(@"%@: %@", key, object);
	return [object description];
}

- (OxToOneTreeNode*)replacementTreeNode:(id)aNewObject
{
	return [[[[self class] alloc] initWithKey:key object:aNewObject] autorelease];
}

@end

@implementation OxManagedObjectTreeNode

- (void)dealloc
{
	if(children != nil) {
		NSEntityDescription *entity = [object entity];
		for(NSString *attributeName in [[entity attributesByName] allKeys])
			[object removeObserver:self forKeyPath:attributeName];
			
		NSDictionary *relationships = [entity relationshipsByName];
		for(NSString *relationshipName in [relationships allKeys]) {
			NSRelationshipDescription *relDesc = [relationships objectForKey:relationshipName];
			if(![relDesc isToMany])
				[object removeObserver:self forKeyPath:relationshipName];
		}
	}
	
	[super dealloc];
}

- (void)initChildren
{
	NSEntityDescription *entity = [object entity];
	
	NSMutableArray *newChildren = [[NSMutableArray alloc] init];
	
	NSDictionary *attributes = [entity attributesByName];
	NSArray *attributeNames = [[attributes allKeys] sortedArrayUsingSelector:@selector(compare:)];	
	for(NSString *attributeName in attributeNames) {
		id value = [object valueForKey:attributeName];
		OxOtherObjectTreeNode *treeNode = [[OxOtherObjectTreeNode alloc] initWithKey:attributeName object:value];
		[newChildren addObject:treeNode];
		[treeNode release];
		 
		[object addObserver:self forKeyPath:attributeName options:0 context:nil];
	}
	
	NSDictionary *relationships = [entity relationshipsByName];
	NSArray *relationshipNames = [[relationships allKeys] sortedArrayUsingSelector:@selector(compare:)];	
	for(NSString *relationshipName in relationshipNames) {
		NSRelationshipDescription *relDesc = [relationships objectForKey:relationshipName];
		
		OxTreeNode *treeNode;
		if([relDesc isToMany]) {
			treeNode = [[OxToManyTreeNode alloc] initWithKey:relationshipName ownerObject:object];
		} else {
			id value = [object valueForKey:relationshipName];
			treeNode = [[OxManagedObjectTreeNode alloc] initWithKey:relationshipName object:value];
			
			[object addObserver:self forKeyPath:relationshipName options:0 context:nil];
		}
		[newChildren addObject:treeNode];
		[treeNode release];		
	}
	
	self.children = newChildren;
	[newChildren release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)anObject change:(NSDictionary *)change context:(void *)context
{
	// keyPath is always the name of some key of object
	NSMutableArray *updatedChildren = [children mutableCopy];
	for(int i = 0, c = [updatedChildren count]; i < c; i++) {
		id treeNode = [updatedChildren objectAtIndex:i];
		if([[treeNode key] isEqual:keyPath]) {
			// Replace tree node with another of same class:
			id replacement = [treeNode replacementTreeNode:[object valueForKey:keyPath]];
			[updatedChildren replaceObjectAtIndex:i withObject:replacement];
			break;
		}
	}
	
	self.children = updatedChildren;
	[updatedChildren release];
}

- (BOOL)isDeleted
{
	return [object isDeleted];
}

@end

@implementation OxToManyTreeNode

- initWithKey:(NSString*)aKey ownerObject:(id)anObject
{
	if((self = [super init])) {
		key = [aKey copy];
		ownerObject = [anObject retain];
	}
	return self;
}

- (void)dealloc
{
	if(children != nil)
		[ownerObject removeObserver:self forKeyPath:key];
	
	[key release];
	[ownerObject release];
	[super dealloc];
}

- (void)initChildren
{
	NSSet *childrenSet = [ownerObject valueForKey:key];
	NSMutableArray *initialChildren = [NSMutableArray arrayWithCapacity:[childrenSet count]];
	for(NSManagedObject *child in childrenSet) {
		OxTreeNode *treeNode = [[OxManagedObjectTreeNode alloc] initWithKey:nil object:child];
		[initialChildren addObject:treeNode];
		[treeNode release];
	}	
	self.children = initialChildren;

	[ownerObject addObserver:self forKeyPath:key options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSMutableSet *childrenSet = [NSMutableSet setWithSet:[ownerObject valueForKey:key]];
	
	// Remove tree nodes that are no longer present.
	NSMutableArray *updatedChildren = [children mutableCopy];	
	[updatedChildren filterArrayInPlaceUsingBlock:^int (id obj) { 
		return [childrenSet containsObject:[obj object]];
	}];
		
	// Add tree nodes that are not yet present.
	for(OxToOneTreeNode *existingNode in updatedChildren)
		[childrenSet removeObject:existingNode.object];
	for(NSManagedObject *child in childrenSet) {
		OxTreeNode *treeNode = [[OxManagedObjectTreeNode alloc] initWithKey:nil object:child];
		[updatedChildren addObject:treeNode];
		[treeNode release];
	}

	self.children = updatedChildren;
	[updatedChildren release];
}

- (NSString*)stringValue
{
	return OxFmt(@"%@: %d objects", key, [[ownerObject valueForKey:key] count]);
}

@end

@implementation OxOtherObjectTreeNode

- (void)initChildren
{
}

- (BOOL)leaf
{
	return YES;
}

@end
