#import "Project.h"

@class ProxyAccount;

@interface Project( Logic )

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (Project*)projectByTag:(NSInteger)tag context:(NSManagedObjectContext*)context;

/**
 * Liefert das Project für ein bestimmtes Tag zurück.
 */
+ (NSArray*)projectsContext:(NSManagedObjectContext*)context;

/**
 * Falls der ProxyAccount nicht mehr sichtbar sein soll, dann werden
 * seine Kalendar aus den Projekt entfernt.
 */
+ (void)syncCalendarsFromProxy:(ProxyAccount *)account managedObjectContext:(NSManagedObjectContext*)context;

- (void)stop:(Entry *)newEntry;

- (NSString*)summaryForEntry:(Entry*)entry;

- (BOOL)hasConnectivity;

@end
