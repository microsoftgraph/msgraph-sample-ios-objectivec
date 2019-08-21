//
//  WelcomeViewController.m
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import "WelcomeViewController.h"
#import "AuthenticationManager.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // TEMPORARY
    self.userProfilePhoto.image = [UIImage imageNamed:@"DefaultUserPhoto"];
    self.userDisplayName.text = @"Default User";
    [self.userDisplayName sizeToFit];
    self.userEmail.text = @"default@contoso.com";
    [self.userEmail sizeToFit];
}

- (IBAction)signOut {
    [AuthenticationManager.instance signOut];
    [self performSegueWithIdentifier: @"userSignedOut" sender: nil];
}

@end
