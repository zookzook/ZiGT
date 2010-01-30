#import "ProxyAccount+Logic.h"
#import "Propfind.h"
#import "Calendar.h"

@implementation ProxyAccount( Logic )

- (void)calendarsFound:(Propfind*) reportRequest {
    
    NSMutableDictionary* oldCals= [NSMutableDictionary dictionary];
    for( Calendar* c in self.calendars ) {
        
        [oldCals setObject:c forKey:c.guid];        
    } // for 
    
    // Welche Kalendar wurden gelöscht?
    for( Calendar* c in [oldCals allValues] ) {
        
        // finden wir diese nicht mehr, so werden diese gelöscht.
        if( ![reportRequest.calendars objectForKey:c.guid] ) {
            
            [self removeCalendarsObject:c];
            [self.managedObjectContext deleteObject:c];            
        } // if 
    } // for 
    
    // Welche Kalendar sind neu?
    for( NSString* guid in [reportRequest.calendars allKeys] ) {
        
        Calendar* cal= [oldCals objectForKey:guid];
        if( !cal ) {
            Calendar* c= [NSEntityDescription insertNewObjectForEntityForName:@"Calendar" inManagedObjectContext:self.managedObjectContext]; 
            c.guid= guid;
            c.name= [reportRequest.calendars objectForKey:guid];
            [self addCalendarsObject:c];
        } // if 
        else {
            cal.name= [reportRequest.calendars objectForKey:guid];
        } // else
    } // for 
    
}

- (void)calendarsNotFound:(Propfind*) reportRequest {
    
}

@end
