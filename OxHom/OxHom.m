/*
 *  OxHom.m
 *
 *  Copyright 2008 Nicholas Matsakis. 
 *  The code in thie file is released to the public under the
 *  terms of the MIT License as described here:
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "OxHom.h"

@implementation OxHom

+ homWithContentsOf:(id)container 
{
	NSMutableArray *array = [NSMutableArray array];
	for (id obj in container) 
		[array addObject:obj];
	
	return [[[OxHom alloc] initWithMutableArray:array] autorelease];
}

- initWithMutableArray:(NSMutableArray*)array
{
	if ((self = [super init])) {
		a_array = array;
	}
	return self;
}

@synthesize array = a_array;

- (id) map
{
	return [[[OxHomMapProxy alloc] initWithHom:self] autorelease];
}

- (id) filter
{
	return [[[OxHomFilterProxy alloc] initWithHom:self] autorelease];
}

- (OxHomFindProxy*) exists
{
	return [[[OxHomFindProxy alloc] initWithHom:self value:YES] autorelease];
}

- (OxHomFindProxy*) forAll
{
	return [[[OxHomFindProxy alloc] initWithHom:self value:NO] autorelease];
}

- (id) perform
{
	return [[[OxHomPerformProxy alloc] initWithHom:self] autorelease];
}

@end


#pragma mark -
#pragma mark Informal protocol: isTrue

@implementation NSObject (OxHomIsTrue)
- (BOOL) isTrue {
	return YES;
}
@end

@implementation NSNull (OxHomIsTrue)
- (BOOL) isTrue {
	return NO;
}
@end

@implementation NSString (OxHomIsTrue)
- (BOOL) isTrue {
	return [self length] != 0;
}
@end

@implementation NSSet (OxHomIsTrue)
- (BOOL) isTrue {
    return [self count] != 0;
}
@end

@implementation NSArray (OxHomIsTrue)
- (BOOL) isTrue {
	return [self count] != 0;
}
@end

@implementation NSNumber (OxHomIsTrue)
- (BOOL) isTrue {
	return [self boolValue];
}
@end

#pragma mark -
#pragma mark NSArray Categories

@implementation NSArray (OxHomHelpers)
- (id) performForEach {
	return [[OxHom homWithContentsOf:self] perform];
}
@end

#pragma mark -
#pragma mark Internal Helper Functions and Proxy Classes

NSMethodSignature *veryGeneralSignature()
{
    NSMutableString *sigStr = [NSMutableString stringWithUTF8String:@encode(id)];
	[sigStr appendFormat:@"%s", @encode(id)];  // self
	[sigStr appendFormat:@"%s", @encode(SEL)]; // selector
    return [NSMethodSignature signatureWithObjCTypes:[sigStr UTF8String]];
}

NSMethodSignature *copiedSigWithNewReturnType(NSMethodSignature *sig,
                                              const char *newRetType)
{
    NSMutableString *sigStr = [NSMutableString stringWithUTF8String:newRetType];
    for (int i = 0, c = [sig numberOfArguments]; i < c; i++)
        [sigStr appendFormat:@"%s", [sig getArgumentTypeAtIndex:i]];
    return [NSMethodSignature signatureWithObjCTypes:[sigStr UTF8String]];
}

BOOL interpretReturnValueAsBool(NSInvocation *anInvocation) {
    const char *retType = [[anInvocation methodSignature] methodReturnType];
    if (!strcmp(retType, @encode(BOOL))) {
        BOOL v;
        [anInvocation getReturnValue:&v];
        return v;
    } else if (!strcmp(retType, @encode(id))) {
        id v;
        [anInvocation getReturnValue:&v];
        if (v == nil)
            return NO;
        return [v isTrue]; // as in Python, let the type decide what true means
    } else if (!strcmp(retType, @encode(int))) {
        int v;
        [anInvocation getReturnValue:&v];
        return v != 0;
    } 
    
    int len = [[anInvocation methodSignature] methodReturnLength];        
    char *buf = malloc(len);
    [anInvocation getReturnValue:buf];
    for (int i = 0; i < len; i++) 
        if (buf[i]) {
            free(buf);
            return YES;
        }
    free(buf);
    return NO;            
}

id interpretReturnValueAsId(NSInvocation *anInvocation) {
    const char *retType = [[anInvocation methodSignature] methodReturnType];
#   define GEN(T, C) \
if (!strcmp(retType, @encode(T))) { \
T v; \
[anInvocation getReturnValue:&v]; \
return [NSNumber numberWith##C:v]; \
}
    if (!strcmp(retType, @encode(id))) {
        id v;
        [anInvocation getReturnValue:&v];
        return v;
    } 
#   include "OxHomNumericTypes.h"
#   undef GEN
    
    [NSException raise:@"OxCannotConvertToId"
                format:@"OxHom: Cannot convert type %s to an object",
     retType];
    return nil;
}

unsigned sizeofEncodedType(const char *type) {
    struct type_info_t {
        const char *encodedText;
        unsigned size;
    } infoArray[] = {
#       define GEN(t, X) { @encode(t), sizeof(t) },
        GEN(id,)
        GEN(SEL,)
        GEN(void*,)
        GEN(char*,)
#       include "OxHomNumericTypes.h"
#       undef GEN
        { NULL, 0 }
    };
    
    for (struct type_info_t *t = infoArray; t->encodedText != NULL; t++) {
        if (!strcmp(t->encodedText, type))
            return t->size;
    }
    
    return 0; // XXX throw exception
}

NSInvocation *copiedInvocation(NSMethodSignature *sig, NSInvocation *src) {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    void *buf = malloc(sizeof(id));
    unsigned maxSize = sizeof(id);
    int numArgs = [sig numberOfArguments];
    for (int i = 0; i < numArgs; i++) {
        const char *argType = [sig getArgumentTypeAtIndex:i];
        unsigned argSize = sizeofEncodedType(argType);
        assert(argSize > 0);
        if (argSize > maxSize) {
            buf = realloc(buf, argSize);
            maxSize = argSize;
        }
        [src getArgument:buf atIndex:i];
        [inv setArgument:buf atIndex:i];
    }
    free(buf);
    return inv;
}

@implementation OxHomExpandMarker

+ homExpandMarkerWith:(id)container {
	return [[[self alloc] initWithContainer:container] autorelease];
}

- initWithContainer:(id)container {
	if ((self = [super init])) {
		m_container = container;
	}
	return self;
}
	
- container {
	return m_container;
}

- (id) perform {
	return [[OxHom homWithContentsOf:m_container] perform];
}

@end


@implementation OxHomProxy

- initWithHom:(OxHom*)hom {
	m_hom = [hom retain];
    return self;
}

- (void)dealloc {
    [m_hom release];
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	if ([m_hom.array count] == 0)
		return veryGeneralSignature();
	
    // Check the signature of some item in the container (here we assume that
    // they all respond alike!)
    id item = [m_hom.array objectAtIndex:0];
	return [item methodSignatureForSelector:aSelector];
}

// invoked by expandInvocation:startingWithArgument:, should return NO if 
// we do not need to continue expanding
- (BOOL) processFullyExpandedInvocation:(NSInvocation*)anInvocation
{
	return NO; 
}

- (BOOL) expandInvocation:(NSInvocation*)anInvocation startingWithArgument:(int)argIndex
{
	NSMethodSignature *sig = [anInvocation methodSignature];

	int numArgs = [sig numberOfArguments];
	if (argIndex >= numArgs) {
		[anInvocation invoke];
		return [self processFullyExpandedInvocation:anInvocation];
	}
	
	const char *argType = [sig getArgumentTypeAtIndex:argIndex];
	if (!strcmp(argType, @encode(id))) {
		id argValue;
		[anInvocation getArgument:&argValue atIndex:argIndex];
		if ([argValue isKindOfClass:[OxHomExpandMarker class]]) {
			@try {
				for (id item in [argValue container]) {
					[anInvocation setArgument:&item atIndex:argIndex];
					if (![self expandInvocation:anInvocation startingWithArgument:argIndex+1])
						return NO;
				}
				return YES;
			} @finally {
				[anInvocation setArgument:&argValue atIndex:argIndex];
			}
		}
	}
	
	return [self expandInvocation:anInvocation startingWithArgument:argIndex+1];
}

- (BOOL) expandInvocation:(NSInvocation*)anInvocation {
	return [self expandInvocation:anInvocation startingWithArgument:2];
}

@end

@implementation OxHomFindProxy

- initWithHom:(OxHom*)hom value:(BOOL)value {
	if ((self = [super initWithHom:hom])) {
		m_value = value;
	}
	return self;
}

- (BOOL) processFullyExpandedInvocation:(NSInvocation*)anInvocation
{
	// return NO to stop searching once we find m_value
	return !(interpretReturnValueAsBool(anInvocation) == m_value);
}

- (BOOL) _homFound {
	return m_found;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	for (id item in m_hom.array) {
		[anInvocation setTarget:item];
		if (![self expandInvocation:anInvocation]) {
			m_found = YES;
			return;
		}
	}
	m_found = NO;
}

@end

@implementation OxHomPerformProxy

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	for (id item in m_hom.array) {
		[anInvocation setTarget:item];
		[self expandInvocation:anInvocation];
	}
}

- (BOOL) processFullyExpandedInvocation:(NSInvocation*)anInvocation
{
	return YES;
}

@end

@implementation OxHomMapProxy

- (BOOL) processFullyExpandedInvocation:(NSInvocation*)anInvocation
{
	id res = interpretReturnValueAsId(anInvocation);
	[m_values addObject:res];
	return YES;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	// keep an item if ANY of the expanded entries
	// is YES. 
	NSMutableArray *array = m_hom.array;
	m_values = [[NSMutableArray alloc] initWithCapacity:1];
	
	for (int i = 0; i < [array count]; i++) {
		[m_values removeAllObjects];
        [anInvocation setTarget:[array objectAtIndex:i]];
		[self expandInvocation:anInvocation];
		
		if ([m_values count] == 1) {
			[m_hom.array replaceObjectAtIndex:i withObject:[m_values objectAtIndex:0]];	
		} else {
			[m_hom.array replaceObjectAtIndex:i withObject:[NSArray arrayWithArray:m_values]];
		}
    }
	
	[m_values release];
	m_values = nil;
} 

@end

@implementation OxHomFilterProxy

- (BOOL) processFullyExpandedInvocation:(NSInvocation*)anInvocation
{
	if (interpretReturnValueAsBool(anInvocation))
		return NO;
	return YES;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	// keep an item if ANY of the expanded entries
	// is YES. 
	NSMutableArray *array = m_hom.array;
	for (int i = 0; i < [array count]; i++) {
		m_found = NO;
        [anInvocation setTarget:[array objectAtIndex:i]];
		
		if ([self expandInvocation:anInvocation])
			// if we ever find one that returns true, then this will return NO because 
			// we were permitted to stop the search
			[array removeObjectAtIndex:i--];
    }
} 

@end
