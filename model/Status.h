//
//  Status.h
//  ZiGT
//
//  Created by Michael Maier on 16.04.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Entry;
@class Project;
@class Task;

@interface Status :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * rounding;
@property (nonatomic, retain) NSNumber * pushToServerTimeinterval;
@property (nonatomic, retain) NSNumber * minTimeinterval;
@property (nonatomic, retain) NSNumber * finishedNormaly;
@property (nonatomic, retain) NSNumber * autostart;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) Entry * entry;
@property (nonatomic, retain) Project * autostartProject;
@property (nonatomic, retain) Task * autostartTask;

@end



