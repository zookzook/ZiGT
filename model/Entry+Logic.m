#import <AddressBook/AddressBook.h>
#import "Entry+Logic.h"
#import "Project+Logic.h"
#import "NSDate+Utils.h"
#import "NSString+Utils.h"
#import "Calendar.h"
#import "Task.h"
#import "ProxyAccount.h"
#import "MessageToken.h"
#import "NSArray+Utils.h"

@implementation Entry( Logic )

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (NSArray*)unstoredWithContext:(NSManagedObjectContext*)context {
    
    NSEntityDescription *entityDescription= [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:context];
    NSFetchRequest      *request          = [[[NSFetchRequest alloc] init] autorelease];
    NSPredicate         *predicate        = [NSPredicate predicateWithFormat:@"stored = NO"];
    
    [request setEntity:entityDescription];    
    [request setPredicate:predicate];
    
    NSError *error;
    return [context executeFetchRequest:request error:&error];
}

- (void)awakeFromInsert {
    
    self.uuid= [NSString uuid];
}

/**
 * Aktuelles Zeitinterval zwischen Start und Ende.
 */
- (NSTimeInterval)timeInterval {
    
    return [self.finishedAt timeIntervalSinceDate:self.startedAt];
}

/**
 * Liefert die Dauer formatiert zurück.
 */
- (NSString*)timeIntervalDescription:(NSDate*)now {
    
    static NSDateFormatter* _formatter;
    
    if( !_formatter ) {
        
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"HH:mm:ss"];        
    } // if 
    
    if( !now )
        now= [NSDate date];                        
    
    NSTimeInterval diffTime= [now timeIntervalSinceReferenceDate] - [self.startedAt timeIntervalSinceReferenceDate] - [[NSTimeZone defaultTimeZone] secondsFromGMT];
    NSDate*           diffDate= [NSDate dateWithTimeIntervalSinceReferenceDate:diffTime];            
    return [NSString stringWithFormat:NSLocalizedString( @"Duration %@", @"StopWatch" ), [_formatter stringFromDate:diffDate]];
}

/**
 * Erzeugt den VCalendar-Eintrag.
 */
- (NSString *)vcalendar {
    
    NSMutableString* result= [NSMutableString string];
    
    [result appendString:@"BEGIN:VCALENDAR\r\n"];
    [result appendString:@"VERSION:2.0\r\n"];
    [result appendString:@"PRODID:-//ZiGT//ZiGT 0.0//EN\r\n"];
    [result appendString:@"CALSCALE:GREGORIAN\r\n"];
    [result appendString:[self vevent]];
    [result appendString:@"END:VCALENDAR\r\n"];

    return result;
}

-(NSString*)summary {
    
    NSArray* tokens= [self.project.messageExpression componentsSeparatedByString:@"^"];
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
                    
                    [result appendString:self.project.name];
                } // if
                else
                    if( [mt.token isEqualToString:@"@Task@"] ) {
                        
                        [result appendString:self.task.displayName];
                    } // if
                    else
                        if( [mt.token isEqualToString:@"@Time@"] ) {
                            
                            [result appendString:[self timeIntervalDescription:self.finishedAt]];
                        } // if
            
        } // if 
        else
            [result appendString:token];
    } // for 
    
    return result;
}

/**
 * Erzeugt den VEVENT-Eintrag.
 */
- (NSString *)vevent {
    
    NSMutableString* result= [NSMutableString string];
    
    NSString* now= [[NSDate date] UTCString];
    
    NSDate* start= self.startedAt;
    if( self.startedAtRounded )
        start= self.startedAtRounded;
    
    NSDate* end= self.finishedAt;
    if( self.finishedAtRounded )
        end= self.finishedAtRounded;
    if( !end )
        end= [NSDate date];
        
    [result appendString:@"BEGIN:VEVENT\r\n"];
    [result appendFormat:@"DTSTART:%@\r\n", [start UTCString]];
    
    [result appendFormat:@"DTEND:%@\r\n", [end UTCString]];
    [result appendFormat:@"UID:%@\r\n", [self uuid]];
    [result appendFormat:@"DTSTAMP:%@\r\n", now ];
    [result appendFormat:@"CREATED:%@\r\n", now ];
    [result appendFormat:@"SUMMARY:%@\r\n", [self summary]];
    
    if( self.info )
        [result appendFormat:@"DESCRIPTION:%@\r\n", self.info ];
    if( self.url )
        [result appendFormat:@"URL;VALUE=URI:%@\r\n", self.url ];
    
    [result appendString:@"END:VEVENT\r\n"];

    return result;    
}


/**
 * Zeiten werden gerundet bzgl. der Minutenzahl:
 * Startzeit wird abgerundet, so dass minutes ein Teiler ist
 * Endzeit wird aufgerundet, so dass minutes ein Teiler ist
 */
- (void)roundBy:(NSInteger)minutes {
        
    NSTimeInterval newStartInterval;
    NSTimeInterval startInterval= [self.startedAt timeIntervalSinceReferenceDate];
    NSTimeInterval          base= startInterval - ((NSInteger)startInterval % (minutes * 60));
//    if( startInterval - base > minutes * 60 / 2 )
//        newStartInterval= base + minutes * 60;
//    else 
        newStartInterval= base + minutes * 60;

    self.startedAt= [NSDate dateWithTimeIntervalSinceReferenceDate:newStartInterval];
    
    if( self.finishedAt ) {
        
        NSTimeInterval newEndInterval;
        NSTimeInterval   endInterval= [self.finishedAt timeIntervalSinceReferenceDate]; //  + (minutes * 60);
                                base= endInterval - ((NSInteger)(endInterval) % (minutes * 60));
        
//        if( endInterval - base > minutes * 60 / 2 )
            newEndInterval= base + minutes * 60;
//        else 
//            newEndInterval= base;
        
        self.finishedAt= [NSDate dateWithTimeIntervalSinceReferenceDate:newEndInterval];        
    } // if 
    
    NSLog( @"Started-At:%@", self.startedAt );
    NSLog( @"Finished-At:%@", self.finishedAt );
}

- (void)roundStartedAtBy:(NSInteger)minutes {
    
    self.startedAtRounded= [self.startedAt copy];
    
    NSTimeInterval newStartInterval;
    NSTimeInterval startInterval= [self.startedAtRounded timeIntervalSinceReferenceDate];
    NSTimeInterval          base= startInterval - ((NSInteger)startInterval % (minutes * 60));
    newStartInterval= base + minutes * 60;
    
    self.startedAtRounded= [NSDate dateWithTimeIntervalSinceReferenceDate:newStartInterval];        
}

- (void)roundFinishedAtBy:(NSInteger)minutes {
    
    self.finishedAtRounded= [self.finishedAt copy];
    
    NSTimeInterval    endInterval= [self.finishedAtRounded timeIntervalSinceReferenceDate]; //  + (minutes * 60);
    NSTimeInterval           base= endInterval - ((NSInteger)(endInterval) % (minutes * 60));
    NSTimeInterval newEndInterval= base + minutes * 60;
    self.finishedAtRounded= [NSDate dateWithTimeIntervalSinceReferenceDate:newEndInterval];        
}

- (BOOL)hasConnectivity {
    
    return YES;
}

@end

