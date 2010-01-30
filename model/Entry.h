//
//  Entry.h
//  ZiGT
//
//  Created by Michael Maier on 28.01.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Project;

@interface Entry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * stored;
@property (nonatomic, retain) NSDate * startedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSDate * finishedAt;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) Project * project;

@end



