//
//  CalendarTableViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <CalendarTableViewControllerSnippet>
#import "CalendarTableViewController.h"
#import "CalendarTableViewCell.h"
#import <MSGraphClientModels/MSGraphClientModels.h>

@interface CalendarTableViewController ()

@end

@implementation CalendarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}

- (NSInteger) numberOfSections:(UITableView*) tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section {
    return self.events ? self.events.count : 0;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalendarTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell"];

    // Get the event that corresponds to the row
    MSGraphEvent* event = self.events[indexPath.row];

    // Configure the cell
    cell.subject = event.subject;
    cell.organizer = event.organizer.emailAddress.name;
    cell.duration = [NSString stringWithFormat:@"%@ to %@",
                     [self formatGraphDateTime:event.start],
                     [self formatGraphDateTime:event.end]];

    return cell;
}

- (NSString*) formatGraphDateTime:(MSGraphDateTimeTimeZone*) dateTime {
    // Create a formatter to parse Graph's date format
    NSDateFormatter* isoFormatter = [[NSDateFormatter alloc] init];
    isoFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS";

    // Specify the time zone
    isoFormatter.timeZone = [[NSTimeZone alloc] initWithName:dateTime.timeZone];

    NSDate* date = [isoFormatter dateFromString:dateTime.dateTime];

    // Output like 5/5/2019, 2:00 PM
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;

    NSString* dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void) setEvents:(NSArray<MSGraphEvent *> *)events {
    _events = events;
    [self.tableView reloadData];
}

@end
// </CalendarTableViewControllerSnippet>
