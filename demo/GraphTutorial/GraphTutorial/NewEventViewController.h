//
//  NewEventViewController.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewEventViewController : UIViewController

@property (nonatomic) IBOutlet UITextField* subject;
@property (nonatomic) IBOutlet UITextField* attendees;
@property (nonatomic) IBOutlet UIDatePicker* start;
@property (nonatomic) IBOutlet UIDatePicker* end;
@property (nonatomic) IBOutlet UITextView* body;

@end

NS_ASSUME_NONNULL_END
