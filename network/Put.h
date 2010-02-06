#import <Cocoa/Cocoa.h>
#import "HTTPRequest.h"

@class Entry, Account, Project, Proxy;

@interface Put : HTTPRequest {

    Entry*              event;    
    BOOL                recordEvent;    // Dieses Event wird gerade aufgezeichnet...
}

@property (nonatomic, retain) Entry              *event;
@property (nonatomic, getter=isRecordEvent) BOOL recordEvent;

+ (Put*)putWithAccount:(Account *)newAccount delegate:(id)newDelegate event:(Entry*)entry context:(void *)context;
- (id)initWithAccount:(Account *)newAccount delegate:(id)newDelegate event:(Entry*)entry context:(void *)context;

@end

@interface NSObject( PutAdditions )

- (void)calendarStored:(Put*) putRequest;
- (void)calendarFailed:(Put*) putRequest;

@end