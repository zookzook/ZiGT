//
//  Status.h
//  ZiGT
//
//  Created by Michael Maier on 05.02.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Entry;
@class Project;

@interface Status :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * rounding;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * minTimeinterval;
@property (nonatomic, retain) NSNumber * pushToServerTimeinterval;
@property (nonatomic, retain) Entry * entry;
@property (nonatomic, retain) Project * currentProject;

@end



