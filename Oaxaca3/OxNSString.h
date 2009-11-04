//
//  OxNSString.h
//  Flash2
//
//  Copyright 2008 Nicholas Matsakis. 
//  The code in thie file is released to the public under the
//  terms of the MIT License as described here:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface NSString (Oaxaca2)

/* Python-style string slicing */
- (NSString*) sliceFrom:(int)index;
- (NSString*) sliceFrom:(int)fromIndex to:(int)toIndex;
- (NSString*) sliceTo:(int)index;

/* Returns number of characters this string has in common with the other
 string, in a case-insensitive fashion. */
- (int) sharedCaseInsensitivePrefixLength:(NSString*)other;
- (int) sharedCaseInsensitiveSuffixLength:(NSString*)other;

/* Returns a new string constructed by removing any text between parenthesis */
- (NSMutableString*) stringByPurgingParentheticalText;

/* Returns this with 'string' inserted at the front */
- (NSString*) stringByPrependingString:(NSString*)string;

/* Copies this string 'times' times */
- (NSMutableString*) stringByRepeating:(int)times;

/* Capitalizes the first letter (!) */
- (NSString*) stringWithCapitalizedFirstLetter;

/* Returns the substring that appears before the first occurence of 'str'.
   If 'str' is not contained within 'self', returns self. */
- (NSString*) stringBefore:(NSString*)str;

/* Returns a range corresponding to all characters after index. 
 If index is negative, it is assumed to count backwards from the end of the string. */
- (NSRange) rangeAfter:(int)index;

/* Returns the range after range.location + range.length + 1 */
- (NSRange) rangeAfterRange:(NSRange)range;

/* Returns true if 'string' is a subset of this string */
- (BOOL) containsString:(NSString*)string;

/* Returns true if this string contains any of the characters in 'set' */
- (BOOL) containsCharactersInSet:(NSCharacterSet*)set;

/* Strips out tags and entities.  Rather crude. */
- (NSMutableString*) stripHTML;

/* Strips whitespace from beginning and end */
- (NSString*) strip;

/* Like python's .split() method */
- (NSMutableArray*) componentsSeparatedByWhitespace;
- (NSMutableArray*) componentsSeparatedBy:(NSCharacterSet *)separators;

/* the number of words separated by whitespaces */
- (int) wordCount;

/* Replaces all internal whitespace by a single space, and 
 strips excess whitespace from beginning and end */
- (NSMutableString*) normalizeWhitespace;

- (BOOL) isEqualToStringIgnoringCase:(NSString*)other;

- (NSComparisonResult) compareIgnoringCase:(NSString*)otherString;

/* like compare:options:range:, but checks only for equality and range is always 
   from beginning to length of 'other' */
- (bool) hasPrefix:(NSString*)other options:(NSStringCompareOptions)mask;

@end

