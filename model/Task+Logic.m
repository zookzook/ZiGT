#import "Task+Logic.h"
#import "NSManagedObjectContext+Additions.h"

@implementation Task( Logic )

+ (void)prepareStandardTasks:(NSManagedObjectContext*)context {
    
    NSArray* tasks= [context allMOsForEntityNamed:@"Task"];
    
    if( [tasks count] == 0 ) {
        
        Task* task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Analysis", @"Analysis" );
        task.name= ANALYSIS_TASK;
        
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Design", @"Design" );
        task.name= DESIGN_TASK;
        
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Documentation", @"Documentation" );
        task.name= DOCUMENTATION_TASK;
        
        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Implementation", @"Implementation" );
        task.name= IMPLEMENTATION_TASK;

        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Support", @"Support" );
        task.name= SUPPORT_TASK;

        task= [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:context];
        task.displayName= NSLocalizedString( @"Testing", @"Testing" );
        task.name= TESTING_TASK;
        
    } // if 
}

+ (NSArray*)tasks:(NSManagedObjectContext*)context {
    
    NSError*                        error= nil;
    NSEntityDescription* entityDescription= [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
    NSFetchRequest*                request= [[[NSFetchRequest alloc] init] autorelease];
    NSSortDescriptor*       sortDescriptor= [[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES] autorelease];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setEntity:entityDescription];    
    
    return [context executeFetchRequest:request error:&error];
}

- (NSImage*)menuItemImage {

    return [NSImage imageNamed:NSLocalizedString( self.name, @"" )];
}

- (NSImage*)highlightedMenuItemImage {
    
    return [NSImage imageNamed:[NSLocalizedString( self.name, @"" ) stringByAppendingString:@"_hi"]];
}

@end
