#import <Cocoa/Cocoa.h>

#ifndef NDEBUG
// Add a log at the current debug level.
#  define OxLog(args...) _OxLog (__FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:args])

// Use these to indent a lexically scoped block of log entries, like this:
//   OAIDENTED(@"Some text") { ... } OAUNDENTED;
// Oh, for the Python with statement! (or first class blocks, I suppose)
#  define OxIndented(args...) @try { _OxIndent(__FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:args]);
#  define OxUndented          } @finally { _OxUndent(); }

// You can use this to indent/undent when lexical scoping is not convenient.
#  define OxIndent(args...) _OxIndent (__FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:args])
#  define OxUndent() _OxUndent ()
#else
#  define OxLog(args...) 
#  define OxIndent(args...) 
#  define OxUndent() 
#  define OxIndented(args...)
#  define OxUndented
#endif

void _OxLog (const char *funcname, const char *file, int line, NSString *logme);
void _OxIndent (const char *funcname, const char *file, int line, NSString *label);
void _OxUndent ();

