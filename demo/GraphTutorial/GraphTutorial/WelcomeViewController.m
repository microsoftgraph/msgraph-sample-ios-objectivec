//
//  WelcomeViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import "WelcomeViewController.h"
#import "AuthenticationManager.h"
#import "SpinnerViewController.h"
#import "GraphManager.h"
#import <MSGraphClientModels/MSGraphClientModels.h>

@interface WelcomeViewController ()

@property SpinnerViewController* spinner;

@end

@implementation WelcomeViewController

// <ViewDidLoadSnippet>
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.spinner = [SpinnerViewController alloc];
    [self.spinner startWithContainer:self];

    self.userProfilePhoto.image = [UIImage imageNamed:@"DefaultUserPhoto"];

    [GraphManager.instance
     getMeWithCompletionBlock:^(MSGraphUser * _Nullable user, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stop];

            if (error) {
                // Show the error
                UIAlertController* alert = [UIAlertController
                                            alertControllerWithTitle:@"Error getting user profile"
                                            message:error.debugDescription
                                            preferredStyle:UIAlertControllerStyleAlert];

                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:nil];

                [alert addAction:okButton];
                [self presentViewController:alert animated:true completion:nil];
                return;
            }

            // Set display name
            self.userDisplayName.text = user.displayName ? : @"Mysterious Stranger";
            [self.userDisplayName sizeToFit];

            // AAD users have email in the mail attribute
            // Personal accounts have email in the userPrincipalName attribute
            self.userEmail.text = user.mail ? : user.userPrincipalName;
            [self.userEmail sizeToFit];
            
            // Save user time zone
            [GraphManager.instance setGraphTimeZone:(user.mailboxSettings.timeZone ? : @"UTC")];
        });
    }];
}
// </ViewDidLoadSnippet>

// <SignOutSnippet>
- (IBAction)signOut {
    [AuthenticationManager.instance signOut];
    [self performSegueWithIdentifier: @"userSignedOut" sender: nil];
}
// </SignOutSnippet>

@end
