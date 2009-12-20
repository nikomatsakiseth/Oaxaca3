//
//  OxBinder.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxBinder.h"
#import "OxDebug.h"
#import "OxNSObject.h"
#import "OxNSArray.h"
//#import "OxDisableDebug.h"

static void *SLAVE = "slave";
static void *MASTER = "master";

@implementation OxBinder

- init {
    [super init];
    m_boundPaths = [NSMutableArray array];
    return self;
}

- (void)unbindAll
{
	for(NSArray *bindingInfo in m_boundPaths) {
		NSString *keyPathS = [bindingInfo _0];
		id objectS = [bindingInfo _1];
		
		NSString *keyPathM = [bindingInfo _2];
		id objectM = [bindingInfo _3];
		
		[objectS removeObserver:self forKeyPath:keyPathS];
		[objectM removeObserver:self forKeyPath:keyPathM];
	}
	[m_boundPaths removeAllObjects];
}

- (void)releaseAndUnbindAll
{
	[self unbindAll];
	[self release];
}

- (void) dealloc
{
	[m_boundPaths release];
	[super dealloc];
}

- (void) bindKeyPath:(NSString*)keyPathS
       ofSlaveObject:(id)objectS
           toKeyPath:(NSString*)keyPathM
      ofMasterObject:(id)objectM
{
    NSArray *bindingInfo = [NSArray arrayWithObjects:keyPathS, objectS, keyPathM, objectM, nil];

    id initialValue = [objectM valueForKeyPath:keyPathM];
    [objectS setValue:initialValue forKeyPath:keyPathS];
    
    [m_boundPaths addObject:bindingInfo];
    
    [objectS addObserver:self
              forKeyPath:keyPathS
                 options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                 context:SLAVE];
    
    [objectM addObserver:self
              forKeyPath:keyPathM
                 options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
                 context:MASTER];
}

- (void) observeValueForKeyPath:(NSString *)keyPath 
                       ofObject:(id)object 
                         change:(NSDictionary *)change 
                        context:(void *)context
{
    int offset = (context == SLAVE ? 0 : 2);
    int keyPathIdx = offset;
    int objectIdx = 1 + offset;

    int oppOffset = (context == MASTER ? 0 : 2);
    int oppKeyPathIdx = oppOffset;
    int oppObjectIdx = 1 + oppOffset;
	
	id oldValue = [change valueForKey:NSKeyValueChangeOldKey];
	id newValue = [change valueForKey:NSKeyValueChangeNewKey];
	if(oldValue == [NSNull null]) oldValue = nil;
	if(newValue == [NSNull null]) newValue = nil;
	
	if(oldValue == newValue || [oldValue isEqual:newValue]) {
		OxLog(@"OxBinder: Observed non-change in %@.%@ to %@ from %@", 
			  [object shortDescription], keyPath, [newValue shortDescription], [oldValue shortDescription]);
		return;
	}
	
	OxIndented(@"OxBinder: Observed change in %@.%@ to %@ from %@", 
			   [object shortDescription], keyPath, [newValue shortDescription], [oldValue shortDescription]);
	{    
		for (NSArray *bindingInfo in m_boundPaths) {
			if ([bindingInfo objectAtIndex:objectIdx] == object &&
				[[bindingInfo objectAtIndex:keyPathIdx] isEqual:keyPath])
			{
				// find the opposite binding and update it.
				// check first that it needs to change to prevent 
				// infinite cycles.
				id oppObject = [bindingInfo objectAtIndex:oppObjectIdx];
				id oppKeyPath = [bindingInfo objectAtIndex:oppKeyPathIdx];
				id oppValue = [oppObject valueForKeyPath:oppKeyPath];
				if (oppValue != newValue && ![oppValue isEqual:newValue]) {
					OxLog(@"OxBinder: Propagating new value %@.%@ (was %@)", [oppObject shortDescription], oppKeyPath, [oppValue shortDescription]);
					[oppObject setValue:newValue forKeyPath:oppKeyPath];
				}
			}
		}
	} OxUndented;
}

@end
