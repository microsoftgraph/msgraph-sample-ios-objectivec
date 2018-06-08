#import <Foundation/Foundation.h>
#import <MSAL/MSAL.h>

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

- (NSString *)getRedirectUrlFromMSALArray:(NSArray *) array;

@end
