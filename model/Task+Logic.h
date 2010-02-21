#import "Task.h"

#define ANALYSIS_TASK @"ANALYSIS_TASK"
#define DESIGN_TASK @"DESIGN_TASK"
#define DOCUMENTATION_TASK @"DOCUMENTATION_TASK"
#define IMPLEMENTATION_TASK @"IMPLEMENTATION_TASK"
#define SUPPORT_TASK @"SUPPORT_TASK"
#define TESTING_TASK @"TESTING_TASK"

@interface Task( Logic )

+ (void)prepareStandardTasks:(NSManagedObjectContext*)context;

+ (NSArray*)tasks:(NSManagedObjectContext*)context;

- (NSImage*)menuItemImage;
- (NSImage*)highlightedMenuItemImage;
- (NSImage*)statusMenuItemImage;

@end
