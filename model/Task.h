//
//  Task.h
//  ZiGT
//
//  Created by Michael Maier on 28.01.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Task :  NSManagedObject  
{
}

@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * name;

@end



