#import <Cocoa/Cocoa.h>

@class Account;

@interface HTTPRequest : NSObject {

    NSURLResponse*          response;
    NSURLConnection*        connection;
    NSMutableData*          data;
    Account*                account;
    id                      delegate;
}

@property (nonatomic, retain) NSURLConnection     *connection;
@property (nonatomic, retain) NSMutableData       *data;
@property (nonatomic, retain) NSURLResponse       *response;
@property (nonatomic, retain) Account             *account;
@property (nonatomic, retain, readonly) id        delegate;

- (id)initWithAccount:(Account *)newAccount delegate:(id)newDelegate;
- (void)run;

- (NSString*)method;
- (NSURL*)url;
- (NSString*)body;

- (void)willPerformRequest:(NSMutableURLRequest*)request;

@end

