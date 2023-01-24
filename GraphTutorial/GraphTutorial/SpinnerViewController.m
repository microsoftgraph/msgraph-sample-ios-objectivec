//
//  SpinnerViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <SpinnerViewSnippet>
#import "SpinnerViewController.h"

@interface SpinnerViewController ()
@property (nonatomic) UIActivityIndicatorView* spinner;
@end

@implementation SpinnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                UIActivityIndicatorViewStyleLarge];

    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:_spinner];

    _spinner.translatesAutoresizingMaskIntoConstraints = false;
    [_spinner startAnimating];

    [_spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = true;
    [_spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = true;
}

- (void) startWithContainer:(UIViewController *)container {
    [container addChildViewController:self];
    self.view.frame = container.view.frame;
    [container.view addSubview:self.view];
    [self didMoveToParentViewController:container];
}

- (void) stop {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
// </SpinnerViewSnippet>
