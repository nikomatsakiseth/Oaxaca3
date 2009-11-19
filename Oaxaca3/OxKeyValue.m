//
//  OxKeyValue.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxKeyValue.h"
#import "OxNSString.h"
#import "OxNSArray.h"

void invokeObservationSelector(id self, NSString *keyPath, id object, NSDictionary *change, void *context) {
    NSArray *components = [keyPath componentsSeparatedByString:@"."];
    NSArray *capComponents = [components mapByPerformingSelector:@selector(stringWithCapitalizedFirstLetter)];
    NSString *combComponents = [capComponents componentsJoinedByString:@""];
    NSString *selString = [NSString stringWithFormat:
                          @"observeValueFor%@OfObject:change:context:", combComponents];
    SEL sel = sel_registerName([selString UTF8String]);
    
    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setTarget:self];
    [inv setSelector:sel];
    [inv setArgument:&object atIndex:2];
    [inv setArgument:&change atIndex:3];
    [inv setArgument:&context atIndex:4];
    [inv invoke];
}
