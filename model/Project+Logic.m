#import "Project+Logic.h"
#import "Entry+Logic.h"
#import "NSDate+Utils.h"
#import <AddressBook/AddressBook.h>
#import "Calendar.h"
#import "Task.h"
#import "ProxyAccount.h"
#import "MessageToken.h"
#import "NSArray+Utils.h"

@implementation Project( Logic )

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (Project*)projectByTag:(NSInteger)tag context:(NSManagedObjectContext*)context {
    
    Project* result= nil;
    NSEntityDescription *entityDescription= [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    NSFetchRequest      *request          = [[[NSFetchRequest alloc] init] autorelease];
    NSPredicate         *predicate        = [NSPredicate predicateWithFormat:@"tag = %@", [NSNumber numberWithInt:tag]];

    [request setEntity:entityDescription];    
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if( [array count] > 0 )
        result= [array lastObject];
    
    return result;
}

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (NSArray*)projectsContext:(NSManagedObjectContext*)context {
    
    NSError*                        error= nil;
    NSEntityDescription* entityDescription= [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
    NSFetchRequest*                request= [[[NSFetchRequest alloc] init] autorelease];
    NSSortDescriptor*       sortDescriptor= [[[NSSortDescriptor alloc] initWithKey:@"menuName" ascending:YES] autorelease];
    
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setEntity:entityDescription];    
        
    return [context executeFetchRequest:request error:&error];
}

/**
 * Falls der ProxyAccount nicht mehr sichtbar sein soll, dann werden
 * seine Kalendar aus den Projekt entfernt.
 */
+ (void)syncCalendarsFromProxy:(ProxyAccount *)account managedObjectContext:(NSManagedObjectContext*)context {
    
    if( ![account.visible boolValue] ) {
        
        NSSet* cals= account.calendars;
        
        for( Project* p in [self projectsContext:context] ) {
            
            if( [cals containsObject:p.calendar] ) {
                
                p.calendar= nil;
            } // if 
        } // for         
    } // if
}

- (void)stop:(Entry *)newEntry {
    
    if( !newEntry.finishedAt )
        newEntry.finishedAt= [NSDate date];
    
    newEntry.stored= [NSNumber numberWithBool:NO];
    [self addEntriesObject:newEntry];    
}

- (NSString*)summaryForEntry:(Entry*)entry {
    
    NSArray* tokens= [self.messageExpression componentsSeparatedByString:@"^"];
    NSMutableString* result= [NSMutableString string];
    for( NSString* token in tokens ) {
        
        MessageToken* mt= [MessageToken findMessageTokenForString:token];
        if( mt ) {
            
            if( [mt.token isEqualToString:@"@User@"] ) {
                
                ABAddressBook*       ab= [ABAddressBook sharedAddressBook];
                ABPerson*            me= [ab me];
                NSString*     firstname= [me valueForProperty:kABFirstNameProperty];
                NSString*     lastname= [me valueForProperty:kABLastNameProperty];
                
                if( firstname )
                    [result appendFormat:@"%@ %@", firstname, lastname];
                else
                    if( lastname )
                        [result appendString:lastname];
            } // if 
            else
            if( [mt.token isEqualToString:@"@Project@"] ) {
                
                [result appendString:self.name];
            } // if
            else
                if( [mt.token isEqualToString:@"@Task@"] ) {
                    
                    [result appendString:self.task.name];
                } // if
                else
                    if( [mt.token isEqualToString:@"@Time@"] ) {
                        
                        [result appendString:[entry timeIntervalDescription:entry.finishedAt]];
                    } // if
            
        } // if 
        else
            [result appendString:token];
    } // for 
    
    return result;
}

- (BOOL)hasConnectivity {
    
    return self.calendar.guid != nil;
}

@end
