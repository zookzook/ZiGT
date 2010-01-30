#import "NSDate+Utils.h"


@implementation NSDate( Utils )

- (NSString *)UTCString {
    
    static NSTimeZone* UTCTimezone;
    
    if( !UTCTimezone )
        UTCTimezone= [[NSTimeZone timeZoneWithAbbreviation:@"UTC"] retain];

    return [self descriptionWithCalendarFormat:@"%Y%m%dT%H%M%SZ" timeZone:UTCTimezone locale:nil];
             
}
             
@end
