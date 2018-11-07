//
//  LoginViewController.h
//  NativeO365CalendarEvents
//
//  Created by Andrew Connell on 11/7/18.
//  Copyright © 2018 Microsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

NS_ASSUME_NONNULL_END
