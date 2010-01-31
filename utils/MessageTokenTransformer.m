//
//  MessageTokenTransformer.m
//  ZiGT
//
//  Created by Michael Maier on 31.01.10.
//  Copyright 2010 VIVAI Software AG. All rights reserved.
//

#import "MessageTokenTransformer.h"
#import "MessageToken.h"
#import "NSArray+Utils.h"

@implementation MessageTokenTransformer

+ (Class)transformedValueClass {
    
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    
    return YES;
}

- (id)transformedValue:(id)value {
    
    NSArray* tokens= [(NSString*)value componentsSeparatedByString:@"^"];
    NSArray* result= [tokens map:^(id object) { 
    
        id tempResult= [MessageToken findMessageTokenForString:object];
        if( !tempResult )
            tempResult= object;
        return tempResult;
    }];
    
    return result;
    
}

- (id)reverseTransformedValue:(id)value {
        
    NSMutableString* result= [NSMutableString string];
    for( id object in value ) {

        if( [result length] > 0 )
            [result appendString:@"^"];

        if( [object isKindOfClass:[MessageToken class]] ) {
             
            [result appendString:[object token]];
        } // if         
        else {
            [result appendString:[object description]];
        } // else
        
    } // for 
    return result;
}
@end
