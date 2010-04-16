#import "Status.h"

@class Project, Task;

typedef enum {
    
    STOPPED= 0,
    RUNNING= 1
    
} STATUS;

@interface Status( Logic )

- (Project*)currentProject;
- (Task*)currentTask;

- (void)awakeFromInsert;
- (BOOL)isRunning;
- (void)startProject:(Project *)newProject withTask:(Task*)newTask;
- (void)restart;
- (void)stop;

- (NSImage*)image:(BOOL)highlighted hasConnectivity:(BOOL)connectivity;
- (BOOL)hasAutostartProject;

@end
