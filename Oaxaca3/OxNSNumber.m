//
//  Copyright 2009 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSNumber.h"

@implementation NSNumber (Oaxaca3)

- (NSNumber*)numberByAddingDouble:(double)amnt
{
	return [NSNumber numberWithDouble:[self doubleValue] + amnt];
}

@end
