#import "NSXmlDocument+Utils.h"

@implementation NSXMLDocument( Utils )

+ (void)removeNamespaces:(NSXMLNode*)root {
    
    for( NSXMLNode* child in [root children] ) {
        
        if( [child kind] == NSXMLElementKind ) {            
            [(NSXMLElement*)child setNamespaces:[NSArray array]];
        } // if         
        [self removeNamespaces:child];        
    } // for 
}

- (NSXMLDocument*)fix {

    NSError *err=nil;
    [NSXMLDocument removeNamespaces:self];    
    NSXMLDocument* result= [[NSXMLDocument alloc] initWithXMLString:[self description] options:NSXMLNodePreserveAll error:&err];
    
    return [result autorelease];
}

@end
