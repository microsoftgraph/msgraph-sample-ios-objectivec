//
//  CalendarTableViewCell.h
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarTableViewCell : UITableViewCell

@property (nonatomic) NSString* subject;
@property (nonatomic) NSString* organizer;
@property (nonatomic) NSString* duration;

@end

NS_ASSUME_NONNULL_END
