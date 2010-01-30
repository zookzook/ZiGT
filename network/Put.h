#import <Cocoa/Cocoa.h>

@class Entry, Account, Project, Proxy;

@interface Put : NSObject {

    NSURLResponse*      response;
    NSURLConnection*    connection;
    NSMutableData*      data;
    Account*            account;
    id                  delegate;
    Entry*              event;    
    BOOL                recordEvent;    // Dieses Event wird gerade aufgezeichnet...
}

@property (nonatomic, retain) NSURLConnection    *connection;
@property (nonatomic, retain) NSMutableData      *data;
@property (nonatomic, retain) NSURLResponse      *response;
@property (nonatomic, retain) Account            *account;
@property (nonatomic, retain) Entry              *event;
@property (nonatomic, getter=isRecordEvent) BOOL recordEvent;
@property (nonatomic, retain, readonly) id       delegate;

+ (Put*)putEvent:(Entry *)event forAccount:(Account *)account delegate:(id)delegate;

- (id)initWithEvent:(Entry *)newEvent forAccount:(Account *)newAccount delegate:(id)newDelegate;
- (void)run;

@end

@interface NSObject( PutAdditions )

- (void)calendarStored:(Put*) putRequest;
- (void)calendarFailed:(Put*) putRequest;

@end