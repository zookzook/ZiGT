#import <QuartzCore/CIFilter.h>
#import "Status+Logic.h"
#import "Project.h"
#import "Entry.h"
#import "Task+Logic.h"

@implementation Status( Logic )

- (void)awakeFromInsert {
    
    self.state= [NSNumber numberWithInt:STOPPED];
}

- (BOOL)isRunning {
    
    return [self.state intValue] == RUNNING;
}

- (Project*)currentProject {
    
    return self.entry.project;    
}

- (Task*)currentTask {
    
    return self.entry.task;
}

- (void)startProject:(Project *)newProject withTask:(Task*)newTask {

    if( self.entry ) {
        
        [self.managedObjectContext deleteObject:self.entry];
        self.entry= nil;
    } // if 
        
    Entry*    entry= [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext]; 
    entry.startedAt= [NSDate date];        
    entry.stored   = [NSNumber numberWithBool:YES];
    self.entry     = entry;
    
    self.entry.project= newProject;
    self.entry.task   = newTask;

    self.state= [NSNumber numberWithInt:RUNNING];
    NSLog( @"Starte Project %@ mit Task %@", self.currentProject, self.entry.task );
}

- (void)restart {
    
    [self startProject:self.currentProject withTask:self.entry.task];
}

- (void)stop {
    
    self.state= [NSNumber numberWithInt:STOPPED];
}


- (NSImage*)image:(BOOL)highlighted hasConnectivity:(BOOL)connectivity {
        
    float height  = 22.0;
    float space   = 3.0;
    float fontSize= 15.0;
    
    NSImage* result= nil;
    
    if( self.entry ) {

        NSString* text= self.entry.project.menuName;
        
        NSColor *textColor = [NSColor controlTextColor];
        if( highlighted )
            textColor= [NSColor selectedMenuItemTextColor];
        
        NSFont *msgFont = [NSFont menuBarFontOfSize:fontSize];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
        [paraStyle setAlignment:NSCenterTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSMutableDictionary *msgAttrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         msgFont, NSFontAttributeName,
                                         textColor, NSForegroundColorAttributeName,
                                         paraStyle, NSParagraphStyleAttributeName,
                                         nil];
        [paraStyle release];
        
        NSSize msgSize = [text sizeWithAttributes:msgAttrs];
        
        NSImage* taskImage= [self.entry.task statusMenuItemImage];
        if( highlighted )
            taskImage= [self.entry.task highlightedMenuItemImage];
        
        NSRect fromRect= NSMakeRect( 0.0, 0.0, 0.0, 0.0 );
        NSImage* disconnectedImage= [NSImage imageNamed:@"disconnected"];

        
        float width=  msgSize.width + space + [taskImage size].width + space;
        if( !connectivity ) {            
            width= [disconnectedImage size].width + space + msgSize.width + space + [taskImage size].width + space;
        } // if 
        
        NSSize imageSize= NSMakeSize( width, height );
        result = [[NSImage alloc] initWithSize:imageSize];
        
        [result lockFocus];
        float x= 0.0;
        
        if( !connectivity ) {
            
            fromRect.size= [disconnectedImage size];
            [disconnectedImage drawAtPoint: NSMakePoint( x, floor( (height - [disconnectedImage size].height) / 2.0) )
                                  fromRect: fromRect
                                 operation: NSCompositeSourceOver
                                  fraction: 1.0];                    
        
            x+= [disconnectedImage size].width + space;
        } // if 
                
        NSRect msgRect = NSMakeRect(0, 0, msgSize.width, msgSize.height);
        msgRect.origin.x = x;
        msgRect.origin.y = ([result size].height - msgSize.height) / 2.0;
        
        [text drawInRect:msgRect withAttributes:msgAttrs];
        
        x+=  msgSize.width + space;
        fromRect.size= [taskImage size];
                
        if( NO) {

            if( NO ) {
                
                NSBitmapImageRep*     rep= (NSBitmapImageRep*)[taskImage bestRepresentationForRect:fromRect context:[NSGraphicsContext currentContext] hints:nil];    
                CIImage*          ciImage= [[CIImage alloc] initWithBitmapImageRep: rep];        
                CIFilter* colorMonochrome= [CIFilter filterWithName:@"CIColorMonochrome"];
                CIColor*       blackColor= [CIColor colorWithString:@"0.0 0.0 0.0 1.0"];
                
                [colorMonochrome setDefaults];
                [colorMonochrome setValue: ciImage forKey: @"inputImage"];
                [colorMonochrome setValue: [NSNumber numberWithFloat: 1.0] forKey: @"inputIntensity"];
                [colorMonochrome setValue: blackColor forKey: @"inputColor"];
                
                CIImage* outImage= [colorMonochrome valueForKey: @"outputImage"];
                
                [outImage drawAtPoint: NSMakePoint(msgSize.width + space, floor( (height - [taskImage size].height) / 2.0) )
                             fromRect:  fromRect
                            operation: NSCompositeSourceOver
                             fraction: 1.0];
                
                [ciImage release];
            }
        } // 

        [taskImage drawAtPoint: NSMakePoint( x, floor( (height - [taskImage size].height) / 2.0) )
                      fromRect:  fromRect
                     operation: NSCompositeSourceOver
                      fraction: 1.0];        
        
        [result unlockFocus];
        [result autorelease];
    } // if 

    return result;
}


@end
