//
//  OxBinder.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>


@interface OxBinder : NSObject {
    NSMutableArray *m_boundPaths;
}

- init;

// Ensures that the value at object1/keyPath1 always has the 
// same value as the value at object2/keyPath2.  *Takes the
// current value of object2/keyPath2 as the initial value,
// hence the term Master object.*
- (void) bindKeyPath:(NSString*)keyPath1
       ofSlaveObject:(id)object1
           toKeyPath:(NSString*)keyPath2
      ofMasterObject:(id)object2;

@end
