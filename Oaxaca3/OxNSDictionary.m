//
//  OxNSDictionary.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSDictionary.h"


@implementation NSDictionary (Oaxaca2)

- (NSDictionary*) dictionaryWithValue:(id)value forKey:(id)key
{
	// Would be nice to make our own dictionary subclass that made this
	// more efficient.
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self];
	[dict setValue:value forKey:key];
	return dict;
}

- (NSDictionary*) dictionaryWithoutKey:(id)key
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self];
	[dict removeObjectForKey:key];
	return dict;
}

- (NSDictionary*) dictionaryWithKey:(id)newKey replacingKey:(id)oldKey;
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self];
	id value = [[dict objectForKey:oldKey] retain];
	if (value != nil) {
		[dict removeObjectForKey:oldKey];
		[dict setObject:value forKey:newKey];
		[value release];
	}
	return dict;
}


@end
