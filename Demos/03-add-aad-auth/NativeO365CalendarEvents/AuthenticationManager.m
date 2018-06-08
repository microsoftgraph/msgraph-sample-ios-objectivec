#import <MSAL/MSAL.h>
#import "AuthenticationManager.h"

@implementation AuthenticationManager

#pragma mark - init
- (void)initWithAuthority:(NSString*)authority_
               completion:(void (^)(NSError* error))completion
{
    //Get the MSAL client Id for this Azure app registration. We store it in the main bundle
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSArray *array = [dictionary objectForKey:@"CFBundleURLTypes"];
    NSString *redirectUrl = [self getRedirectUrlFromMSALArray:(array)];
    
    NSRange range = [redirectUrl rangeOfString:@"msal"];
    NSString *kClientId = [[redirectUrl substringFromIndex:NSMaxRange(range)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"client id = %@", kClientId);
    
    self.clientId = kClientId;
    self.authorty = authority_;
    
    NSError *error_ = nil;
    @try {
        self.msalClient = [[MSALPublicClientApplication alloc] initWithClientId:kClientId error:&error_];
        if (error_) {
            completion(error_);
        } else {
            completion(nil);}
    }
    @catch(NSException *exception) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:exception.name forKey:@"ExceptionName"];
        [info setValue:exception.reason forKey:@"ExceptionReason"];
        [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
        [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
        [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
        
        NSError *error = [[NSError alloc] initWithDomain:MSALErrorDomain code:MSALErrorInternal userInfo:info];
        //use error
        completion(error);
    }
}

#pragma mark - singleton
+ (AuthenticationManager *)sharedInstance
{
    static AuthenticationManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    // Initialize the AuthenticationManager only once.
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AuthenticationManager alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - acquire token
- (void)acquireAuthTokenWithScopes:(NSArray<NSString *> *)scopes
                        completion:(void(^)(MSALErrorCode error))completion
{
    NSError  __autoreleasing  *error_ = nil;
    
    NSArray<MSALUser *> *users = [self.msalClient users:(&error_)];
    
    if (self.msalClient == nil) {
        completion(MSALErrorInternal);
    }
    
    if (users == nil | [users count] == 0) {
        @try {
            [self.msalClient acquireTokenForScopes:scopes completionBlock:^(MSALResult *result, NSError *error) {
                if (error) {
                    completion(error.code);
                } else {
                    self.clientId = self.msalClient.clientId;
                    self.accessToken = result.accessToken;
                    
                    self.user = result.user;
                    self.userID = result.user.displayableId;
                    completion(0);
                    
                }
            }];
        }
        @catch (NSException *exception) {
            completion(MSALErrorInternal);
        }
    } else {
        @try {
            self.user =  [users objectAtIndex:0];
            [self.msalClient acquireTokenSilentForScopes:scopes user:self.user completionBlock:^(MSALResult *result, NSError *error) {
                if (error) {
                    completion(MSALErrorInteractionRequired);
                } else {
                    self.clientId = self.msalClient.clientId;
                    self.accessToken = result.accessToken;
                    self.userID = result.user.displayableId;
                    
                    completion(0);
                }
            }];
        }
        @catch (NSException *exception) {
            completion(MSALErrorInternal);
        }
    }
}

-(void) acquireAuthTokenCompletion:(void (^)(MSALErrorCode *error))completion{
}

#pragma mark - Get client id from bundle

- (NSString *) getRedirectUrlFromMSALArray:(NSArray *) array {
    NSDictionary *arrayElement = [array objectAtIndex: 0];
    NSArray *redirectArray = [arrayElement valueForKeyPath:@"CFBundleURLSchemes"];
    NSString *substring = [redirectArray objectAtIndex:0];
    return substring;
}
@end
