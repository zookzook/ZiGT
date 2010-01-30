#import "HTTPRequest.h"

@interface Propfind : HTTPRequest {

    NSMutableDictionary* calendars;
    NSString*            guid;
}

@property (nonatomic, retain) IBOutlet NSMutableDictionary *calendars;
@property (nonatomic, retain) IBOutlet NSString *guid;

- (id)initWithAccount:(Account *)newAccount forGUID:(NSString*)newGuid delegate:(id)newDelegate;

@end

@interface NSObject( PropfindDelegate )

- (void)calendarsFound:(Propfind*) reportRequest;
- (void)calendarsNotFound:(Propfind*) reportRequest;

@end
