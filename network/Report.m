#import "Report.h"
#import "NSXMLDocument+Utils.h"
#import "Account.h"

@implementation Report

@synthesize proxies;

- (NSString*)method {
    
    return @"REPORT";
}

- (NSURL*)url {
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/principals/users/%@/", self.account.url, self.account.username]];
}

- (void)willPerformRequest:(NSMutableURLRequest*)request {
    
    [request setValue:@"text/xml; charset=\"utf-8\"" forHTTPHeaderField:@"Content-Type"];
    self.proxies= [NSMutableDictionary dictionary];
}

- (NSString*)body {
    
    NSMutableString* result= [NSMutableString string];
    
    [result appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
    [result appendString:@"<x0:expand-property xmlns:x0=\"DAV:\"><x0:property name=\"calendar-proxy-write-for\" namespace=\"http://calendarserver.org/ns/\"><x0:property name=\"displayname\"/><x0:property name=\"principal-URL\"/><x0:property name=\"calendar-user-address-set\" namespace=\"urn:ietf:params:xml:ns:caldav\"/></x0:property><x0:property name=\"calendar-proxy-read-for\" namespace=\"http://calendarserver.org/ns/\"><x0:property name=\"displayname\"/><x0:property name=\"principal-URL\"/><x0:property name=\"calendar-user-address-set\" namespace=\"urn:ietf:params:xml:ns:caldav\"/></x0:property></x0:expand-property>"];
    return result;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSHTTPURLResponse* httpResponse= (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    if( statusCode >= 200 && statusCode < 300 ) {
                
        NSError *err=nil;
        
        NSXMLDocument* xmlDoc= [[[NSXMLDocument alloc] initWithData:self.data options:NSXMLNodePreserveAll error:&err] autorelease];
        xmlDoc= [xmlDoc fix];
        
        NSLog( @"%@", xmlDoc );
        NSArray *nodes = [xmlDoc nodesForXPath:@"//calendar-proxy-write-for//response" error:&err];
        for( NSXMLNode* responseNode in nodes ) {
            
            NSString* displayName= nil;
            NSString*        guid= nil;
            
            NSArray* node= [responseNode nodesForXPath:@".//displayname/text()" error:&err];
            if( [node count] == 1 ) {
                
                displayName= [[node lastObject] stringValue];
            } // if 
            
            node= [responseNode nodesForXPath:@".//principal-URL/href/text()" error:&err];
            if( [node count] == 1 ) {
                
                guid= [[[node lastObject] stringValue] lastPathComponent];
            } // if 
            
            if( displayName && guid ) {
                
                [self.proxies setObject:displayName forKey:guid];
            } // if 
        } // for    
        
        [self.delegate proxiesFound:self];
    }    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.delegate proxiesNotFound:self];
}

- (void)dealloc {
    
    self.proxies= nil;
    [super dealloc];
}

@end
