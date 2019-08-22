//
//  AuthenticationManager.m
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import "AuthenticationManager.h"

@interface AuthenticationManager()

@property NSString* appId;
@property NSArray<NSString*>* graphScopes;
@property MSALPublicClientApplication* publicClient;

@end

@implementation AuthenticationManager

+ (id) instance {
    static AuthenticationManager *singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        singleInstance = [[self alloc] init];
    });
    
    return singleInstance;
}

- (id) init {
    if (self = [super init]) {
        // Get app ID and scopes from AuthSettings.plist
        NSString* authConfigPath =
        [NSBundle.mainBundle pathForResource:@"AuthSettings" ofType:@"plist"];
        NSString* bundleId = NSBundle.mainBundle.bundleIdentifier;
        NSDictionary* authConfig = [NSDictionary dictionaryWithContentsOfFile:authConfigPath];
        
        self.appId = authConfig[@"AppId"];
        self.graphScopes = authConfig[@"GraphScopes"];
        
        // Create the MSAL client
        self.publicClient = [[MSALPublicClientApplication alloc] initWithClientId:self.appId
                                                                    keychainGroup:bundleId
                                                                            error:nil];
    }
    
    return self;
}

- (void) getTokenInteractivelyWithCompletionBlock:(GetTokenCompletionBlock)completionBlock {
    // Call acquireToken to open a browser so the user can sign in
    [self.publicClient
     acquireTokenForScopes:self.graphScopes
     completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
        
        // Check error
        if (error) {
            completionBlock(nil, error);
            return;
        }
        
        // Check result
        if (!result) {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"No result was returned" forKey:NSDebugDescriptionErrorKey];
            completionBlock(nil, [NSError errorWithDomain:@"AuthenticationManager" code:0 userInfo:details]);
            return;
        }
        
        NSLog(@"Got token interactively: %@", result.accessToken);
        completionBlock(result.accessToken, nil);
    }];
}

- (void) getTokenSilentlyWithCompletionBlock:(GetTokenCompletionBlock)completionBlock {
    // Check if there is an account in the cache
    NSError* msalError;
    MSALAccount* account = [self.publicClient allAccounts:&msalError].firstObject;
    
    if (msalError || !account) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"Could not retrieve account from cache" forKey:NSDebugDescriptionErrorKey];
        completionBlock(nil, [NSError errorWithDomain:@"AuthenticationManager" code:0 userInfo:details]);
        return;
    }
    
    // Attempt to get token silently
    [self.publicClient
     acquireTokenSilentForScopes:self.graphScopes account:account
     completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
         // Check error
         if (error) {
             completionBlock(nil, error);
             return;
         }
         
         // Check result
         if (!result) {
             NSMutableDictionary* details = [NSMutableDictionary dictionary];
             [details setValue:@"No result was returned" forKey:NSDebugDescriptionErrorKey];
             completionBlock(nil, [NSError errorWithDomain:@"AuthenticationManager" code:0 userInfo:details]);
             return;
         }
         
         NSLog(@"Got token silently: %@", result.accessToken);
         completionBlock(result.accessToken, nil);
     }];
}

- (void) signOut {
    NSError* msalError;
    NSArray* accounts = [self.publicClient allAccounts:&msalError];
    
    if (msalError) {
        NSLog(@"Error getting accounts from cache: %@", msalError.debugDescription);
        return;
    }
    
    for (id account in accounts) {
        [self.publicClient removeAccount:account error:nil];
    }
}

- (MSALAuthenticationProvider*) getGraphAuthProvider {
    // Create an MSAL auth provider for use with the Graph client
    return [[MSALAuthenticationProvider alloc]
            initWithPublicClientApplication:self.publicClient
            andScopes:self.graphScopes];
}

@end
