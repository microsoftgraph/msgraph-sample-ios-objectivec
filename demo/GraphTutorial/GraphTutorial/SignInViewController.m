//
//  SignInViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <SignInViewSnippet>
#import "SignInViewController.h"
#import "SpinnerViewController.h"
#import "AuthenticationManager.h"

@interface SignInViewController ()
@property SpinnerViewController* spinner;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.spinner = [SpinnerViewController alloc];
    [self.spinner startWithContainer:self];

    [AuthenticationManager.instance
     getTokenSilentlyWithCompletionBlock:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.spinner stop];

             if (error || !accessToken) {
                 // If there is no token or if there's an error,
                 // no user is signed in, so stay here
                 return;
             }

             // Since we got a token, user is signed in
             // Go to welcome page
             [self performSegueWithIdentifier: @"userSignedIn" sender: nil];
         });
    }];
}

- (IBAction)signIn {
    [self.spinner startWithContainer:self];

    [AuthenticationManager.instance
     getTokenInteractivelyWithParentView:self
     andCompletionBlock:^(NSString * _Nullable accessToken, NSError * _Nullable error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.spinner stop];

             if (error || !accessToken) {
                 // Show the error and stay on the sign-in page
                 UIAlertController* alert = [UIAlertController
                                             alertControllerWithTitle:@"Error signing in"
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

             // Since we got a token, user is signed in
             // Go to welcome page
             [self performSegueWithIdentifier: @"userSignedIn" sender: nil];
         });
     }];
}
@end
// </SignInViewSnippet>
