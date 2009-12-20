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

#ifdef OX_BLOCKS_AVAILABLE
- (void) filterArrayInPlaceUsingBlock:(int (^)(id obj))blk
{
	NSUInteger c, dead;
	c = [self count];
	dead = 0;
	for(int i = 0; i < c; i++) {
		id obj = [self objectAtIndex:i];
		if(!blk(obj)) {
			dead++;			
		} else if(dead) {
			[self replaceObjectAtIndex:i-dead withObject:obj];
		}
	}

	// remove the last "dead" entries:
	if(dead)
		[self removeObjectsInRange:NSMakeRange(c - dead, dead)];
}
#endif

@end
