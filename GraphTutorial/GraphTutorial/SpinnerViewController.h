//
//  SpinnerViewController.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpinnerViewController : UIViewController

- (void) startWithContainer:(UIViewController*) container;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
