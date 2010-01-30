#import "NSArray+Utils.h"

@implementation NSArray( Utils )

- (NSArray*)filter:(BOOL(^)(id elt))filterBlock {
    
	NSMutableArray* result= [NSMutableArray array];
	for (id element in self)
		if( filterBlock( element ) )	
            [result addObject:element];
    
	return	result;
}

- (NSArray*)map:(id(^)(id object))filterBlock {
    
    NSMutableArray* result= [NSMutableArray array];
	for(id object in self) {        
        
        id mappedObject= filterBlock( object );
        if( mappedObject ) {
            
            [result addObject:mappedObject];
        } // if 
    } // for 
    
    return result;
}

@end
