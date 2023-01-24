//
//  CalendarTableViewController.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <CalendarTableViewControllerSnippet>
#import <UIKit/UIKit.h>
#import <MSGraphClientModels/MSGraphClientModels.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarTableViewController : UITableViewController

@property (nonatomic) NSArray<MSGraphEvent*>* events;

@end

NS_ASSUME_NONNULL_END
// </CalendarTableViewControllerSnippet>
