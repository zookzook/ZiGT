#import "NSManagedObjectContext+Additions.h"

@implementation NSManagedObjectContext( Additions )

/**
 * liefert alle Objekte einer Entität zurück
 */
- (NSArray*)allMOsForEntityNamed:(NSString*)entityName {
	
    NSFetchRequest *fetchRequest= [[NSFetchRequest alloc] init];
    NSError        *fetchError  = nil;
    NSArray        *result;
    
    @try {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
        [fetchRequest setEntity:entity];
        result= [self executeFetchRequest:fetchRequest error:&fetchError];
		
		if( fetchError ) {
			
		} // if 
        
    } @finally {
        [fetchRequest release];
    } // finally
	
	return result;
}

/**
 * liefert das erste Objekte einer Entität zurück. Sollte nur eins sein.
 */
- (NSManagedObject*)firstMOForEntityNamed:(NSString*)entityName {
    
    NSManagedObject *result    = nil;
    NSArray         *tempResult= [self allMOsForEntityNamed:entityName];
    
    if( [tempResult count] > 0 )
        result= [tempResult lastObject];
    
    return result;
}


@end
