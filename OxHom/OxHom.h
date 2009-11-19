/*
 *  OxHom.h
 *
 *  Copyright 2008 Nicholas Matsakis. 
 *  The code in thie file is released to the public under the
 *  terms of the MIT License as described here:
 *  http://www.opensource.org/licenses/mit-license.php
 *
 *  This code is purposefully independent from the
 *  rest of the Oaxaca library!
 */

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark Macros -- use these most of the time

// Macros for map, filter, etc that work even for
// messages with BOOL return type.  These make
// use of GCCs ability to treat a block as an
// expression.  To use:
//
// NSArray *filteredArray = OxFilter(array, hasPrefix:foo);
// NSArray *mappedArray = OxMap(array, varArgsMethods:work, too);
//
// You can also insert OxForEach() to cause iteration over any
// argument in the message.  
//
// To filter and map when the receiver is not a container, use:
// 
// NSArray *filteredArray = OxIFilter(object, hasPrefix:OxForEach(array))

#define OxFilter(_container, ...) \
        ({OxHom *hom = [OxHom homWithContentsOf:_container]; [(id)[hom filter] __VA_ARGS__]; hom.array;})
#define OxMap(_container, ...) \
        ({OxHom *hom = [OxHom homWithContentsOf:_container]; [(id)[hom map] __VA_ARGS__]; hom.array;})
#define OxExists(_container, ...) \
	    ({id hom = [[OxHom homWithContentsOf:_container] exists]; [hom __VA_ARGS__]; [hom _homFound];})
#define OxForAll(_container, ...) \
        ({id hom = [[OxHom homWithContentsOf:_container] forAll]; [hom __VA_ARGS__]; ![hom _homFound];})
#define OxPerform(_container, ...) \
        ({id hom = [[OxHom homWithContentsOf:_container] perform]; [hom __VA_ARGS__]; nil;})

#define OxForEach(_container) \
        [OxHomExpandMarker homExpandMarkerWith:(_container)]
#define OxIFilter(_object, ...) \
        [OxFilter([NSArray arrayWithObject:(_object)], __VA_ARGS__) objectAtIndex:0]
#define OxIMap(_object, ...) \
        [OxMap([NSArray arrayWithObject:(_object)], __VA_ARGS__) objectAtIndex:0]
#define OxIExists(_object, ...) \
        OxExists([NSArray arrayWithObject:(_object)], __VA_ARGS__)
#define OxIForAll(_object, ...) \
		OxForAll([NSArray arrayWithObject:(_object)], __VA_ARGS__)

#pragma mark -
#pragma mark OxHom -- for repeated maps and filters

// OxHom encapsulates a mutable array
// which can be modified or search via Higher-Order-Messaging.
// Normally, you will want to use the macros above rather
// than interact directly with this class.  
// The exception is when you are performing multiple
// successive operations, like repeated maps and filters.
// In that case, OxHom can be convenient and efficient.

@class OxHomProxy;
@class OxHomFindProxy;

@interface OxHom : NSObject {
	NSMutableArray *a_array;
}

+ homWithContentsOf:(id)container;

- initWithMutableArray:(NSMutableArray*)array;

// The internal array of this HOM object.
// You can use this to read the final
// result of HOM operations or simply make
// your own in-place changes.
@property (retain) NSMutableArray *array;

// Mutators:
//
// The objects resulting from these calls are trampolines
// which will mutate self.array with every message they receive.
//
// IMPORTANT: The return value of messages sent to these trampolines
// is undefined.  Therefore, use the macros 
// OxExists and OxForAll!

- (id) map;
- (id) filter;

// Queries:
//
// The objects resulting from this call are trampolines
// which search self.array to see if there are objects
// within that return true/false in response to any
// message they receive.  Because the return value from those
// messages is undefined, it's more convenient to use the 
// OxExists() and OxForAll() macros than to call these directly!

- (OxHomFindProxy*) exists; // purposefully did not use id -- use OxExists macro!
- (OxHomFindProxy*) forAll; // purposefully did not use id -- use OxForAll macro!

// Plain forwarding:
//
// The objects resulting from this call are trampolines
// which will forward messages they receive to each item
// in self.array as appropriate.  The return value from
// these messages is undefined.

- (id) perform;

@end

#pragma mark -
#pragma mark Informal protocol: isTrue

// Decides whether an object should be considered "true".
// We use Pythonic criteria, but you may choose to apply
// a different choice.

@interface NSObject (OxHomIsTrue)
- (BOOL) isTrue; // objects are true by default
@end

@interface NSNull (OxHomIsTrue)
- (BOOL) isTrue; // always false
@end

@interface NSString (OxHomIsTrue)
- (BOOL) isTrue; // non-empty strings are true
@end

@interface NSSet (OxHomIsTrue)
- (BOOL) isTrue; // non-empty sets are true
@end

@interface NSArray (OxHomIsTrue)
- (BOOL) isTrue; // non-empty arrays are true
@end

@interface NSNumber (OxHomIsTrue)
- (BOOL) isTrue; // same as boolValue
@end

#pragma mark -
#pragma mark NSArray Categories

@interface NSArray (OxHomHelpers)
- performForEach;
@end

#pragma mark -
#pragma mark Internal -- helper functions and proxy classes

// Hopefully you won't need these, but they are exposed in case
// they prove useful.

// A signature that accepts any arguments and returns id.
NSMethodSignature *veryGeneralSignature();

// Interprets various kinds of return values as boolean.
// For numeric constants, zero is false.
// For objects, it sends isTrue.
// Otherwise, it checks the raw memory and if any non-zero
// bytes are found the values is considered true.
BOOL interpretReturnValueAsBool(NSInvocation *anInvocation); 

// If the return value is not already an object, tries
// to wrap it in NSNumber if appropriate.
id interpretReturnValueAsId(NSInvocation *anInvocation); 

// Number of bytes occupied by the encoded string 'type'.
// (See @encode()).
unsigned sizeofEncodedType(const char *type);

@interface OxHomExpandMarker : NSObject {
	id m_container;
}

+ homExpandMarkerWith:(id)container;
- initWithContainer:(id)container;
- container;
- (id) perform; // allows you to write [[OxForEach(array) perform] foo];
@end

@interface OxHomProxy : NSProxy {
	OxHom *m_hom;
}
- initWithHom:(OxHom*)hom;
@end

@interface OxHomFindProxy : OxHomProxy {
	BOOL m_value;
	BOOL m_found;
}
- initWithHom:(OxHom*)hom value:(BOOL)value;
- (BOOL) _homFound;
@end

@interface OxHomPerformProxy : OxHomProxy {
}
@end

@interface OxHomMapProxy : OxHomProxy {
	NSMutableArray *m_values;
}
@end

@interface OxHomFilterProxy : OxHomProxy {
	BOOL m_found;
}
@end