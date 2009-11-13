#import "OxNSMutableArray.h"

@implementation NSMutableArray (Oaxaca3)

- (void) reverseArrayInPlace
{
	for(int i = 0, c = [self count]; i < c/2; i++) {
		int j = c - i - 1;
		[self exchangeObjectAtIndex:i withObjectAtIndex:j];
	}
}

- (void) moveObjectAtIndex:(int)atIndex toIndex:(int)toIndex
{
	// Is there a more efficient way?  I see no obvious one from the API.
	
	NSAssert2(atIndex >= 0 && atIndex < [self count], @"atIndex %d out of bounds %d!", atIndex, [self count]);
	NSAssert2(toIndex >= 0 && toIndex < [self count], @"toIndex %d out of bounds %d!", toIndex, [self count]);
	
	if(atIndex < toIndex) {
		do {
			[self exchangeObjectAtIndex:atIndex withObjectAtIndex:atIndex+1];
			atIndex++;
		} while(atIndex < toIndex);	
	} else if (atIndex > toIndex) {
		do {
			[self exchangeObjectAtIndex:atIndex withObjectAtIndex:atIndex-1];
			atIndex--;
		} while(atIndex > toIndex);
	}
}

@end
