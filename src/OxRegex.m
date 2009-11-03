#import "OxRegex.h"

static NSString *nullstring=nil;

@implementation OxRegex

-(id)initWithPattern:(NSString *)pattern options:(int)options
{
	if((self=[super init]))
	{
		int err=regcomp(&preg,[pattern UTF8String],options|REG_EXTENDED);
		if(err)
		{
			char errbuf[256];
			regerror(err,&preg,errbuf,sizeof(errbuf));
			[NSException raise:OxRegexException
                        format:@"Could not compile regex \"%@\": %s",pattern,errbuf];
		}
	}
	return self;
}

-(void)dealloc
{
	regfree(&preg);
	[super dealloc];
}

-(BOOL)matchesString:(NSString *)string
{
	if(regexec(&preg,[string UTF8String],0,NULL,0)==0) return YES;
	return NO;
}

-(NSString *)matchedSubstringOfString:(NSString *)string
{
	const char *cstr=[string UTF8String];
	regmatch_t match;
	if(regexec(&preg,cstr,1,&match,0)==0)
	{
		return [[[NSString alloc] initWithBytes:cstr+match.rm_so
                                         length:match.rm_eo-match.rm_so 
                                       encoding:NSUTF8StringEncoding] autorelease];
	}
    
	return nil;
}

-(NSString *)matchedSubstringOfUTF8Bytes:(char*)bytes from:(int)offset length:(int)length
{
	regmatch_t match = { .rm_so=offset, .rm_eo=length };
	if(regexec(&preg,bytes,1,&match,REG_STARTEND)==0)
	{
		return [[[NSString alloc] initWithBytes:bytes+match.rm_so
                                         length:match.rm_eo-match.rm_so 
                                       encoding:NSUTF8StringEncoding] autorelease];
	}
    
	return nil;
}


-(NSArray *)capturedSubstringsOfString:(NSString *)string
{
	const char *cstr=[string UTF8String];
	int num=preg.re_nsub+1;
	regmatch_t *matches=calloc(sizeof(regmatch_t),num);
    
	if(regexec(&preg,cstr,num,matches,0)==0)
	{
		NSMutableArray *array=[NSMutableArray arrayWithCapacity:num];
        
		int i;
		for(i=0;i<num;i++)
		{
			NSString *str;
            
			if(matches[i].rm_so==-1&&matches[i].rm_eo==-1) str=nullstring;
			else str=[[[NSString alloc] initWithBytes:cstr+matches[i].rm_so
                                               length:matches[i].rm_eo-matches[i].rm_so 
                                             encoding:NSUTF8StringEncoding] autorelease];
            
			[array addObject:str];
		}
        
		free(matches);
        
		return [NSArray arrayWithArray:array];
	}
    
	return nil;
}

- (NSArray *) allMatchingSubstringsOfString:(NSString *)string {
    NSMutableArray *array = [NSMutableArray array];
    int index = 0;
    const char *cstr = [string UTF8String];
    int length = strlen(cstr);
    regmatch_t match;
    
    while (true) {
        match.rm_so = index;
        match.rm_eo = length;
        if (regexec(&preg, cstr, 1, &match, REG_STARTEND) == 0) {
            int len = match.rm_eo - match.rm_so;
            NSString *next = [[[NSString alloc] initWithBytes:cstr+match.rm_so 
                                                       length:len 
                                                     encoding:NSUTF8StringEncoding] autorelease];
            [array addObject:next];
            index = match.rm_eo;
        }
        else return array;
    }
}

+(OxRegex *)regexWithPattern:(NSString *)pattern options:(int)options
{ return [[[OxRegex alloc] initWithPattern:pattern options:options] autorelease]; }

+(OxRegex *)regexWithPattern:(NSString *)pattern
{ return [[[OxRegex alloc] initWithPattern:pattern options:REG_EXTENDED] autorelease]; }

+(NSString *)null { return nullstring; }

+(void)initialize
{
	if(!nullstring) nullstring=[[NSString alloc] initWithString:@""];
}

@end

@implementation NSString (OxRegex)

-(BOOL)matchedByPattern:(NSString *)pattern options:(int)options
{
	OxRegex *re=[OxRegex regexWithPattern:pattern options:options|REG_NOSUB];
	return [re matchesString:self];
}

-(BOOL)matchedByPattern:(NSString *)pattern
{ return [self matchedByPattern:pattern options:0]; }

-(NSString *)substringMatchedByPattern:(NSString *)pattern options:(int)options
{
	OxRegex *re=[OxRegex regexWithPattern:pattern options:options];
	return [re matchedSubstringOfString:self];
}

-(NSString *)substringMatchedByPattern:(NSString *)pattern
{ return [self substringMatchedByPattern:pattern options:0]; }

-(NSArray *)substringsCapturedByPattern:(NSString *)pattern options:(int)options
{
	OxRegex *re=[OxRegex regexWithPattern:pattern options:options];
	return [re capturedSubstringsOfString:self];
}

-(NSArray *)substringsCapturedByPattern:(NSString *)pattern
{ return [self substringsCapturedByPattern:pattern options:0]; }

-(NSString *)escapedPattern
{
	int len=[self length];
	NSMutableString *escaped=[NSMutableString stringWithCapacity:len];
    
	for(int i=0;i<len;i++)
	{
		unichar c=[self characterAtIndex:i];
		if(c=='^'||c=='.'||c=='['||c=='$'||c=='('||c==')'
           ||c=='|'||c=='*'||c=='+'||c=='?'||c=='{'||c=='\\') [escaped appendFormat:@"\\%C",c];
		else [escaped appendFormat:@"%C",c];
	}
	return [NSString stringWithString:escaped];
}

@end
