# Create an iOS native application

In this demo you will create an iOS application and wire up the different screens.

Alternatively, you can open the final solution from this demo located in this folder. Refer to the prerequisites for what you need to run the demo.

## Prerequisites

To complete this lab, you need the following:

* Desktop / laptop running MacOS
* [XCode v9](https://developer.apple.com/xcode/)

## Demo steps

1. Open XCode.
1. Select **File > New > Project**.
    1. In the **Choose a template for your new project**, select **Page-Based App**.

        ![Screenshot of the "Choose a template for your new project" dialog in XCode](../../Images/xcode-createproj-01.png)

    1. Select **Next**.
    1. In the **Choose options for your new project**, enter the following values:
        * **Product Name**: NativeO365CalendarEvents
        * **Organization Name**: Microsoft
        * **Organization Identifier**: com.microsoft.officedev
        * **Language**:
        * Uncheck all additional options

        ![Screenshot of the "Choose options for your new project" dialog in XCode](../../Images/xcode-createproj-01.png)

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

        ![Screenshot of XCode Project Manager panel](../../Images/xcode-createux-01.png)

    1. Select all the items in the storyboard by selecting any of the elements int he design surface and press <kbd>delete</kbd>.
1. Create the application's UI in the storyboard:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. In the **Utilities** panel, select the **Show Object library**
    1. Select and drag the **Navigation Controller** onto the storyboard design surface:

        ![Screenshot of XCode Storyboard Creation](../../Images/xcode-createux-02.png)

    1. Set the Navigation Controller as the initial view for the application:
        1. In the storyboard designer, select the **Navigation Controller**.
        1. In the **Utilities** panel, select the **Attributes Inspector**.
        1. Select the **Is Initial View Controller** option. Notice a faded right arrow is added to the storyboard, pointing to the Navigation Controller:

            ![Screenshot showing setting the initial view for the application](../../Images/xcode-createux-03.png)

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

        ![Screenshot of adding a View Controller to the storyboard](../../Images/xcode-createux-04.png)

    1. Link the Login view to the controller module:
        1. Select the **View Controller Scene > View Controller** in the left-hand panel of the storyboard.
        1. In the **Utilities** panel, select the **Identity** inspector.
        1. Set the **Class** to **LoginViewController**.

            ![Screenshot of setting hte controller for the login view](../../Images/xcode-createux-07.png)

    1. Select and drag the **Text Field** onto the storyboard design surface.
        1. In the **Utilities** panel, select the **Attributes** inspector.
        1. Set the **Text** to **Office 365 Calendar Events**.

        ![Screenshot of adding a text field to the login view](../../Images/xcode-createux-05.png)

    1. Select and drag the **Button** onto the storyboard design surface.
        1. In the **Utilities** panel, select the **Attributes** inspector.
        1. Set the button's text to **Signin to Microsoft**.
        1. With the button selected in the storyboard, in **Utilities** panel, select the **Connections** inspector.
        1. Select the circle plus icon in the **Referencing Outlets > New Referencing Outlet** option and drag it onto the surface of the login view in the storyboard:

            ![Screenshot of adding a text field to the login view](../../Images/xcode-createux-06.png)

        1. In the box that appears, select **loginAction** to wire the button to the object defined in the **LoginViewController.h** interface file.
        1. Select the circle plus icon in the **Sent Events > Touch Up Inside** option, drag it onto the surface of the login view in the storyboard and select **loginAction**.

            ![Screenshot of the signin button's conenctions](../../Images/xcode-createux-08.png)

    1. Select and drag the **Activity Indicator View** onto the storyboard design surface.
        1. Select the circle plus icon in the **Referencing Outlets > New Referencing Outlet** option, drag it onto the surface of the login view in the storyboard and select **activityIndicator**.

1. Change the storyboard flow so that the login view is displayed when the application loads:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. Select the **Navigation Controller** in the left-hand part of the storyboard.
    1. Press <kbd>control</kbd> and drag it onto the **Login View Controller** on the storyboard design surface.

        ![Screenshot creating a new segue to the Login View Controller](../../Images/xcode-createux-09.png)

    1. In the dialog that appears, select **Relationship Segue > root view controller**.

        ![Screenshot specifying the association between the Navigation Controller and Login View Controller](../../Images/xcode-createux-10.png)

    1. The storyboard should now display a different flow of view logic so that:
        * the application will first load from the Navigation Controller
        * the Navigation Controller will then load the Login View Controller
        * the Root View Controller is now orphaned... this will be addressed later in the lab.

        ![Screenshot of the new storyboard flow](../../Images/xcode-createux-11.png)

1. Test the user interface:
    1. Select the play button in the toolbar to build & run the application in the iPhone simulator.

        ![Screenshot showing the running application](../../Images/xcode-createux-12.png)

    1. When the application loads, select the **Signin to Microsoft** button.

        ![Screenshot showing the running application](../../Images/xcode-createux-13.png)

At this point you can stop the application in XCode. The user interface is mostly configured.
