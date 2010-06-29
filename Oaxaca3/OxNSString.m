//
//  OxNSString.m
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "OxNSString.h"
#import "Ox.h"

@implementation NSString (Oaxaca2)

- (NSString*) sliceFrom:(int)index {
	return [self sliceFrom:index to:[self length]];
}

- (NSString*) sliceFrom:(int)fromIndex to:(int)toIndex {
	int length = [self length];
	if (fromIndex < 0) fromIndex = length + fromIndex;
	if (fromIndex > length) return @"";
	if (toIndex < 0) toIndex = [self length] + toIndex;
	if (toIndex > length) toIndex = length;
	if (fromIndex >= toIndex) return @"";
	return [self substringWithRange:NSMakeRange(fromIndex, toIndex-fromIndex)];
}

- (NSString*) sliceTo:(int)index {
	return [self sliceFrom:0 to:index];
}

- (int) sharedCaseInsensitivePrefixLength:(NSString*)other
{
    return [[self commonPrefixWithString:other options:NSCaseInsensitiveSearch] length];
}

- (int) sharedCaseInsensitiveSuffixLength:(NSString*)other
{
    NSRange range[2];
    int lengths[2];
    
    lengths[0] = [self length];
    lengths[1] = [other length];
    
    int sufflength = 1;
    
    while (sufflength <= lengths[0] && sufflength <= lengths[1]) {
        for (int i = 0; i < 2; i++) {
            range[i].location = lengths[i] - sufflength;
            range[i].length = sufflength;
        }
        
        /* horribly inefficient, but who cares? */
        NSString *othersubset = [other substringWithRange:range[1]];
        NSComparisonResult comp = [self compare:othersubset options:NSCaseInsensitiveSearch range:range[0]];
        if (comp != NSOrderedSame) 
            break;
        
        sufflength += 1;
    }
    
    return sufflength - 1;
}

/* Returns this with 'string' inserted at the front */
- (NSString*) stringByPrependingString:(NSString*)string
{
	return OxFmt(@"%@%@", string, self);
}

- (NSMutableString*) stringByPurgingParentheticalText
{
    NSMutableString *result = [[[NSMutableString alloc] initWithCapacity:[self length]] autorelease];
    
    BOOL inparen = NO;
    int len = [self length];
    for (int i = 0; i < len; i++) {
        unichar ch = [self characterAtIndex:i];
        if (inparen) {
            if (ch == ')') {
                inparen = NO;
            }
        }
        else if (ch == '(') {
            inparen = YES;
        }
        else {
            [result appendFormat:@"%C", ch];
        }
    }
    
    return result;
}

- (NSMutableString*) stringByRepeating:(int)times
{
    NSMutableString *result = [[[NSMutableString alloc] initWithCapacity:[self length]*times] autorelease];
    for (int i = 0; i < times; i++)
        [result appendString:self];
    return result;
}

- (NSString*) stringWithCapitalizedFirstLetter
{
    return [NSString stringWithFormat:@"%@%@",
            [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
}

- (NSString*) stringBefore:(NSString*)str
{
	NSRange range = [self rangeOfString:str];
	if (range.location == NSNotFound)
		return self;
	return [self substringWithRange:range];
}

- (NSRange) rangeAfterRange:(NSRange)range
{
    return [self rangeAfter:range.location + range.length];
}

- (BOOL) containsString:(NSString*)string
{
    NSRange range = [self rangeOfString:string];
    if (range.location == NSNotFound) return NO;
    return YES;
}

- (BOOL) containsCharactersInSet:(NSCharacterSet*)set
{
	NSRange range = [self rangeOfCharacterFromSet:set];
	if (range.location == NSNotFound) return NO;
	return YES;
}

- (NSRange) rangeAfter:(int)index
{
    NSRange result;
    int length = [self length];
    
    if (index < -length)
        result.location = 0;               // i.e., [-100000:] yields entire string
    else if (index < 0)
        result.location = length + index;  // i.e., [-5:] yields last five characters
    else if (index > length)
        result.location = length;          // i.e., [100000:] yields empty string
    else 
        result.location = index;           // i.e., [5:] yields everything after first 5 chars
    
    NSAssert(result.location >= 0 && result.location <= length, @"Invalid range resulted");
    result.length = length - result.location;
    return result;
}

- (NSString*) strip
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSMutableArray*) componentsSeparatedByWhitespace 
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];    
    int length = [self length];
    NSMutableArray *result = [NSMutableArray array];
    
    BOOL inWord=NO;
    NSRange nonWS = NSMakeRange(0, 0);
    for (int i = 0; i < length; i++) {
        unichar c = [self characterAtIndex:i];        
        if ([whitespace characterIsMember:c]) {
            if (inWord) {
                nonWS.length = i - nonWS.location;                
                [result addObject:[self substringWithRange:nonWS]];
                inWord = NO;
            }
        }
        else {
            if (!inWord) {
                nonWS.location = i;
                inWord = YES;
            }
        }
    }
    
    if (inWord)
        [result addObject:[self substringFromIndex:nonWS.location]];
    
    return result;
    
}

