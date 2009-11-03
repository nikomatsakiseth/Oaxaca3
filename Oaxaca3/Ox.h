// Some macros to make it easier to create wrapper objects.
#define OxInt(n) [NSNumber numberWithInt:n]
#define OxDouble(n) [NSNumber numberWithDouble:n]
#define OxYES [NSNumber numberWithBool:YES]
#define OxNO [NSNumber numberWithBool:NO]
#define OxArr(...) [NSArray arrayWithObjects:__VA_ARGS__, nil]
#define OxSet(...) [NSSet setWithObjects:__VA_ARGS__, nil]
#define OxMutableArr(...) [NSMutableArray arrayWithObjects:__VA_ARGS__, nil]
#define OxDict(...) [NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]
#define OxMutableDict(...) [NSMutableDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]
#define CfDict(...) ((CFDictionaryRef)OxDict(__VA_ARGS__))
#define CfArr(...) ((CFArrayRef)OxArr(__VA_ARGS__))
#define OxFmt(...) [NSString stringWithFormat:__VA_ARGS__]

// UTF-8 String Constants:
//   (Be sure to set the coding on your .m file to UTF-8!)
#define Utf8(X)   [[NSString stringWithUTF8String:X] decomposedStringWithCanonicalMapping]
#define Utf8Arr(...) OxUtf8StringArray(nil, __VA_ARGS__, nil)
NSArray *OxUtf8StringArray(void *_, ...);

// Useful in OxDict definitions to help remember the order.  Now one can write:
// OxDict(value1 FOR key1, value2 FOR key2)
#define FOR ,

// Useful with HOM methods like filter, to avoid warnings.
// Use like (HOM)[[array filter] foo]
// #define HOM id)(int --> this didn't seem to be safe, compiler went a bit nuts!
#define HOM id

#define OxGetKeyPath(NM,KP) \
static inline id NM(id object) { return [object valueForKeyPath:KP]; }

#define OxSetKeyPath(NM,KP) \
static inline void set ## NM(id object, id value) { return [object setValue:value forKeyPath:KP]; }

// Convenient marker for the implementation of abstract methods:
#define OxAbstract() ([NSException raise:@"OxAbstract" format:@"Abstract Method %s Invoked: %s:%d", __func__, __FILE__, __LINE__], nil)
