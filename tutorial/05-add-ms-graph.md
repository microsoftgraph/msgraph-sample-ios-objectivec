<!-- markdownlint-disable MD002 MD041 -->

In this exercise you will incorporate the Microsoft Graph into the application. For this application, you will use the [Microsoft Graph SDK for Objective C](https://github.com/microsoftgraph/msgraph-sdk-objc) to make calls to Microsoft Graph.

## Get calendar events from Outlook

In this section you will extend the `GraphManager` class to add a function to get the user's events and update `CalendarViewController` to use these new functions.

1. Open **GraphManager.h** and add the following code above the `@interface` declaration.

    ```objc
    typedef void (^GetEventsCompletionBlock)(NSData* _Nullable data, NSError* _Nullable error);
    ```

1. Add the following code to the `@interface` declaration.

    ```objc
    - (void) getEventsWithCompletionBlock: (GetEventsCompletionBlock)completionBlock;
    ```

1. Open **GraphManager.m** and add the following function to the `GraphManager` class.

    ```objc
    - (void) getEventsWithCompletionBlock:(GetEventsCompletionBlock)completionBlock {
        // GET /me/events?$select='subject,organizer,start,end'$orderby=createdDateTime DESC
        NSString* eventsUrlString =
        [NSString stringWithFormat:@"%@/me/events?%@&%@",
         MSGraphBaseURL,
         // Only return these fields in results
         @"$select=subject,organizer,start,end",
         // Sort results by when they were created, newest first
         @"$orderby=createdDateTime+DESC"];

        NSURL* eventsUrl = [[NSURL alloc] initWithString:eventsUrlString];
        NSMutableURLRequest* eventsRequest = [[NSMutableURLRequest alloc] initWithURL:eventsUrl];

        MSURLSessionDataTask* eventsDataTask =
        [[MSURLSessionDataTask alloc]
         initWithRequest:eventsRequest
         client:self.graphClient
         completion:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (error) {
                 completionBlock(nil, error);
                 return;
             }

             // TEMPORARY
             completionBlock(data, nil);
         }];

        // Execute the request
        [eventsDataTask execute];
    }
    ```

    > [!NOTE]
    > Consider what the code in `getEventsWithCompletionBlock` is doing.
    >
    > - The URL that will be called is `/v1.0/me/events`.
    > - The `select` query parameter limits the fields returned for each events to just those the app will actually use.
    > - The `orderby` query parameter sorts the results by the date and time they were created, with the most recent item being first.

1. Open **CalendarViewController.m** and replace its entire contents with the following code.

    ```objc
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
    ```

1. Run the app, sign in, and tap the **Calendar** navigation item in the menu. You should see a JSON dump of the events in the app.

## Display the results

Now you can replace the JSON dump with something to display the results in a user-friendly manner. In this section, you will modify the `getEventsWithCompletionBlock` function to return strongly-typed objects, and modify `CalendarViewController` to use a table view to render the events.

### Update getEvents

1. Open **GraphManager.h**. Change the `GetEventsCompletionBlock` type definition to the following.

    ```objc
    typedef void (^GetEventsCompletionBlock)(NSArray<MSGraphEvent*>* _Nullable events, NSError* _Nullable error);
    ```

1. Open **GraphManager.m**. Replace the `completionBlock(data, nil);` line in the `getEventsWithCompletionBlock` function with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/GraphManager.m" id="GetEventsSnippet" highlight="24-43":::

### Update CalendarViewController

1. Create a new **Cocoa Touch Class** file in the **GraphTutorial** project named `CalendarTableViewCell`. Choose **UITableViewCell** in the **Subclass of** field.
1. Open **CalendarTableViewCell.h** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewCell.h" id="CalendarTableCellSnippet":::

1. Open **CalendarTableViewCell.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewCell.m" id="CalendarTableCellSnippet":::

1. Open **Main.storyboard** and locate the **Calendar Scene**. Select the **View** in the **Calendar Scene** and delete it.

    ![A screenshot of the View in the Calendar Scene](./images/view-in-calendar-scene.png)

1. Add a **Table View** from the **Library** to the **Calendar Scene**.
1. Select the table view, then select the **Attributes Inspector**. Set **Prototype Cells** to **1**.
1. Use the **Library** to add three **Labels** to the prototype cell.
1. Select the prototype cell, then select the **Identity Inspector**. Change **Class** to **CalendarTableViewCell**.
1. Select the **Attributes Inspector** and set **Identifier** to `EventCell`.
1. With the **EventCell** selected, select the **Connections Inspector** and connect `durationLabel`, `organizerLabel`, and `subjectLabel` to the labels you added to the cell on the storyboard.
1. Set the properties and constraints on the three labels as follows.

    - **Subject Label**
        - Add constraint: Leading space to Content View Leading Margin, value: 0
        - Add constraint: Trailing space to Content View Trailing Margin, value: 0
        - Add constraint: Top space to Content View Top Margin, value: 0
    - **Organizer Label**
        - Font: System 12.0
        - Add constraint: Leading space to Content View Leading Margin, value: 0
        - Add constraint: Trailing space to Content View Trailing Margin, value: 0
        - Add constraint: Top space to Subject Label Bottom, value: Standard
    - **Duration Label**
        - Font: System 12.0
        - Color: Dark Gray Color
        - Add constraint: Leading space to Content View Leading Margin, value: 0
        - Add constraint: Trailing space to Content View Trailing Margin, value: 0
        - Add constraint: Top space to Organizer Label Bottom, value: Standard
        - Add constraint: Bottom space to Content View Bottom Margin, value: 8

    ![A screenshot of the prototype cell layout](./images/prototype-cell-layout.png)

1. Open **CalendarViewController.h** and remove the `calendarJSON` property.
1. Change the `@interface` declaration to the following.

    ```objc
    @interface CalendarViewController : UITableViewController
    ```

1. Open **CalendarViewController.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarViewController.m" id="CalendarViewSnippet":::

1. Run the app, sign in, and tap the **Calendar** tab. You should see the list of events.

    ![A screenshot of the table of events](./images/calendar-list.png)
