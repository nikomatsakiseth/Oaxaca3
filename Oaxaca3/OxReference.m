/*
 Oaxaca: Useful Cocoa Library
 Copyright (C) 2005, Niko Matsakis (niko@alum.mit.edu)
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "OxReference.h"
#import "Ox.h"

@implementation OxWeakReference

+ referenceWithObject:object
{
    return [[[self alloc] initWithObject:object] autorelease];
}

- initWithObject:object
{
    if ((self = [super init])) {
        referencedObject = object;
    }
    return self;
}

- referencedObject
{
    return referencedObject;
}

- (unsigned) hash
{
    return (unsigned)(intptr_t)referencedObject;
}

- (BOOL) isEqual:obj
{
    if (![obj isKindOfClass:[OxWeakReference class]]) 
        return NO;
    return ((OxWeakReference*)obj)->referencedObject == referencedObject;
}

- copyWithZone:(NSZone*)zone
{
    return [self retain];
}

@end

@implementation OxReference

- initWithObject:object
{
    if ((self = [super initWithObject:object])) {
        [referencedObject retain];
    }
    return self;
}

- (void) dealloc
{
    [referencedObject release];
    [super dealloc];
}

@end

@implementation NSObject (OxReference)
- (OxReference*) reference {
    return [OxReference referenceWithObject:self];
}
@end

@implementation NSDictionary (OxReference)

+ (NSMutableDictionary*) dictionaryWithValues:(NSArray*)values pointerKeys:(NSArray*)keys
{
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    int max = [values count];
    if (max > [keys count]) max = [keys count];
    for (int i = 0; i < max; i++) {
        [res setObject:[values objectAtIndex:i]
            forPointer:[keys objectAtIndex:i]];
    }
    return res;
}

- objectForPointer:key
{
    return [self objectForKey:[OxWeakReference referenceWithObject:key]];
}

@end

@implementation NSMutableDictionary (OxReference)

- (void) setObject:object forPointer:key
{
    [self setObject:object forKey:[OxReference referenceWithObject:key]];
}

@end