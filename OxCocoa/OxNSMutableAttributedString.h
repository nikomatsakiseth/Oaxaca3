//
//  OxNSMutableAttributedString.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Cocoa/Cocoa.h>


@interface NSMutableAttributedString (Oaxaca2)

- (void) appendString:(NSString*)string;
- (void) appendString:(NSString*)string withColor:(NSColor*)color;
- (void) appendString:(NSString*)string withAttributes:(NSDictionary*)attr;

@end
