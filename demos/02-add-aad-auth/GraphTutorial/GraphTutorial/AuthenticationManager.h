//
//  AuthenticationManager.h
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import <Foundation/Foundation.h>
#import <MSAL/MSAL.h>
#import <MSGraphMSALAuthProvider/MSGraphMSALAuthProvider.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetTokenCompletionBlock)(NSString* _Nullable accessToken, NSError* _Nullable error);

@interface AuthenticationManager : NSObject

+ (id) instance;
- (void) getTokenInteractivelyWithCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) getTokenSilentlyWithCompletionBlock: (GetTokenCompletionBlock)completionBlock;
- (void) signOut;
- (MSALAuthenticationProvider*) getGraphAuthProvider;

@end

NS_ASSUME_NONNULL_END
