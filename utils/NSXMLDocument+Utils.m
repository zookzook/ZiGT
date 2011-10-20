#import "NSXmlDocument+Utils.h"

@implementation NSXMLDocument( Utils )

+ (void)removeNamespaces:(NSXMLNode*)root {
    
    for( NSXMLNode* child in [root children] ) {
        
        if( [child kind] == NSXMLElementKind ) {                        
            [(NSXMLElement*)child namespaces];
            [(NSXMLElement*)child setNamespaces:nil];
        } // if         
        [self removeNamespaces:child];        
    } // for 
}

- (NSXMLDocument*)fix {

    NSError *err=nil;
    [NSXMLDocument removeNamespaces:self];    
    NSXMLDocument* result= [[NSXMLDocument alloc] initWithXMLString:[self XMLString] options:NSXMLNodePreserveAll error:&err];
    
    return [result autorelease];
}

@end
