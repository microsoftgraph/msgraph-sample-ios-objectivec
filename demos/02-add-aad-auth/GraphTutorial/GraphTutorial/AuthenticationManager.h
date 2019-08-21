//
//  AuthenticationManager.h
//  GraphTutorial
//
//  Created by Jason Johnston on 8/21/19.
//  Copyright © 2019 Jason Johnston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MSAL/MSAL.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetTokenCompletionBlock)(NSString* _Nullable accessToken, NSError* _Nullable error);

@interface AuthenticationManager : NSObject

@property MSALPublicClientApplication* publicClient;

+ (id) instance;
- (void) getTokenInteractivelyWithCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) getTokenSilentlyWithCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) signOut;
@end

NS_ASSUME_NONNULL_END
