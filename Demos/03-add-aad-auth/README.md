# Extend the iOS App for Azure AD Authentication

With the application created, now extend it to support authentication with Azure AD. This is required to obtain the necessary OAuth access token to call the Microsoft Graph. In this demo you will integrate the Microsoft Authentication Library (MSAL) into the application.

Alternatively, you can open the final solution from this demo located in this folder. Refer to the prerequisites for what you need to run the demo.

> To run the solution in this demo without recreating the solution, do the following:
> * from the project root run the command `carthage update` to download * build the MSAL library
> * Open the `Info.plist` file and replace the `ENTER_YOUR_CLIENT_ID` in the last setting with your Azure AD application ID

## Prerequisites

To complete this lab, you need the following:

* Office 365 tenancy
  * If you do not have one, you obtain one (for free) by signing up to the [Office 365 Developer Program](https://developer.microsoft.com/en-us/office/dev-program).
* Azure AD application registered using the [App Registration portal](https://apps.dev.microsoft.com) with a native platform configured.
* Desktop / laptop running MacOS
* [XCode v9](https://developer.apple.com/xcode/)
* [Carthage v0.29.0](https://github.com/Carthage/Carthage)

## Demo steps

1. Use the package manager Carthage to add the MSAL for iOS library to the application:
    1. In XCode, select **File > New File**
    1. Select **Empty File** and select **Next**.
    1. Name the file **Carthage** and select **Create**. Make sure to save the file in the same folder as the **NativeO365CalendarEvents.xcodeproj** file.
    1. Add the following to the **Carthage** file:

        ```txt
        github "AzureAD/microsoft-authentication-library-for-objc" "master"
        ```

    1. Launch a Terminal and change to the folder where the project is located.
    1. Execute the following commend in the Terminal to download and build the MSAL library:

        ```shell
        carthage update
        ```

    1. Add the MSAL library to the project's linked frameworks:
        1. In the **Navigator**, select the project.
        1. In the **General** section of the project's properties, select the plus control in the **Linked Frameworks and Libraries** section.

            ![Screenshot of the project's Linked Frameworks and Libraries](./Images/xcode-auth-01.png)

        1. In the **Choose frameworks and libraries to add**, select **Add Other**.
        1. Select the **MSAL.Framework** folder from **./Carthage/Build/iOS** folder.

            ![Screenshot of the project's Linked Frameworks and Libraries](./Images/xcode-auth-02.png)

    1. In the **Build Phases** section of the project's properties, select the **TARGETS > NativeO365CalendarEvents**.
        1. Select the plus icon in the top-left corner and select **New Run Script Phase**.

            ![Screenshot of creating a new build script phase](./Images/xcode-auth-03.png)

        1. Set the shell script to run:

            ```bash
            usr/local/bin/carthage copy-frameworks
            ```

        1. Set the following **Input Files**:

            ```bash
            $(SRCROOT)/Carthage/Build/iOS/MSAL.framework
            ```

            ![Screenshot adding the run script details](./Images/xcode-auth-04.png)

1. Update the application's configuration to include the Azure AD application's ID:
    1. In the **Navigator**, right-click the **Info.plist** file and select **Open As > Source Code**.
    1. Add the following XML immediately before the closing `</dict>` element:

        ```xml
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleTypeRole</key>
                <string>Editor</string>
                <key>CFBundleURLName</key>
                <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>msalENTER_YOUR_CLIENT_ID</string>
                    <string>auth</string>
                </array>
            </dict>
        </array>
        ```

    1. In the previous XML, replace the `ENTER_YOUR_CLIENT_ID` with the Azure AD application's ID you copied from a previous step.

1. Update the application to handle a response from the MSAL library:
    1. In the **Navigator**, select the **AppDelegate.m** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import <MSAL/msal.h>
        ```

    1. Add the following method to the end of the file, before the closing `@end` statement.

        ```objc
        - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
        {
          [MSALPublicClientApplication handleMSALResponse:url];
          return YES;
        }
        ```

1. Create a new authentication manager class:
    1. Select **File > New File**.
        1. Select **Cocoa Touch Class** and select **Next**.
        1. In the **Choose options for your new file** dialog, set the following values, select **Next** and then select **Create**:
            * **Class**: AuthenticationManager
            * **Subclass of**: NSObject
            * **Language**: Objective-C

1. Code the `AuthenticationManager` interface:
    1. Open the **AuthenticationManager.h** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import <MSAL/msal.h>
        ```

    1. Add the following code to the body of the **AuthenticationManager** interface:

        ```objc
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
        ```

1. Code the implementation of the `AuthenticationManager` class:
    1. Open the **AuthenticationManager.m** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import <MSAL/MSAL.h>
        ```

    1. Add the following code to the `AuthenticationManager` to create an implement the class constructor:

        ```objc
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
        ```

    1. Add the following code to the `AuthenticationManager` class to implement a single static instance of the class:

        ```objc
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
        ```

    1. Add the following code to the `AuthenticationManager` class to implement the `acquireAuthTOkenWithScopes()` method:

        ```objc
        #pragma mark - acquire token
        - (void)acquireAuthTokenWithScopes:(NSArray<NSString *> *)scopes
                                completion:(void(^)(MSALErrorCode error))completion {

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
        ```

    1. Add the following code to the `AuthenticationManager` class to implement the `acquireAuthTokenCompletion()` method:

        ```objc
        -(void) acquireAuthTokenCompletion:(void (^)(MSALErrorCode *error))completion{
        }

        #pragma mark - Get client id from bundle

        - (NSString *) getRedirectUrlFromMSALArray:(NSArray *) array {
            NSDictionary *arrayElement = [array objectAtIndex: 0];
            NSArray *redirectArray = [arrayElement valueForKeyPath:@"CFBundleURLSchemes"];
            NSString *substring = [redirectArray objectAtIndex:0];
            return substring;
        }
        ```

1. Update the login controller to wire up the authentication manager:
    1. Open the **LoginViewController.m** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import "AuthenticationManager.h"
        #import <MSAL/MSALUser.h>
        ```

    1. Add the following code after the `import` statements to declare a constant string for the root part of the Auzre AD OAuth v2 endpoints:

        ```objc
        NSString * const kAuthority   = @"https://login.microsoftonline.com/common/v2.0";
        ```

    1. Add the following code to the existing `LoginViewController` interface:

        ```objc
        @property (weak, nonatomic) NSArray *scopes;
        ```

    1. Replace the contents of the `loginAction()` method with the following code to the existing `LoginViewController` class:

      ```object
      - (IBAction)loginAction:(id)sender{
          [self showLoadingUI:YES];

          self.scopes = [NSArray arrayWithObjects:@"https://graph.microsoft.com/User.Read", @"https://graph.microsoft.com/Calendars.Read", nil];

          AuthenticationManager *authenticationManager = [AuthenticationManager sharedInstance];
          [authenticationManager initWithAuthority:kAuthority completion:^(NSError *error) {
              if (error) {
                  [self showLoadingUI:NO];
                  [self showMessage:@"Please see the log for more details" withTitle:@"InitWithAuthority Error"];
              } else {
                  [authenticationManager acquireAuthTokenWithScopes:self.scopes completion:^(MSALErrorCode error) {
                      if(error){
                          [self showLoadingUI:NO];
                          [self showMessage:@"Please see the log for more details" withTitle:@"AcquireAuthToken Error"];
                      } else {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              MSALUser *currentUser = [authenticationManager user];

                              NSString *successMessage = @"Authentication succeeded for: ";
                              successMessage = [successMessage stringByAppendingString:[currentUser name]];
                              successMessage = [successMessage stringByAppendingString:@" ("];
                              successMessage = [successMessage stringByAppendingString:[currentUser displayableId]];
                              successMessage = [successMessage stringByAppendingString:@")"];

                              [self showMessage:successMessage withTitle:@"Success"];
                          });
                      }
                  }];
              }
          }];
      }
      ```

1. Test the user interface:
    1. Select the play button in the toolbar to build & run the application in the iPhone simulator.
    1. When the application loads in the simulator, select **Signin with Microsoft**.
    1. When prompted, signin using your Office 365 account:

        ![Screenshot of the iOS prompting the user to login](./Images/xcode-auth-05.png)

    1. After a successful signin, you should see an alert box appear with your name.

        ![Screenshot of the iOS displaying the signed in user](./Images/xcode-auth-06.png)
