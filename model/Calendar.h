//
//  Calendar.h
//  ZiGT
//
//  Created by Michael Maier on 05.02.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Project;
@class ProxyAccount;

@interface Calendar :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* projects;
@property (nonatomic, retain) ProxyAccount * proxyAccount;

@end


@interface Calendar (CoreDataGeneratedAccessors)
- (void)addProjectsObject:(Project *)value;
- (void)removeProjectsObject:(Project *)value;
- (void)addProjects:(NSSet *)value;
- (void)removeProjects:(NSSet *)value;

@end

