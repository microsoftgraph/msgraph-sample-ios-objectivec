//
//  SpinnerViewController.h
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpinnerViewController : UIViewController
- (void) startWithContainer:(UIViewController*) container;
- (void) stop;
@end

NS_ASSUME_NONNULL_END
