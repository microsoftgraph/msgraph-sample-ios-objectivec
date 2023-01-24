//
//  CalendarTableViewCell.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <CalendarTableCellSnippet>
#import "CalendarTableViewCell.h"

@interface CalendarTableViewCell()

@property (nonatomic) IBOutlet UILabel *subjectLabel;
@property (nonatomic) IBOutlet UILabel *organizerLabel;
@property (nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation CalendarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setSubject:(NSString *)subject {
    _subject = subject;
    self.subjectLabel.text = subject;
    [self.subjectLabel sizeToFit];
}

- (void) setOrganizer:(NSString *)organizer {
    _organizer = organizer;
    self.organizerLabel.text = organizer;
    [self.organizerLabel sizeToFit];
}

- (void) setDuration:(NSString *)duration {
    _duration = duration;
    self.durationLabel.text = duration;
    [self.durationLabel sizeToFit];
}

@end
// </CalendarTableCellSnippet>
