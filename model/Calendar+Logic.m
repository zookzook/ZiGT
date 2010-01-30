#import "Calendar+Logic.h"
#import "ProxyAccount.h"

@implementation Calendar( Logic )

- (NSString*)fullname {
    
    return [NSString stringWithFormat:@"%@: %@", self.proxyAccount.name, self.name];
}

@end
