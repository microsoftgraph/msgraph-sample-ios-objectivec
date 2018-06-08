# Build iOS Objective-C native applications with the Microsoft Graph

In this lab you will create an Android application using the Azure AD v2 authentication endpoint and the Microsoft Authentication Library (MSAL) to access data in Office 365 using the Microsoft Graph REST API.

## In this lab

* [Create an Azure AD native application with the App Registration Portal](#exercise1)
* [Create an iOS native application](#exercise2)
* [Extend the iOS App for Azure AD Authentication](#exercise3)
* [Integrate Microsoft Graph into the Application](#exercise4)

## Prerequisites

To complete this lab, you need the following:

* Office 365 tenancy
  * If you do not have one, you obtain one (for free) by signing up to the [Office 365 Developer Program](https://developer.microsoft.com/en-us/office/dev-program).
* Desktop / laptop running MacOS
* [XCode v9](https://developer.apple.com/xcode/)
* [Carthage v0.29.0](https://github.com/Carthage/Carthage)

<a name="exercise1"></a>

## Exercise 1: Create an Azure AD native application with the App Registration Portal

In this exercise you will create a new Azure AD native application using the App Registry Portal (ARP).

1. Open a browser and navigate to the **App Registry Portal**: **apps.dev.microsoft.com** and login using a **personal account** (aka: Microsoft Account) or **Work or School Account**.
1. Select **Add an app** at the top of the page.
1. On the **Register your application** page, set the **Application Name** to **NativeO365CalendarEvents** and select **Create**.

    ![Screenshot of creating a new app in the App Registration Portal website](./Images/arp-create-app-01.png)

1. On the **NativeO365CalendarEvents Registration** page, under the **Properties** section, copy the **Application Id** Guid as you will need it later.

    ![Screenshot of newly created application's ID](./Images/arp-create-app-02.png)

1. Scroll down to the **Platforms** section.

    1. Select **Add Platform**.
    1. In the **Add Platform** dialog, select **Native Application**.

        ![Screenshot creating a platform for the app](./Images/arp-create-app-03.png)

    1. After the native application platform is created, copy the **Custom Redirect URIs** as you will need it later.

        ![Screenshot of the custom application URI for the native application](./Images/arp-create-app-04.png)

        > Unlike application secrets that are only displayed a single time when they are created, the custom redirect URIs are always shown so you can come back and get this string if you need it later.

1. In the **Microsoft Graph Permissions** section, select **Add** next to the **Delegated Permissions** subsection.

    ![Screenshot of the Add button for adding a delegated permission](./Images/arp-add-permission-01.png)

    In the **Select Permission** dialog, locate and select the permission **Calendars.Read** and select **OK**:

      ![Screenshot of adding the Calendars.Read permission](./Images/arp-add-permission-02.png)

      ![Screenshot of the newly added Calendars.Read permission](./Images/arp-add-permission-03.png)

1. Scroll to the bottom of the page and select **Save**.

<a name="exercise2"></a>

## Exercise 2: Create an iOS native application

In this exercise you will create an iOS application and wire up the different screens.

1. Open XCode.
1. Select **File > New > Project**.
    1. In the **Choose a template for your new project**, select **Page-Based App**.

        ![Screenshot of the "Choose a template for your new project" dialog in XCode](./Images/xcode-createproj-01.png)

    1. Select **Next**.
    1. In the **Choose options for your new project**, enter the following values:
        * **Product Name**: NativeO365CalendarEvents
        * **Organization Name**: Microsoft
        * **Organization Identifier**: com.microsoft.officedev
        * **Language**:
        * Uncheck all additional options

        ![Screenshot of the "Choose options for your new project" dialog in XCode](./Images/xcode-createproj-01.png)

    1. Select **Next**.
1. Cleanup the default storyboard
    1. In the **Navigator** panel, select the following files and delete them:
        * RootViewController.h
        * RootViewController.m
        * DataViewController.h
        * DataViewController.m
        * ModelController.h
        * ModelController.m
    1. In the **Project Manager** panel, select **Main.storyboard**:

        ![Screenshot of XCode Project Manager panel](./Images/xcode-createux-01.png)

    1. Select all the items in the storyboard by selecting any of the elements int he design surface and press <kbd>delete</kbd>.
1. Create the application's UI in the storyboard:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. In the **Utilities** panel, select the **Show Object library**
    1. Select and drag the **Navigation Controller** onto the storyboard design surface:

        ![Screenshot of XCode Storyboard Creation](./Images/xcode-createux-02.png)

    1. Set the Navigation Controller as the initial view for the application:
        1. In the storyboard designer, select the **Navigation Controller**.
        1. In the **Utilities** panel, select the **Attributes Inspector**.
        1. Select the **Is Initial View Controller** option. Notice a faded right arrow is added to the storyboard, pointing to the Navigation Controller:

            ![Screenshot showing setting the initial view for the application](./Images/xcode-createux-03.png)

1. Create the a view controller that will be used by a new view you will create:
    1. Create a login view controller interface:
        1. Select **File > New File**.
        1. Select **Header File** & select **Next**.
        1. Name the file **LoginViewController.h** & select **Create**.
        1. Replace the contents of the file with the following code:

            ```objc
            #import <UIKit/UIKit.h>
            @interface LoginViewController : UIViewController

            @property (weak, nonatomic) IBOutlet UIButton *loginButton;
            @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

            @end
            ```

    1. Create a login view controller class:
        1. Select **File > New File**.
        1. Select **Header File** & select **Next**.
        1. Name the file **LoginViewController**, leave the remaining options as their defaults & select **Next** followed by **Create**.
        1. Replace the contents of the file with the following code:

            ```objc
            #import "LoginViewController.h"

            @interface LoginViewController()
            @end

            @implementation LoginViewController

            - (void)viewDidLoad {
                [super viewDidLoad];
                self.activityIndicator.hidden = YES;
            }

            - (void)showMessage:(NSString*)message withTitle:(NSString *)title {
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:title
                                              message:message
                                              preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action)
                                            {
                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                [self showLoadingUI:NO];
                                            }];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }

            - (void)showLoadingUI:(BOOL)loading {
                if(loading){
                    self.activityIndicator.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.loginButton setTitle:@"Connecting..." forState:UIControlStateNormal];
                    self.loginButton.enabled = NO;
                }
                else{
                    [self.activityIndicator stopAnimating];
                    [self.loginButton setTitle:@"Signin to Microsoft" forState:UIControlStateNormal];
                    self.loginButton.enabled = YES;
                    self.activityIndicator.hidden = YES;
                }
            }

            - (IBAction)loginAction:(id)sender{
                [self showLoadingUI:YES];
                [self showMessage:@"Launch browser based login..." withTitle:@"Signin to Microsoft"];
            }

            @end
            ```

1. Create the initial login screen that will be displayed when the application loads, prompting the user to signin to Office 365:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. In the **Utilities** panel, select the **Show Object library**
    1. Select and drag the **View Controller** onto the storyboard design surface:

        ![Screenshot of adding a View Controller to the storyboard](./Images/xcode-createux-04.png)

    1. Link the Login view to the controller module:
        1. Select the **View Controller Scene > View Controller** in the left-hand panel of the storyboard.
        1. In the **Utilities** panel, select the **Identity** inspector.
        1. Set the **Class** to **LoginViewController**.

            ![Screenshot of setting hte controller for the login view](./Images/xcode-createux-07.png)

    1. Select and drag the **Text Field** onto the storyboard design surface.
        1. In the **Utilities** panel, select the **Attributes** inspector.
        1. Set the **Text** to **Office 365 Calendar Events**.

        ![Screenshot of adding a text field to the login view](./Images/xcode-createux-05.png)

    1. Select and drag the **Button** onto the storyboard design surface.
        1. In the **Utilities** panel, select the **Attributes** inspector.
        1. Set the button's text to **Signin to Microsoft**.
        1. With the button selected in the storyboard, in **Utilities** panel, select the **Connections** inspector.
        1. Select the circle plus icon in the **Referencing Outlets > New Referencing Outlet** option and drag it onto the surface of the login view in the storyboard:

            ![Screenshot of adding a text field to the login view](./Images/xcode-createux-06.png)

        1. In the box that appears, select **loginAction** to wire the button to the object defined in the **LoginViewController.h** interface file.
        1. Select the circle plus icon in the **Sent Events > Touch Up Inside** option, drag it onto the surface of the login view in the storyboard and select **loginAction**.

            ![Screenshot of the signin button's conenctions](./Images/xcode-createux-08.png)

    1. Select and drag the **Activity Indicator View** onto the storyboard design surface.
        1. Select the circle plus icon in the **Referencing Outlets > New Referencing Outlet** option, drag it onto the surface of the login view in the storyboard and select **activityIndicator**.

1. Change the storyboard flow so that the login view is displayed when the application loads:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. Select the **Navigation Controller** in the left-hand part of the storyboard.
    1. Press <kbd>control</kbd> and drag it onto the **Login View Controller** on the storyboard design surface.

        ![Screenshot creating a new segue to the Login View Controller](./Images/xcode-createux-09.png)

    1. In the dialog that appears, select **Relationship Segue > root view controller**.

        ![Screenshot specifying the association between the Navigation Controller and Login View Controller](./Images/xcode-createux-10.png)

    1. The storyboard should now display a different flow of view logic so that:
        * the application will first load from the Navigation Controller
        * the Navigation Controller will then load the Login View Controller
        * the Root View Controller is now orphaned... this will be addressed later in the lab.

        ![Screenshot of the new storyboard flow](./Images/xcode-createux-11.png)

1. Test the user interface:
    1. Select the play button in the toolbar to build & run the application in the iPhone simulator.

        ![Screenshot showing the running application](./Images/xcode-createux-12.png)

    1. When the application loads, select the **Signin to Microsoft** button.

        ![Screenshot showing the running application](./Images/xcode-createux-13.png)

At this point you can stop the application in XCode. The user interface is mostly configured.

<a name="exercise3"></a>

## Exercise 3: Extend the iOS App for Azure AD Authentication

With the application created, now extend it to support authentication with Azure AD. This is required to obtain the necessary OAuth access token to call the Microsoft Graph. In this exercise you will integrate the Microsoft Authentication Library (MSAL) into the application.

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

<a name="exercise4"></a>

## Exercise 4: Integrate Microsoft Graph into the Application

The last exercise is to incorporate the Microsoft Graph into the application. For this application, you will use the Microsoft Graph REST API.

1. Create a new controller for the calendar view:
    1. Select **File > New File**.
        1. Select **Cocoa Touch Class** and select **Next**.
        1. In the **Choose options for your new file** dialog, set the following values, select **Next** and then select **Create**:
            * **Class**: CalendarTableViewController
            * **Subclass of**: UITableViewController
            * **Language**: Objective-C
    1. Open the **CalendarTableViewController.h** file.
        1. Add the following code to the `CalendarTableViewController` interface:

            ```objc
            @property (strong, nonatomic) NSMutableArray* eventsList;
            ```

1. Associate the calendar events view with it's new controller:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. In the storyboard designer, select the **Root View Controller**
        1. In the **Utilities** panel, within the **Identity** inspector, set the **Class** to **CalendarTableViewController**.

            ![Screenshot associating the calendar view to the controller](./Images/xcode-graph-01.png)

        1. In the **Utilities** panel, within the **Identity** inspector:
            * Set the **Identity > Storyboard ID** to **calendarList**.
            * Set the **Document > Label** to **CalendarList**.

    1. In the storyboard designer, select the **CalendarList Scene > CalendarList > Table View > Table View Cell**.
        1. In the **Utilities** panel, within the **Identity** inspector, set the **Document > Label** to **calendarListCell**.
        1. In the **Utilities** panel, within the **Attributes** inspector, set the **Document > Label** to **eventCellTableViewCell**.

1. Implement the user interface for the table cells that will display events.
    1. In the **Utilities** panel, drag two **Label** controls from the **Object** library into the white box for the table view cell.
        * Place the two tables vertically and left-aligned.
        * Stretch the width of the labels to go to the right edge of the screen to avoid wrapping.
    1. In the **Utilities** panel, within the **Attributes** inspector, modify the formatting of the two labels as you would like them to appear

        ![Screenshot associating the calendar view to the controller](./Images/xcode-graph-01.png)

    1. In the **Utilities** panel, within the **Identity** inspector, set the **Document > Label** for the two labels to the following values:
        * subjectLabel
        * dateLabel
    1. In the **Utilities** panel, within the **Attributes** inspector, set the select each of the two labels and set the following properties:
        * subjectLabel
            * **Label > Label**: subjectLabel
            * **View > Tag**: 100
        * dateLabel
            * **Label > Label**: dateLabel
            * **View > Tag**: 200

    1. Open the **CalendarTableViewController.m** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import "AuthenticationManager.h"
        #import <MSAL/MSAL.h>
        ```

1. Implement the calendar view's controller:
    1. Open the **CalendarTableViewController.m** file.
    1. Add the following code to the `viewDidLoad()` method:

        ```objc
        self.eventsList = [[NSMutableArray alloc] init];
        [self getEvents];
        ```

    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        -(void)getEvents
        {
            // authProvider
            AuthenticationManager *authManager = [AuthenticationManager sharedInstance];

            UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(100,100,50,50)];
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [spinner setColor:[UIColor blackColor]];
            [self.view addSubview:spinner];
            spinner.hidesWhenStopped = YES;
            [spinner startAnimating];

            NSString *dataUrl = @"https://graph.microsoft.com/v1.0/me/events?$select=subject,start,end";
            NSURL *url = [NSURL URLWithString:dataUrl];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"GET";

            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];

            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", authManager.accessToken];
            [request setValue:authorization forHTTPHeaderField:@"Authorization"];

            __weak CalendarTableViewController *weakSelf = self;
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        // ...
                                                        CalendarTableViewController *strongSelf = weakSelf;
                                                        NSError *jsonError = nil;

                                                        NSDictionary *jsonFinal = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                        if (jsonError)
                                                        {
                                                            NSLog(@"Error: %@", jsonError);
                                                        }
                                                        self.eventsList = [jsonFinal valueForKey:@"value"];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [spinner stopAnimating];
                                                            [spinner removeFromSuperview];
                                                            [strongSelf.tableView reloadData];
                                                        });
                                                    }];

            [task resume];
        }
        ```

    1. Add the following two utility methods to the `CalendarTableViewController` class:

        ```objc
        - (UIImage *)imageWithColor:(UIColor *)color {
            CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, rect);

            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return image;
        }
        -(NSString *)converStringToDateString:(NSString *)stringDate {
            NSString *result = @"";

            NSDateFormatter *retdateFormat = [[NSDateFormatter alloc] init];
            [retdateFormat setDateFormat:@"yyyy'/'MM'/'dd HH':'mm"];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"];
            NSDate *convertData =[formatter dateFromString:stringDate];

            result = [retdateFormat stringFromDate:convertData];

            return result;
        }

        - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];

            UIButton* actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [actionButton setFrame:CGRectMake(15, 15, 100, 40)];
            [actionButton setBackgroundImage:[self imageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [actionButton setTitle:@"Reload" forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:actionButton];

            NSString *lbl1str = @"The events in the last 30 days.";
            UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 280, 30)];
            lbl1.text = lbl1str;
            lbl1.textAlignment = NSTextAlignmentLeft;
            lbl1.font = [UIFont systemFontOfSize:16];
            lbl1.textColor = [UIColor colorWithRed:136.00f/255.00f green:136.00f/255.00f blue:136.00f/255.00f alpha:1];
            [view addSubview:lbl1];

            return view;
        }
        ```

    1. Locate the method `numberOfSectionsInTableView()` in the `CalendarTableViewController` class. Replace the contents of this method with the following code:

        ```objc
        return 1;
        ```

    1. Locate the method `numberOfRowsInSection()` in the `CalendarTableViewController` class. Replace the contents of this method with the following code:

        ```objc
        return [self.eventsList count];
        ```

    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
        {
            return 100;
        }
        ```

    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
            static NSString *CellIdentifier = @"eventCellTableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            UILabel *subjectLabel = (UILabel *)[cell viewWithTag:100];
            NSDictionary *calendarItem = [self.eventsList objectAtIndex:indexPath.row];
            subjectLabel.text = [calendarItem valueForKey:@"subject"]; // ((MSGraphEvent *)[self.eventsList objectAtIndex:indexPath.row]).subject;;

            NSString *startTime = (NSString *)[[calendarItem valueForKey:@"start"] valueForKey:@"dateTime"];
            NSString *endTime = (NSString *)[[calendarItem valueForKey:@"end"] valueForKey:@"dateTime"];

            NSString *startText = [NSString stringWithFormat:@"Start: %@",[self converStringToDateString:startTime]];
            NSString *endText = [NSString stringWithFormat:@"%@",[self converStringToDateString:endTime]];

            NSString *eventDatetime = startText;
            eventDatetime = [eventDatetime stringByAppendingString:@" - "];
            eventDatetime = [eventDatetime stringByAppendingString:endText];

            UILabel *dateLabel = (UILabel *)[cell viewWithTag:200];
            dateLabel.text = eventDatetime;

            return cell;
        }
        ```

1. Update the login controller so after a successful login, it will programatically load the calendar event view:
    1. In the **Navigator**, select the **LoginViewController.m**
    1. Locate the `loginAction()` method in the `LoginViewController` class.
    1. Add the following lines to the end of the method:

        ```objc
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
        UIViewController *calVC = [board instantiateViewControllerWithIdentifier:@"calendarList"];
        [self.navigationController pushViewController:calVC animated:YES];
        ```

1. Test the user interface:
    1. Select the play button in the toolbar to build & run the application in the iPhone simulator.
    1. When the application loads in the simulator, select **Signin with Microsoft**.
    1. When prompted, signin using your Office 365 account:
    1. After a successful signin, you should see an alert box appear with your name.

        ![Screenshot of the iOS prompting the user to login](./Images/xcode-graph-03.png)
