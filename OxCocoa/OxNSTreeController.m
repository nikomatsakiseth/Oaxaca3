//
//  OxNsTreeController.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSTreeController.h"


@implementation NSTreeController (Oaxaca2)

- (id) selectedObject
{
    id selObjs = [self selectedObjects];
    if ([selObjs count] > 0)
        return [selObjs objectAtIndex:0];
    return nil;
}

@end
