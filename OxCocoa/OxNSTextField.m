//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSTextField.h"


@implementation NSTextField (Oaxaca2)

- (void) configureIntoLabel {
	[self setBordered:NO];
	[self setDrawsBackground:NO];
	[self setEditable:NO];
}

@end
