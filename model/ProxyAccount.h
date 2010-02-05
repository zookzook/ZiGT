//
//  ProxyAccount.h
//  ZiGT
//
//  Created by Michael Maier on 05.02.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Account;
@class Calendar;

@interface ProxyAccount :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) Account * account;
@property (nonatomic, retain) NSSet* calendars;

@end


@interface ProxyAccount (CoreDataGeneratedAccessors)
- (void)addCalendarsObject:(Calendar *)value;
- (void)removeCalendarsObject:(Calendar *)value;
- (void)addCalendars:(NSSet *)value;
- (void)removeCalendars:(NSSet *)value;

@end

