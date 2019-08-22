//
//  CalendarViewController.m
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import "CalendarViewController.h"
#import "SpinnerViewController.h"
#import "GraphManager.h"
#import <MSGraphClientModels/MSGraphClientModels.h>

@interface CalendarViewController ()

@property SpinnerViewController* spinner;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.spinner = [SpinnerViewController alloc];
    [self.spinner startWithContainer:self];
    
    [GraphManager.instance
     getEventsWithCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
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
             
             // TEMPORARY
             self.calendarJSON.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             [self.calendarJSON sizeToFit];
         });
     }];
}

@end
