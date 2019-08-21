//
//  SignInViewController.m
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import "SignInViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)signIn {
    [self performSegueWithIdentifier: @"userSignedIn" sender: nil];
}
@end
