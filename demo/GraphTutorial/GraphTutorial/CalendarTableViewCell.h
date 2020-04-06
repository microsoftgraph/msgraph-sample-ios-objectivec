//
//  CalendarTableViewCell.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

// <CalendarTableCellSnippet>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarTableViewCell : UITableViewCell

@property (nonatomic) NSString* subject;
@property (nonatomic) NSString* organizer;
@property (nonatomic) NSString* duration;

@end

NS_ASSUME_NONNULL_END
// </CalendarTableCellSnippet>
