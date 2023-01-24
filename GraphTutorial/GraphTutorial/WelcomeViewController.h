//
//  WelcomeViewController.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WelcomeViewController : UIViewController

@property (nonatomic) IBOutlet UIImageView *userProfilePhoto;
@property (nonatomic) IBOutlet UILabel *userDisplayName;
@property (nonatomic) IBOutlet UILabel *userEmail;

@end

NS_ASSUME_NONNULL_END
