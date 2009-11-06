#import <Foundation/Foundation.h>
#import <regex.h>

// A simple wrapper around regular expressions.   Based on some code that was released 
// into the public domain.  I include here the original text.

/*
 http://www.cocoadev.com/index.pl?CSRegex
 
 CSRegex is a simple Objective-C wrapper around the regcomp()/regexec() 
 functions available in the BSD libc. It is meant to be a quick and simple 
 regex class that can be dropped into any Cocoa project with a minimum of fuss. 
 It consists of only two files, and no external dependencies. Currently there 
 is no documentation, but I hope to remedy that soon. It should, however, be 
 pretty self-documenting.  It is simpler to use than other regex wrappers, 
 such a OgreKit, AGRegex or OmniFoundation, but not as powerful. It is meant 
 for code that needs simple regex snippets, without the need for including 
 external libraries or frameworks.
 
 Note that the use of the BSD regex functions means this class uses POSIX 
 regexes and not Perl regexes! This most notably means that character classes 
 like \w and \s do not work - POSIX uses character classes like [:alpha:] and 
 [:space:] instead. Use the command "man re_format" for more information.
 
 Two missing features that would be nice to have implemented are 
 search-and-replace regexs, and a function to find all substrings that match a 
 given pattern. I might implement these at some point, unless somebody else 
 beats me to it.
 
 It is released into the public domain. I claim no copyright on any part 
 of it. -- WAHa
 */

// In the event of a parse error, raises an NSException with this name,
// and a message describing the parse error:
#define OxRegexException @"OxRegexException"

@interface OxRegex : NSObject
{
	regex_t preg;
}

+(OxRegex *)regexWithPattern:(NSString *)pattern options:(int)options; // may raise 
+(OxRegex *)regexWithPattern:(NSString *)pattern; // default options = REG_EXTENDED, may raise

+(NSString *)null;

+(void)initialize;

-(id)initWithPattern:(NSString *)pattern options:(int)options; // may raise
-(void)dealloc;

-(BOOL)matchesString:(NSString *)string;
-(NSString *)matchedSubstringOfString:(NSString *)string;
-(NSArray *)capturedSubstringsOfString:(NSString *)string;

-(NSString *)matchedSubstringOfUTF8Bytes:(char*)bytes from:(int)offset length:(int)length;

-(NSArray *)allMatchingSubstringsOfString:(NSString *)string;

@end

@interface NSString (OxRegex)

-(BOOL)matchedByPattern:(NSString *)pattern options:(int)options; // may raise
-(BOOL)matchedByPattern:(NSString *)pattern; // may raise

-(NSString *)substringMatchedByPattern:(NSString *)pattern options:(int)options; // may raise
-(NSString *)substringMatchedByPattern:(NSString *)pattern; // may raise

-(NSArray *)substringsCapturedByPattern:(NSString *)pattern options:(int)options; // may raise
-(NSArray *)substringsCapturedByPattern:(NSString *)pattern; // may raise

-(NSString *)escapedPattern;

@end
