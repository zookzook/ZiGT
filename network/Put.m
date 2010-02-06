#import "Put.h"
#import "Entry+Logic.h"
#import "Account.h"
#import "Project.h"
#import "ProxyAccount.h"
#import "Calendar.h"

@implementation Put

@synthesize event, recordEvent;

+ (Put*)putWithAccount:(Account *)newAccount delegate:(id)newDelegate event:(Entry*)entry context:(void *)context {

    return [[[self alloc] initWithAccount:newAccount delegate:newDelegate event:entry context:context] autorelease];
}

- (id)initWithAccount:(Account *)newAccount delegate:(id)newDelegate event:(Entry*)entry context:(void *)newContext {

    self= [super initWithAccount:newAccount delegate:newDelegate context:newContext];
    if( self ) {
        
        self.event      = entry;
        self.recordEvent= NO;
    } // if
    
    return self;
}

- (NSString*)method {
    
    return @"PUT";
}


- (NSURL*)url {
    
    NSString* url= [NSString stringWithFormat:@"%@/calendars/__uids__/%@/%@/%@.ics", self.account.url, self.event.project.calendar.proxyAccount.guid, self.event.project.calendar.guid, self.event.uuid];
    return [NSURL URLWithString:url];
}

- (NSString*)body {
    
   return [self.event vcalendar];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.delegate calendarFailed:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSHTTPURLResponse* httpResponse= (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    if( statusCode >= 200 && statusCode < 300 ) {

        [self.delegate calendarStored:self];
    } // if 
    else {
        
        NSLog( @"StatusCode:%d", statusCode );
        NSLog( @"%@", [[[NSString alloc]  initWithData:self.data encoding:NSUTF8StringEncoding] autorelease] );
        [self.delegate calendarFailed:self];
    } // else 

    self.connection= nil;
    self.data      = nil;
}

- (BOOL)isEqual:(id)object {
    
    return [self.event isEqual:object];    
}

- (NSUInteger)hash {
    
    return [self.event hash];
}

- (void)dealloc {
    
    self.event= nil;    
    [super dealloc];
}

@end
