//
//  OxKeyValue.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>

// Utilities for key value observing.

/*
 This method is meant to be invoked from 
 observeValueForKeyPath:ofObject:change:context:.  It simply 
 serializes the key path into the selector and reinvokes.  So you
 get something like:

     observeValueForFooBarOfObject:change:context:

 where foo.bar was your key-path.
 
 Just add a method definition like:
 
 - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 {
   invokeObservationSelector(self, keyPath, object, change, context);
 }
 
 to your observing class.
*/
void invokeObservationSelector(id self, NSString *keypath, id object, NSDictionary *change, void *context);
