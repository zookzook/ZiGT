#import "HTTPRequest.h"

@interface Report : HTTPRequest {

    NSMutableDictionary* proxies;
}

@property (nonatomic, retain) IBOutlet NSMutableDictionary *proxies;

@end

@interface NSObject( ReportDelegate )

- (void)proxiesFound:(Report*) reportRequest;
- (void)proxiesNotFound:(Report*) reportRequest;

@end