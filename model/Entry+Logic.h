#import "Entry.h"

@interface Entry( Logic )

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (NSArray*)unstoredWithContext:(NSManagedObjectContext*)context;

/**
 * Erzeugt den VCalendar-Eintrag.
 */
- (NSString *)vcalendar;

/**
 * Erzeugt den VEVENT-Eintrag.
 */
- (NSString *)vevent;

/**
 * Aktuelles Zeitinterval zwischen Start und Ende.
 */
- (NSTimeInterval)timeInterval;

/**
 * Formatierte Zeitausgabe zwischen Start und Ende.
 */
- (NSString*)timeIntervalDescription:(NSDate*)now;

/**
 * Zeiten werden gerundet bzgl. der Minutenzahl:
 * Startzeit wird abgerundet, so dass minutes ein Teiler ist
 * Endzeit wird aufgerundet, so dass minutes ein Teiler ist
 */
- (void)roundBy:(NSInteger)minutes;

- (BOOL)hasConnectivity;

@end
