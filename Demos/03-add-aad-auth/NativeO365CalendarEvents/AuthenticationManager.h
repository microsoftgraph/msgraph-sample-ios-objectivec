//
//  AuthenticationManager.h
//  NativeO365CalendarEvents
//
//  Created by Andrew Connell on 11/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MSAL/MSAL.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthenticationManager : NSObject

// implement singleton pattern as a shared instance
+(AuthenticationManager*)sharedInstance;

// public members
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) MSALPublicClientApplication *msalClient;
@property (nonatomic, weak) NSString *clientId;
@property (nonatomic, weak) NSString *authorty;
@property (nonatomic, strong) MSALUser *user;

// public methods
- (void)initWithAuthority:(NSString*)authority
               completion:(void (^)(NSError *error))completion;

- (void)acquireAuthTokenWithScopes:(NSArray<NSString *> *)scopes completion:(void(^)(MSALErrorCode error))completion;

- (void)acquireAuthTokenCompletion:(void (^)(MSALErrorCode *error))completion;

- (void)clearCredentials;

- (NSString *)getRedirectUrlFromMSALArray:(NSArray *) array;

@end

NS_ASSUME_NONNULL_END
