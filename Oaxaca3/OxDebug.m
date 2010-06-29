#import "OxDebug.h"

static int indent;

void _OxLog (const char *funcname, const char *file, int line, NSString *logme)
{
    NSLog (@"%*s%@", indent, "", logme);
}

void _OxIndent (const char *funcname, const char *file, int line, NSString *label)
{
    _OxLog (funcname, file, line, [NSString stringWithFormat:@"%@:", label]);
    indent += 2;
}

void _OxUndent ()
{
    indent -= 2;
}

