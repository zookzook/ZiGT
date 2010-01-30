#import "Propfind.h"
#import "Account.h"
#import "NSXMLDocument+Utils.h"

@implementation Propfind

@synthesize guid, calendars;

- (id)initWithAccount:(Account *)newAccount forGUID:(NSString*)newGuid delegate:(id)newDelegate {
    
    self= [super initWithAccount:newAccount delegate:newDelegate];
    if( self ) {
        
        self.guid= newGuid;
    } // if 
    
    return self;
}

- (NSString*)method {
    
    return @"PROPFIND";
}

- (NSURL*)url {
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/calendars/__uids__/%@/", self.account.url, self.guid]];
}

- (NSString*)body {
    
    NSMutableString* result= [NSMutableString string];
    
    [result appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [result appendString:@"<x0:propfind xmlns:x0=\"DAV:\" xmlns:x3=\"http://apple.com/ns/ical/\" xmlns:x1=\"http://calendarserver.org/ns/\" xmlns:x2=\"urn:ietf:params:xml:ns:caldav\">"];
    [result appendString:@"<x0:prop>"];
    [result appendString:@"<x0:displayname/>"];
    [result appendString:@"<x0:resourcetype/>"];
    [result appendString:@"</x0:prop>"];
    [result appendString:@"</x0:propfind>"];
    return result;
}

- (void)willPerformRequest:(NSMutableURLRequest*)request {

    [request setValue:@"text/xml; charset=\"utf-8\"" forHTTPHeaderField:@"Content-Type"];
    self.calendars= [NSMutableDictionary dictionary];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSHTTPURLResponse* httpResponse= (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    if( statusCode >= 200 && statusCode < 300 ) {
        
        NSError *err=nil;
        
        NSXMLDocument* xmlDoc= [[[NSXMLDocument alloc] initWithData:self.data options:NSXMLNodePreserveAll error:&err] autorelease];
        xmlDoc= [xmlDoc fix];
        
        NSArray *nodes = [xmlDoc nodesForXPath:@"//response" error:&err];
        for( NSXMLNode* responseNode in nodes ) {
            
            NSString* href= nil;
            NSString* displayname= nil;
            NSArray* node= [responseNode nodesForXPath:@".//calendar" error:&err];
            if( [node count] == 1 ) {
                
                node= [responseNode nodesForXPath:@".//href/text()"error:&err];
                if( [node count] == 1 ) {
                    
                    href= [[[node lastObject] stringValue] lastPathComponent];
                } // if 
                node= [responseNode nodesForXPath:@".//displayname/text()"error:&err];
                if( [node count] == 1 ) {
                    
                    displayname= [[node lastObject] stringValue];
                } // if 
                
                if( href && displayname ) {
                    [self.calendars setObject:displayname forKey:href];
                }
            } // if             
            
        } // for    
        
        [self.delegate calendarsFound:self];
    }    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.delegate calendarsNotFound:self];
}

- (void)dealloc {
    
    self.calendars= nil;
    [super dealloc];
}




@end
