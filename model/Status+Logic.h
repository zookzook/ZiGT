#import "Status.h"

typedef enum {
    
    STOPPED= 0,
    RUNNING= 1
    
} STATUS;

@interface Status( Logic )

- (void)awakeFromInsert;
- (BOOL)isRunning;
- (void)startProject:(Project *)newProject;
- (void)restart;
- (void)stop;

@end
