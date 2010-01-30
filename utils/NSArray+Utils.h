#import <Cocoa/Cocoa.h>

@interface NSArray( Utils )

- (NSArray*)filter:(BOOL(^)(id elt))filterBlock;
- (NSArray*)map:(id(^)(id object))filterBlock;
    
@end
