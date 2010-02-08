//
//  Entry.h
//  ZiGT
//
//  Created by Michael Maier on 08.02.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Project;
@class Status;
@class Task;

@interface Entry :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * stored;
@property (nonatomic, retain) NSDate * startedAtRounded;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * startedAt;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSDate * finishedAt;
@property (nonatomic, retain) NSDate * finishedAtRounded;
@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) Project * project;
@property (nonatomic, retain) Task * task;

@end



