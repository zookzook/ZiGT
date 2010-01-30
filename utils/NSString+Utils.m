#import "NSString+Utils.h"

@implementation NSString( Utils )

/**
 * Neue UUID erzeugen.
 */
+ (NSString *)uuid {
    
    CFUUIDRef uuid= CFUUIDCreate(kCFAllocatorDefault);
    NSString *result= (NSString *)CFUUIDCreateString( kCFAllocatorDefault, uuid );
    CFRelease( uuid );
    
    return result;
}

@end
