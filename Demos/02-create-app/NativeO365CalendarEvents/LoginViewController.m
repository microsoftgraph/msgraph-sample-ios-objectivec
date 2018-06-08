#import "LoginViewController.h"

@interface LoginViewController()
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
}

- (void)showMessage:(NSString*)message withTitle:(NSString *)title {
    UIAlertController * alert= [UIAlertController
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
        [self.loginButton setTitle:@"Signin to Office 365" forState:UIControlStateNormal];
        self.loginButton.enabled = YES;
        self.activityIndicator.hidden = YES;
    }
}

- (IBAction)loginAction:(id)sender{
    [self showLoadingUI:YES];
    [self showMessage:@"Launch browser based login..." withTitle:@"Signin to Office 365"];
}

@end
