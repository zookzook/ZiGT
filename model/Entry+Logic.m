#import "Entry+Logic.h"
#import "Project+Logic.h"
#import "NSDate+Utils.h"
#import "NSString+Utils.h"

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

/**
 * Erzeugt den VEVENT-Eintrag.
 */
- (NSString *)vevent {
    
    NSMutableString* result= [NSMutableString string];
    
    NSString* now= [[NSDate date] UTCString];
    
    [result appendString:@"BEGIN:VEVENT\r\n"];
    [result appendFormat:@"DTSTART:%@\r\n", [[self startedAt] UTCString]];
    
    NSDate* end= self.finishedAt;
    if( !end )
        end= [NSDate date];
    
    [result appendFormat:@"DTEND:%@\r\n", [end UTCString]];
    [result appendFormat:@"UID:%@\r\n", [self uuid]];
    [result appendFormat:@"DTSTAMP:%@\r\n", now ];
    [result appendFormat:@"CREATED:%@\r\n", now ];
    [result appendFormat:@"SUMMARY:%@\r\n", [self.project summary]];
    
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

- (BOOL)hasConnectivity {
    
    return [self.project hasConnectivity];
}

@end

