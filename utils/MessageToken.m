#import "MessageToken.h"

@implementation MessageToken

@synthesize token;

+ (NSArray*)possibleMessageTokens {

    static NSArray* _possibleMessageTokens;
    if( !_possibleMessageTokens ) {
        
        _possibleMessageTokens= [[NSArray alloc] initWithObjects:[self messageTokenWithToken:@"@User@"], 
                                 [self messageTokenWithToken:@"@Project@"], 
                                 [self messageTokenWithToken:@"@Task@"], 
                                 [self messageTokenWithToken:@"@Time@"],
                                 nil];
    } // if 
    return _possibleMessageTokens;
}

+ (MessageToken*)findMessageTokenForString:(NSString*)messageText {
    
    MessageToken* result= nil;
    for( MessageToken* mt in [self possibleMessageTokens] ) {
        
        if( [mt.token isEqualToString:messageText] ) {
            
            result= mt;
            break;
        } // if             
    } // for 
    
    return result;
}

+ (MessageToken*)messageTokenWithToken:(NSString*)newToken {
    
    MessageToken* result= [[self alloc] init];
    result.token= newToken;
    return [result autorelease];
}

@end
