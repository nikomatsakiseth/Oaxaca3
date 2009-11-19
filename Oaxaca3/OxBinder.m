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

static void *SLAVE = "slave";
static void *MASTER = "master";


@implementation OxBinder

- init {
    [super init];
    m_boundPaths = [NSMutableArray array];
    return self;
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
                 options:0      // NSKeyValueObservingOptions
                 context:SLAVE];
    
    [objectM addObserver:self
              forKeyPath:keyPathM
                 options:0
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
    
    for (NSArray *bindingInfo in m_boundPaths) {
        if ([bindingInfo objectAtIndex:objectIdx] == object &&
            [[bindingInfo objectAtIndex:keyPathIdx] isEqual:keyPath])
        {
            // find the opposite binding and update it.
            // check first that it needs to change to prevent 
            // infinite cycles.
            id value = [object valueForKeyPath:keyPath];
            id oppObject = [bindingInfo objectAtIndex:oppObjectIdx];
            id oppKeyPath = [bindingInfo objectAtIndex:oppKeyPathIdx];
            id oppValue = [oppObject valueForKeyPath:oppKeyPath];
            if (oppValue != value && ![oppValue isEqual:value])
                [oppObject setValue:value forKeyPath:oppKeyPath];
        }
    }
}

@end
