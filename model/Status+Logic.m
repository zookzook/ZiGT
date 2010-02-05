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

- (void)startProject:(Project *)newProject withTask:(Task*)newTask {

    // wird das Project gewechselt, dann aktualisieren wir das alte.
    if( self.currentProject != newProject ) {
        
        self.currentProject.active= [NSNumber numberWithBool:NO];
        // haben wir noch einen aktuellen Eintrag, dann kommt der weg.
        if( self.entry ) {
            
            [self.managedObjectContext deleteObject:self.entry];
            self.entry= nil;
        } // if 
    } // if
    
    self.currentProject       = newProject;
    self.currentProject.active= [NSNumber numberWithBool:YES];
    
    // wir legen einen neuen Eintrag ein.
    if( !self.entry ) {
        
        Entry*    entry= [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext]; 
        entry.startedAt= [NSDate date];        
        entry.stored   = [NSNumber numberWithBool:YES];
        self.entry     = entry;
    } // if 
    
    self.state= [NSNumber numberWithInt:RUNNING];
    
    self.entry.project= self.currentProject;
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