- (NSMutableArray*) componentsSeparatedBy:(NSCharacterSet *)separators
{ 
    int length = [self length];
    NSMutableArray *result = [NSMutableArray array];
    
    BOOL inWord=NO;
    NSRange nonWS = NSMakeRange(0, 0);
    for (int i = 0; i < length; i++) {
        unichar c = [self characterAtIndex:i];        
        if ([separators characterIsMember:c]) {
            if (inWord) {
                nonWS.length = i - nonWS.location;                
                [result addObject:[self substringWithRange:nonWS]];
                inWord = NO;
            }
        }
        else {
            if (!inWord) {
                nonWS.location = i;
                inWord = YES;
            }
        }
    }
    
    if (inWord)
        [result addObject:[self substringFromIndex:nonWS.location]];
    
    return result;
    
}

- (int) wordCount
{
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];    
    int length = [self length];
    int result = 0;
	
    BOOL inWord=NO;
    for (int i = 0; i < length; i++) {
        unichar c = [self characterAtIndex:i];        
        if ([whitespace characterIsMember:c]) {
            if (inWord) {
                result++;
                inWord = NO;
            }
        }
        else {
			inWord = YES;
        }
    }
    
    if (inWord)
        result++;
    
    return result;
	
}

- (NSMutableString*) stripHTML
{
    // Maybe this would be better done with some regular expressions?
    
    // given some text, purges any HTML tags we find in it.  
    // Also tries to replace HTML entities a bit.
    NSMutableString *result = [NSMutableString string];    
    NSRange remainingString = [self rangeAfter:0];
    
    // Build up a string without any tags.  Assume no "<" within attribute values... is that wise?
    for (;;) {
        NSRange nextTag = [self rangeOfString:@"<"
                                      options:NSLiteralSearch 
                                        range:remainingString];
        if (nextTag.location == NSNotFound) {
            [result appendString:[self substringFromIndex:remainingString.location]];
            break;
        }
        
        // append all characters before the "<"
        NSRange inBetween;
        inBetween.location = remainingString.location;
        inBetween.length = nextTag.location - remainingString.location;
        [result appendString:[self substringWithRange:inBetween]];
        
        // find the matching ">"
        NSRange afterTag = [self rangeAfter:nextTag.location];
        NSRange endTag = [self rangeOfString:@">" options:NSLiteralSearch range:afterTag];
        if (endTag.location == NSNotFound) {
            // No matching ">" found... hmm... I will include the damn thing then
            [result appendString:[self substringWithRange:[self rangeAfterRange:inBetween]]];
            break;
        }
        
        remainingString = [self rangeAfterRange:endTag];
    }
    
    // Replace some well known entities
    NSRange entireString = [result rangeAfter:0];
    [result replaceOccurrencesOfString:@"&lt;" withString:@"<" options:NSCaseInsensitiveSearch range:entireString];
    [result replaceOccurrencesOfString:@"&gt;" withString:@">" options:NSCaseInsensitiveSearch range:entireString];
    [result replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSCaseInsensitiveSearch range:entireString];
    [result replaceOccurrencesOfString:@"&apos;" withString:@"'" options:NSCaseInsensitiveSearch range:entireString];
    [result replaceOccurrencesOfString:@"&amp;" withString:@"&" options:NSCaseInsensitiveSearch range:entireString];
    
    return result;
}

- (NSMutableString*) normalizeWhitespace
{
    // there must be an easier way to do this
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    int length = [self length];
    NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
    
    BOOL pendingWS=NO, pendingNonWS = NO;
    NSRange nonWS = NSMakeRange(0, 0);
    for (int i = 0; i < length; i++) {
        unichar c = [self characterAtIndex:i];
        if ([whitespace characterIsMember:c]) {
            if (pendingNonWS) {
                NSAssert (!pendingWS, @"Can't be pending WS and Non-WS at same time");
                nonWS.length = i - nonWS.location;
                [result appendString:[self substringWithRange:nonWS]];
                pendingNonWS = NO;
                pendingWS = YES;
            }
        }
        else {
            if (pendingWS) {
                NSAssert (!pendingNonWS, @"Can't be pending WS and Non-WS at same time");
                [result appendString:@" "];
                pendingWS = NO;
            }
            if (!pendingNonWS) {
                pendingNonWS = YES;
                nonWS.location = i;
            }
        }
    }
    
    if (pendingNonWS) {
        [result appendString:[self substringFromIndex:nonWS.location]];
        NSAssert (!pendingWS, @"Can't be pending WS and Non-WS at same time");
    }
    
    return result;
}

- (BOOL) isEqualToStringIgnoringCase:(NSString*)other
{
    return [self caseInsensitiveCompare:other] == NSOrderedSame;
}

- (NSComparisonResult) compareIgnoringCase:(NSString*)otherString
{
    return [self compare:otherString options:NSCaseInsensitiveSearch];
}

- (bool) hasPrefix:(NSString*)other options:(NSStringCompareOptions)mask
{
	NSRange range = NSMakeRange(0, [other length]);
	NSComparisonResult cmpres = [self compare:other options:mask range:range];
	return cmpres == NSOrderedSame;
}

@end

