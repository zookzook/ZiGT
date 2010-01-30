//
//  Project.h
//  ZiGT
//
//  Created by Michael Maier on 28.01.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Calendar;
@class Entry;
@class Status;
@class Task;

@interface Project :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * tag;
@property (nonatomic, retain) NSString * menuName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Status * status;
@property (nonatomic, retain) Task * task;
@property (nonatomic, retain) Calendar * calendar;
@property (nonatomic, retain) NSSet* entries;

@end


@interface Project (CoreDataGeneratedAccessors)
- (void)addEntriesObject:(Entry *)value;
- (void)removeEntriesObject:(Entry *)value;
- (void)addEntries:(NSSet *)value;
- (void)removeEntries:(NSSet *)value;

@end

