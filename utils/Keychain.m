//
//  Keychain.m
//  Keychain
//
//  Created by Wade Tregaskis on Fri Jan 24 2003.
//  Modified by Wade Tregaskis & Mark Ackerman on Mon Sept 29 2003 [redone all the password-related methods].
//
//  Copyright (c) 2003, Wade Tregaskis.  All rights reserved.
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//    * Neither the name of Wade Tregaskis nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "Keychain.h"

@implementation Keychain
+ (Keychain*)defaultKeychain {
    static Keychain *defaultKeychain;
    
    if (defaultKeychain == nil) {
        // The following doesn't need to be thread safe, even with the shared static object, because the underlying NSCachedObject will prevent two copies being created, and thus the later of the two racing assignments will just be resetting the same value
        defaultKeychain = [[Keychain alloc] initFromDefault];
    }
    
    return defaultKeychain;
}

- (Keychain*)initFromDefault {    
    error = SecKeychainCopyDefault(&keychain);
    
    if (error != CSSM_OK) {
        [self release];
        self = nil;
    } else {
        if (self = [super init]) {
            error = CSSM_OK;
        }
    }
    
    return self;
}

- (void)addGenericPassword:(NSString*)password onService:(NSString*)service forAccount:(NSString*)account replaceExisting:(BOOL)replace {
    // SecKeychainAddGenericPassword() will enter new item into keychain, if item with attributes service and account don't already exist in keychain;  returns errSecDuplicateItem if the item already exists;  uses strlen() and UTF8String in place of cStringLength and cString;  passes NULL for &itemRef since SecKeychainItemRef isn't needed, and SecKeychainItemRef won't be returned in &itemRef if errSecDuplicateItem is returned (at least that's been my experience;  couldn't find this behavio(u)r documented)
    
    error = SecKeychainAddGenericPassword(keychain, strlen([service UTF8String]), [service UTF8String], strlen([account UTF8String]), [account UTF8String], strlen([password UTF8String]), [password UTF8String], NULL);
    
    // if we have a duplicate item error and user indicates that password should be replaced...
    if(error == errSecDuplicateItem && replace == YES) {
        UInt32 existingPasswordLength;
        char* existingPasswordData ;
        SecKeychainItemRef existingItem;
        
        // ...get the existing password and a reference to the existing keychain item, then...
        error = SecKeychainFindGenericPassword(keychain, strlen([service UTF8String]), [service UTF8String], strlen([account UTF8String]), [account UTF8String], &existingPasswordLength, (void **)&existingPasswordData, &existingItem);
        
        // ...check to see that the passwords are not the same (no reason to muck around in the keychain if we don't need to;  this check may not be required, depending on whether it is anticipated that this method would be called with the same password as the password for an existing keychain item)  and if the passwords are not the same...
        if(![password isEqualToString:[NSString stringWithCString:existingPasswordData length:existingPasswordLength]]) {
            
            // ...modify the password for the existing keychain item;  (I'll admit to being mystified as to how this function works;  how does it know that it's the password data that's being modified??;  anyway, it seems to work); and finally...
            // Answer: the data of a keychain item is what is being modified.  In the case of internet or generic passwords, the data is the password.  For a certificate, for example, the data is the certificate itself.
            
            error = SecKeychainItemModifyContent(existingItem, NULL, strlen([password UTF8String]), (void *)[password UTF8String]);
        }
        
        // ...free the memory allocated in call to SecKeychainFindGenericPassword() above
        SecKeychainItemFreeContent(NULL, existingPasswordData);
        
        if (existingItem) {
            CFRelease(existingItem);
        }
    }
}

- (void)deletePasswordForGenericService:(NSString*)service forAccount:(NSString*)account {
    UInt32 existingPasswordLength;
    char* existingPasswordData;
    SecKeychainItemRef existingItem;
    
    // ...get the existing password and a reference to the existing keychain item, then...
    error = SecKeychainFindGenericPassword(keychain, strlen([service UTF8String]), [service UTF8String], strlen([account UTF8String]), [account UTF8String], &existingPasswordLength, (void **)&existingPasswordData, &existingItem);
    
    if (error == 0 && existingItem) {
        error = SecKeychainItemDelete(existingItem);
    }
    
    // ...free the memory allocated in call to SecKeychainFindGenericPassword() above
    SecKeychainItemFreeContent(NULL, existingPasswordData);
    
    if (existingItem) {
        CFRelease(existingItem);
    }
}

// The following methods for passwordForGenericService: and genericService: were contributed by Mark Ackerman.  The passwordForInternetServer: and internetServer: methods were derived directly from them by Wade Tregaskis.

- (NSString*)passwordForGenericService:(NSString*)service forAccount:(NSString*)account {
    char *passData;
    UInt32 passLength;
    
    error = SecKeychainFindGenericPassword(keychain, strlen([service UTF8String]), [service UTF8String], strlen([account UTF8String]), [account UTF8String], &passLength, (void**)&passData, NULL);
    
    if (error == CSSM_OK) {
        return [[[NSString alloc] initWithCStringNoCopy:passData length:passLength freeWhenDone:YES] autorelease];
    } else {
        return nil;
    }
}
@end
