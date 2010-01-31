#import <Cocoa/Cocoa.h>

@interface MessageToken : NSObject {

    NSString*   token;
}

@property (nonatomic, retain) NSString *token;

+ (NSArray*)possibleMessageTokens;
+ (MessageToken*)findMessageTokenForString:(NSString*)messageText;
+ (MessageToken*)messageTokenWithToken:(NSString*)newToken;

@end