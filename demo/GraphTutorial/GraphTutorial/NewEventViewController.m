//
//  NewEventViewController.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

// <NewEventViewControllerSnippet>
#import "NewEventViewController.h"
#import "SpinnerViewController.h"
#import "GraphManager.h"

@interface NewEventViewController ()

@property SpinnerViewController* spinner;

@end

@implementation NewEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spinner = [SpinnerViewController alloc];
    
    // Add border around text view
    UIColor* borderColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    self.body.layer.borderWidth = 0.5;
    self.body.layer.borderColor = [borderColor CGColor];
    self.body.layer.cornerRadius = 5.0;

    // Set start picker to the next closest half-hour
    NSDate* now = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSInteger minutes = [calendar component:NSCalendarUnitMinute fromDate:now];
    NSInteger offset = 30 - (minutes % 30);

    NSDate* start = [calendar dateByAddingUnit:NSCalendarUnitMinute
                                         value:offset
                                        toDate:now
                                       options:kNilOptions];
    self.start.date = start;

    // Set end picker to start + 30 min
    NSDate* end = [calendar dateByAddingUnit:NSCalendarUnitMinute
                                       value:30
                                      toDate:start
                                     options:kNilOptions];
    self.end.date = end;
}

- (IBAction) createEvent {
    [self.spinner startWithContainer:self];
    
    NSString* subject = self.subject.text;
    
    NSString* attendeeString = self.attendees.text;
    NSArray* attendees = nil;
    if (attendeeString != nil && attendeeString.length > 0) {
        attendees = [attendeeString componentsSeparatedByString:@";"];
    }

    NSDate* start = self.start.date;
    NSDate* end = self.end.date;

    NSString* body = self.body.text;
    
    [GraphManager.instance createEventWithSubject:subject
                                         andStart:start
                                           andEnd:end
                                     andAttendees:attendees
                                          andBody:body
                               andCompletionBlock:^(MSGraphEvent * _Nullable event,
                                                    NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stop];

            NSString* alertTitle = nil;
            NSString* alertMessage = nil;
            
            UIAlertAction* okButton = nil;
            
            if (error) {
                // Show the error
                alertTitle = @"Error creating event";
                alertMessage = error.debugDescription;
                okButton = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:nil];
            } else {
                alertTitle = @"Success";
                alertMessage = @"Event created";
                okButton = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                    [self dismissViewControllerAnimated:true completion:nil];
                }];
            }

            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:alertTitle
                                        message:alertMessage
                                        preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:okButton];
            [self presentViewController:alert animated:true completion:nil];
        });
    }];
}

- (IBAction) cancel {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
// </NewEventViewControllerSnippet>
