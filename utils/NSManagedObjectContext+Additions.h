#import <Cocoa/Cocoa.h>

@interface NSManagedObjectContext( Additions )

/**
 * liefert alle Objekte einer Entität zurück
 */
- (NSArray*)allMOsForEntityNamed:(NSString*)entityName;

/**
 * liefert das erste Objekte einer Entität zurück. Sollte nur eins sein.
 */
- (NSManagedObject*)firstMOForEntityNamed:(NSString*)entityName;


@end
