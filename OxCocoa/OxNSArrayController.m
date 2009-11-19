//
//  OxNSArrayController.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSArrayController.h"
#import "Ox.h"

@implementation NSArrayController (Oaxaca2)

- (id) selectedObject
{
    unsigned int selidx = [self selectionIndex];
    if (selidx != NSNotFound) 
        return [[self arrangedObjects] objectAtIndex:selidx];
    return nil;
}

@end
