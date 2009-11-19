//
//  OxNSArrayController.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>

@interface NSArrayController (Oaxaca2)

/* 
 Returns the selected object or nil; preferable to selection 
 because it does not return an annoying proxy object.  
 
 Warning: Not KVO observable! 
 */
- (id) selectedObject;

@end
