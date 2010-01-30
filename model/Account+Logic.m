#import "Account+Logic.h"

@implementation Account( Logic )

- (void)mergeProxies:(NSDictionary*)proxies {
    
    NSMutableDictionary* oldProxies= [NSMutableDictionary dictionary];
    for( ProxyAccount* p in self.proxyAccounts ) {
        
        [oldProxies setObject:p forKey:p.guid];        
    } // for 
    
    // Welche Proxys wurden gelöscht?
    for( ProxyAccount* p in [oldProxies allValues] ) {
        
        // finden wir diese nicht mehr, so werden diese gelöscht.
        if( ![proxies objectForKey:p.guid] ) {
            
            [self removeProxyAccountsObject:p];
            [self.managedObjectContext deleteObject:p];            
        } // if 
    } // for 
    
    // Welche Proxys sind neu?
    for( NSString* guid in [proxies allKeys] ) {
        
        ProxyAccount* oldAccount= [oldProxies objectForKey:guid];
        if( !oldAccount ) {
            ProxyAccount* p= [NSEntityDescription insertNewObjectForEntityForName:@"ProxyAccount" inManagedObjectContext:self.managedObjectContext]; 
            p.guid= guid;
            p.name= [proxies objectForKey:guid];
            [self addProxyAccountsObject:p];
        } // if 
        else {
         
            oldAccount.name= [proxies objectForKey:guid];
        } // else
    } // for 
}

@end
