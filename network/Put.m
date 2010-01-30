#import "Put.h"
#import "Entry+Logic.h"
#import "Account.h"
#import "Project.h"
#import "ProxyAccount.h"
#import "Calendar.h"

@implementation Put

@synthesize connection, data, response, event, account, delegate, recordEvent;

+ (Put*)putEvent:(Entry *)event forAccount:(Account *)account delegate:(id)delegate {

    return [[[self alloc] initWithEvent:event forAccount:account delegate:delegate] autorelease];
}

- (id)initWithEvent:(Entry *)newEvent forAccount:(Account *)newAccount delegate:(id)newDelegate {

    self= [super init];
    if( self ) {
        
        self->delegate  = newDelegate;
        self.account    = newAccount;
        self.event      = newEvent;
        self.recordEvent= NO;
    } // if
    
    return self;
}

- (void)run {
    
    NSString* url= [NSString stringWithFormat:@"%@/calendars/__uids__/%@/%@/%@.ics", self.account.url, self.event.project.calendar.proxyAccount.guid, self.event.project.calendar.guid, self.event.uuid];
    NSURL *theUrl= [NSURL URLWithString:url];
    NSMutableURLRequest* request= [NSMutableURLRequest requestWithURL:theUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSMutableDictionary* headers =[NSMutableDictionary dictionary];
    [headers setValue:@"text/calendar; charset=utf-8"  forKey:@"Content-Type"];    
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:headers];
    
    NSString* bodyText= [self.event vcalendar];
    NSLog( @"PUT\n%@", bodyText);
    [request setHTTPBody:[bodyText dataUsingEncoding:NSUTF8StringEncoding]];
    
    self.data      = [NSMutableData data];
    self.connection= [[NSURLConnection alloc] initWithRequest:request delegate:self];    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)newResponse {
    
    self.response= newResponse;
    [self.data setLength:0];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] ||
    [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest];
}

/**
 * Liefert die aktuellen Credential zurück, sofern sie existieren.
 * Ansonsten wird nil zurückgegeben.
 */
- (NSURLCredential *)credentialForProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    NSURLCredentialStorage *storage= [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary    *credentialInfo= [storage credentialsForProtectionSpace:protectionSpace];
    return [credentialInfo objectForKey:self.account.username];
}


-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } // if 
    else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
        
        if( [challenge previousFailureCount] == 0 ) {
            
            NSURLCredential* credential= [NSURLCredential credentialWithUser:account.username
                                                                    password:account.password
                                                                 persistence:NSURLCredentialPersistenceNone];
            
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } // if 
        else
            [[challenge sender] cancelAuthenticationChallenge:challenge];
    } // if 
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData {
    
    [self.data appendData:newData];
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
    
    self.connection= nil;
    self.data      = nil;
    self.account   = nil;
    self.event     = nil;
    
    [super dealloc];
}

@end
