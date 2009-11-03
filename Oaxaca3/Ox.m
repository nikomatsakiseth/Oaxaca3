#import "Ox.h"

NSArray *OxUtf8StringArray(void *_, ...) {
	NSMutableArray *result = [NSMutableArray array];
	va_list va;
	va_start(va, _);
	char *text;
	while ((text = va_arg(va, char*))) {
		[result addObject:Utf8(text)];
	}
	return [NSArray arrayWithArray:result];
}
