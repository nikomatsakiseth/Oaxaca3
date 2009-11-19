//
//  OxNSMutableAttributedString.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSMutableAttributedString.h"


@implementation NSMutableAttributedString (Oaxaca2)

- (void) appendString:(NSString*)string {
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:string] autorelease];
    [self appendAttributedString:attrString];
}

- (void) appendString:(NSString*)string withColor:(NSColor*)color {
    NSDictionary *attr = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    [self appendString:string withAttributes:attr];
}

- (void) appendString:(NSString*)string withAttributes:(NSDictionary*)attr {
    NSAttributedString *attrString = [[[NSAttributedString alloc] initWithString:string attributes:attr] autorelease];
    [self appendAttributedString:attrString];
}

@end
