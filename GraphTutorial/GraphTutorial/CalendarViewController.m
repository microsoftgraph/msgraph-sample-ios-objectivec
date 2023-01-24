//
//  CalendarViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <CalendarViewControllerSnippet>
#import "CalendarViewController.h"
#import "CalendarTableViewController.h"
#import "SpinnerViewController.h"
#import "GraphManager.h"
#import "GraphToIana.h"
#import <MSGraphClientModels/MSGraphClientModels.h>

@interface CalendarViewController ()

@property SpinnerViewController* spinner;
@property CalendarTableViewController* tableView;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.spinner = [SpinnerViewController alloc];
    [self.spinner startWithContainer:self];
    
    // Calculate the start and end of the current week
    NSString* timeZoneId = [GraphToIana
                            getIanaIdentifierFromGraphIdentifier:
                            [GraphManager.instance graphTimeZone]];

    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:timeZoneId];
    [calendar setTimeZone:timeZone];
    
    NSDateComponents* startOfWeekComponents = [calendar
                                               components:NSCalendarUnitCalendar |
                                               NSCalendarUnitYearForWeekOfYear |
                                               NSCalendarUnitWeekOfYear
                                               fromDate:now];
    NSDate* startOfWeek = [startOfWeekComponents date];
    NSDate* endOfWeek = [calendar dateByAddingUnit:NSCalendarUnitDay
                                             value:7
                                            toDate:startOfWeek
                                           options:0];

    // Convert start and end to ISO 8601 strings
    NSISO8601DateFormatter* isoFormatter = [[NSISO8601DateFormatter alloc] init];
    NSString* viewStart = [isoFormatter stringFromDate:startOfWeek];
    NSString* viewEnd = [isoFormatter stringFromDate:endOfWeek];

    [GraphManager.instance
     getCalendarViewStartingAt:viewStart
     endingAt:viewEnd
     withCompletionBlock:^(NSArray<MSGraphEvent*>* _Nullable events, NSError * _Nullable error) {
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

             [self.tableView setEvents:events];
         });
     }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Save a reference to the contained table view so
    // we can pass the results of the Graph call to it
    if ([segue.destinationViewController isKindOfClass:[CalendarTableViewController class]]) {
        self.tableView = segue.destinationViewController;
    }
}

- (IBAction) showNewEventForm {
    [self performSegueWithIdentifier:@"showEventForm" sender:nil];
}

@end
// </CalendarViewControllerSnippet>
