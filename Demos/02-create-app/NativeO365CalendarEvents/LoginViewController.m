//
//  LoginViewController.m
//  NativeO365CalendarEvents
//
//  Created by Andrew Connell on 11/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
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
    
    self.loginButton.enabled = NO;
    self.logoutButton.enabled = YES;
}

- (IBAction)logoutAction:(id)sender{
    [self showLoadingUI:YES];
    [self showMessage:@"Signing out of Microsoft..." withTitle:@"Signout from Microsoft"];
    
    self.loginButton.enabled = YES;
    self.logoutButton.enabled = NO;
}

@end
