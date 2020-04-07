//
//  CalendarViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

// <CalendarViewSnippet>
#import "CalendarViewController.h"
#import "SpinnerViewController.h"
#import "GraphManager.h"
#import "CalendarTableViewCell.h"
#import <MSGraphClientModels/MSGraphClientModels.h>

@interface CalendarViewController ()

@property SpinnerViewController* spinner;
@property NSArray<MSGraphEvent*>* events;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;

    self.spinner = [SpinnerViewController alloc];
    [self.spinner startWithContainer:self];

    [GraphManager.instance
     getEventsWithCompletionBlock:^(NSArray<MSGraphEvent*> * _Nullable events, NSError * _Nullable error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.spinner stop];

             if (error) {
                 // Show the error
                 UIAlertController* alert = [UIAlertController
                                             alertControllerWithTitle:@"Error getting events"
                                             message:error.debugDescription
                                             preferredStyle:UIAlertControllerStyleAlert];

                 UIAlertAction* okButton = [UIAlertAction
                                            actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault
                                            handler:nil];

                 [alert addAction:okButton];
                 [self presentViewController:alert animated:true completion:nil];
                 return;
             }

             self.events = events;
             [self.tableView reloadData];
         });
     }];
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

    NSLog(@"Parsing: %@ - %@", dateTime.dateTime, dateTime.timeZone);

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

@end
// </CalendarViewSnippet>
