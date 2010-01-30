//
//  Account.h
//  ZiGT
//
//  Created by Michael Maier on 28.01.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class ProxyAccount;

@interface Account :  NSManagedObject  
{
    NSString* password;
}

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSSet* proxyAccounts;

@end


@interface Account (CoreDataGeneratedAccessors)
- (void)addProxyAccountsObject:(ProxyAccount *)value;
- (void)removeProxyAccountsObject:(ProxyAccount *)value;
- (void)addProxyAccounts:(NSSet *)value;
- (void)removeProxyAccounts:(NSSet *)value;

@end

