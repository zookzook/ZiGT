#import "Status+Logic.h"
#import "Project.h"
#import "Entry.h"
#import "Task.h"

@implementation Status( Logic )

- (void)awakeFromInsert {
    
    self.state= [NSNumber numberWithInt:STOPPED];
}

- (BOOL)isRunning {
    
    return [self.state intValue] == RUNNING;
}

- (Project*)currentProject {
    
    return self.entry.project;    
}

- (Task*)currentTask {
    
    return self.entry.task;
}

- (void)startProject:(Project *)newProject withTask:(Task*)newTask {

    if( self.entry ) {
        
        [self.managedObjectContext deleteObject:self.entry];
        self.entry= nil;
    } // if 
        
    Entry*    entry= [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext]; 
    entry.startedAt= [NSDate date];        
    entry.stored   = [NSNumber numberWithBool:YES];
    self.entry     = entry;
    
    self.state= [NSNumber numberWithInt:RUNNING];

    self.entry.project= newProject;
    self.entry.task   = newTask;

    NSLog( @"Starte Project %@ mit Task %@", self.currentProject, self.entry.task );
}

- (void)restart {
    
    [self startProject:self.currentProject withTask:self.entry.task];
}

- (void)stop {
    
    self.state= [NSNumber numberWithInt:STOPPED];
}

@end
