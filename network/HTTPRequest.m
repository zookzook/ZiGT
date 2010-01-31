#import "HTTPRequest.h"
#import "Account.h"

@implementation HTTPRequest

@synthesize connection, data, response, account, delegate, context;

- (NSString*)method {
    
    return @"GET";
}

- (id)initWithAccount:(Account *)newAccount delegate:(id)newDelegate context:(void *)newContext {
    
    
    self= [super init];
    if( self ) {
        
        self->delegate  = newDelegate;
        self.account    = newAccount;
        self.context    = newContext;
    } // if
    
    return self;
}

- (NSURL*)url {

    return [NSURL URLWithString:self.account.url];
}

- (void)willPerformRequest:(NSMutableURLRequest*)request {
    
}

- (NSString*)body {
    
    return @"";
}

- (void)run {
    
    NSMutableURLRequest* request= [NSMutableURLRequest requestWithURL:[self url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];    
    
    NSString* body= [self body];
    NSData* bodyData= [body dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:[self method]];
    [request setHTTPBody:bodyData];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    NSLog( @"Body:%@", body );
    
    [self willPerformRequest:request];
    
    
    self.data      = [NSMutableData data];
    self.connection= [[NSURLConnection alloc] initWithRequest:request delegate:self];    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)newResponse {
    
    self.response= newResponse;
    [self.data setLength:0];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    
    NSLog( @"%@", [redirectResponse allHeaderFields] );
    NSLog( @"%@", [request HTTPMethod] );
    return request;
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
    
    NSLog( @"Error: %@", error );
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSHTTPURLResponse* httpResponse= (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    NSLog( @"StatusCode:%d", statusCode );
    NSLog( @"Headers:%@", [httpResponse allHeaderFields] );
    NSLog( @"%@", [[[NSString alloc]  initWithData:self.data encoding:NSUTF8StringEncoding] autorelease] );
}

- (void)dealloc {
    
    self.connection= nil;
    self.data      = nil;
    self.account   = nil;
    self.response  = nil;
    
    [super dealloc];
}

@end
