#import "Task+Logic.h"
#import "NSManagedObjectContext+Additions.h"

@implementation Task( Logic )

+ (void)prepareStandardTasks:(NSManagedObjectContext*)context {
    
    NSArray* tasks= [context allMOsForEntityNamed:@"Task"];
    
    if( [tasks count] == 0 ) {
        
        Task* task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.name= NSLocalizedString( @"Implementation", @"Implementation" );
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.name= NSLocalizedString( @"Analysis", @"Analysis" );
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.name= NSLocalizedString( @"Design", @"Design" );
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.name= NSLocalizedString( @"Support", @"Support" );
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.name= NSLocalizedString( @"MSIE", @"MSIE" );
    } // if 
}

@end
