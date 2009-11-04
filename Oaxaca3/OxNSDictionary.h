//
//  OxNSDictionary.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Oaxaca2)

- (NSDictionary*) dictionaryWithValue:(id)value forKey:(id)key;
- (NSDictionary*) dictionaryWithoutKey:(id)key;
- (NSDictionary*) dictionaryWithKey:(id)newKey replacingKey:(id)oldKey;

@end
