#import <Foundation/Foundation.h>
#import "Ox.h"

@interface NSMutableArray (Oaxaca3)

- (void) reverseArrayInPlace;
- (void) moveObjectAtIndex:(int)fromIndex toIndex:(int)toIndex;

#ifdef OX_BLOCKS_AVAILABLE
- (void) filterArrayInPlaceUsingBlock:(int (^)(id obj))blk;
#endif

@end
