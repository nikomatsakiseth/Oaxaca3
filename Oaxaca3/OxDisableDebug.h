/*
 *  OxDisableDebug.h
 *  AeDemo
 *
 *  Created by Nicholas Matsakis on 7/31/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#undef OxLog
#undef OxIndent
#undef OxUndent
#undef OxIndented
#undef OxUndented
#undef OxLogBacktrace
#undef OxWatch
#undef OxUnwatch

#define OxLog(...)
#define OxIndent(...) 
#define OxUndent() 
#define OxIndented(...)
#define OxUndented
#define OxLogBacktrace(...)
#define OxWatch(args...)
#define OxUnwatch(args...)
