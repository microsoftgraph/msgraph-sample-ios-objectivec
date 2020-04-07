<!-- markdownlint-disable MD002 MD041 -->

In this exercise you will extend the application from the previous exercise to support authentication with Azure AD. This is required to obtain the necessary OAuth access token to call the Microsoft Graph. To do this, you will integrate the [Microsoft Authentication Library (MSAL) for iOS](https://github.com/AzureAD/microsoft-authentication-library-for-objc) into the application.

1. Create a new **Property List** file in the **GraphTutorial** project named **AuthSettings.plist**.
1. Add the following items to the file in the **Root** dictionary.

    | Key | Type | Value |
    |-----|------|-------|
    | `AppId` | String | The application ID from the Azure portal |
    | `GraphScopes` | Array | Two String values: `User.Read` and `Calendars.Read` |

    ![A screenshot of the AuthSettings.plist file in Xcode](./images/auth-settings.png)

> [!IMPORTANT]
> If you're using source control such as git, now would be a good time to exclude the **AuthSettings.plist** file from source control to avoid inadvertently leaking your app ID.

## Implement sign-in

In this section you will configure the project for MSAL, create an authentication manager class, and update the app to sign in and sign out.

### Configure project for MSAL

1. Add a new keychain group to your project's capabilities.
    1. Select the **GraphTutorial** project, then **Signing & Capabilities**.
    1. Select **+ Capability**, then double-click **Keychain Sharing**.
    1. Add a keychain group with the value `com.microsoft.adalcache`.

1. Control click **Info.plist** and select **Open As**, then **Source Code**.
1. Add the following inside the `<dict>` element.

    ```xml
    <key>CFBundleURLTypes</key>
    <array>
      <dict>
        <key>CFBundleURLSchemes</key>
        <array>
          <string>msauth.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
      </dict>
    </array>
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>msauthv2</string>
        <string>msauthv3</string>
    </array>
    ```

1. Open **AppDelegate.m** and add the following import statement at the top of the file.

    ```objc
    #import <MSAL/MSAL.h>
    ```

1. Add the following function to the `AppDelegate` class.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/AppDelegate.m" id="HandleMsalResponseSnippet":::

### Create authentication manager

1. Create a new **Cocoa Touch Class** in the **GraphTutorial** project named **AuthenticationManager**. Choose **NSObject** in the **Subclass of** field.
1. Open **AuthenticationManager.h** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/AuthenticationManager.h" id="AuthManagerSnippet":::

1. Open **AuthenticationManager.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/AuthenticationManager.m" id="AuthManagerSnippet":::

### Add sign-in and sign-out

1. Open the **SignInViewController.m** file and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/SignInViewController.m" id="SignInViewSnippet":::

1. Open **WelcomeViewController.m** and add the following `import` statement to the top of the file.

    ```objc
    #import "AuthenticationManager.h"
    ```

1. Replace the existing `signOut` function with the following.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/WelcomeViewController.m" id="SignOutSnippet":::

1. Save your changes and restart the application in Simulator.

If you sign in to the app, you should see an access token displayed in the output window in Xcode.

![A screenshot of the output window in Xcode showing an access token](./images/access-token-output.png)

## Get user details

In this section you will create a helper class to hold all of the calls to Microsoft Graph and update the `WelcomeViewController` to use this new class to get the logged-in user.

1. Create a new **Cocoa Touch Class** in the **GraphTutorial** project named **GraphManager**. Choose **NSObject** in the **Subclass of** field.
1. Open **GraphManager.h** and replace its contents with the following code.

    ```objc
    #import <Foundation/Foundation.h>
    #import <MSGraphClientSDK/MSGraphClientSDK.h>
    #import <MSGraphClientModels/MSGraphClientModels.h>
    #import <MSGraphClientModels/MSCollection.h>
    #import "AuthenticationManager.h"

    NS_ASSUME_NONNULL_BEGIN

    typedef void (^GetMeCompletionBlock)(MSGraphUser* _Nullable user, NSError* _Nullable error);

    @interface GraphManager : NSObject

    + (id) instance;
    - (void) getMeWithCompletionBlock: (GetMeCompletionBlock)completionBlock;

    @end

    NS_ASSUME_NONNULL_END
    ```

1. Open **GraphManager.m** and replace its contents with the following code.

    ```objc
    #import "GraphManager.h"

    @interface GraphManager()

    @property MSHTTPClient* graphClient;

    @end

    @implementation GraphManager

    + (id) instance {
        static GraphManager *singleInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^ {
            singleInstance = [[self alloc] init];
        });

        return singleInstance;
    }

    - (id) init {
        if (self = [super init]) {
            // Create the Graph client
            self.graphClient = [MSClientFactory
                                createHTTPClientWithAuthenticationProvider:AuthenticationManager.instance];
        }

        return self;
    }

    - (void) getMeWithCompletionBlock:(GetMeCompletionBlock)completionBlock {
        // GET /me
        NSString* meUrlString = [NSString stringWithFormat:@"%@/me", MSGraphBaseURL];
        NSURL* meUrl = [[NSURL alloc] initWithString:meUrlString];
        NSMutableURLRequest* meRequest = [[NSMutableURLRequest alloc] initWithURL:meUrl];

        MSURLSessionDataTask* meDataTask =
        [[MSURLSessionDataTask alloc]
            initWithRequest:meRequest
            client:self.graphClient
            completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    completionBlock(nil, error);
                    return;
                }

                // Deserialize the response as a user
                NSError* graphError;
                MSGraphUser* user = [[MSGraphUser alloc] initWithData:data error:&graphError];

                if (graphError) {
                    completionBlock(nil, graphError);
                } else {
                    completionBlock(user, nil);
                }
            }];

        // Execute the request
        [meDataTask execute];
    }

    @end
    ```

1. Open **WelcomeViewController.m** and add the following `#import` statements at the top of the file.

    ```objc
    #import "SpinnerViewController.h"
    #import "GraphManager.h"
    #import <MSGraphClientModels/MSGraphClientModels.h>
    ```

1. Add the following property to the `WelcomeViewController` interface declaration.

    ```objc
    @property SpinnerViewController* spinner;
    ```

1. Replace the existing `viewDidLoad` with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/WelcomeViewController.m" id="ViewDidLoadSnippet":::

If you save your changes and restart the app now, after sign-in the UI is updated with the user's display name and email address.
