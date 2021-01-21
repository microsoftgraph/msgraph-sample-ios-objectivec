<!-- markdownlint-disable MD002 MD041 -->

In this exercise you will incorporate the Microsoft Graph into the application. For this application, you will use the [Microsoft Graph SDK for Objective C](https://github.com/microsoftgraph/msgraph-sdk-objc) to make calls to Microsoft Graph.

## Get calendar events from Outlook

In this section you will extend the `GraphManager` class to add a function to get the user's events for the current week and update `CalendarViewController` to use this new function.

1. Open **GraphManager.h** and add the following code above the `@interface` declaration.

    ```objc
    typedef void (^GetCalendarViewCompletionBlock)(NSData* _Nullable data,
                                                   NSError* _Nullable error);
    ```

1. Add the following code to the `@interface` declaration.

    ```objc
    - (void) getCalendarViewStartingAt: (NSString*) viewStart
                              endingAt: (NSString*) viewEnd
                   withCompletionBlock: (GetCalendarViewCompletionBlock) completion;
    ```

1. Open **GraphManager.m** and add the following function to the `GraphManager` class.

    ```objc
    - (void) getCalendarViewStartingAt: (NSString *) viewStart
                              endingAt: (NSString *) viewEnd
                   withCompletionBlock: (GetCalendarViewCompletionBlock) completion {
        // Set calendar view start and end parameters
        NSString* viewStartEndString =
        [NSString stringWithFormat:@"startDateTime=%@&endDateTime=%@",
         viewStart,
         viewEnd];

        // GET /me/calendarview
        NSString* eventsUrlString =
        [NSString stringWithFormat:@"%@/me/calendarview?%@&%@&%@&%@",
         MSGraphBaseURL,
         viewStartEndString,
         // Only return these fields in results
         @"$select=subject,organizer,start,end",
         // Sort results by start time
         @"$orderby=start/dateTime",
         // Request at most 25 results
         @"$top=25"];

        NSURL* eventsUrl = [[NSURL alloc] initWithString:eventsUrlString];
        NSMutableURLRequest* eventsRequest = [[NSMutableURLRequest alloc] initWithURL:eventsUrl];

        // Add the Prefer: outlook.timezone header to get start and end times
        // in user's time zone
        NSString* preferHeader =
        [NSString stringWithFormat:@"outlook.timezone=\"%@\"",
         self.graphTimeZone];
        [eventsRequest addValue:preferHeader forHTTPHeaderField:@"Prefer"];

        MSURLSessionDataTask* eventsDataTask =
        [[MSURLSessionDataTask alloc]
         initWithRequest:eventsRequest
         client:self.graphClient
         completion:^(NSData *data, NSURLResponse *response, NSError *error) {
             if (error) {
                 completion(nil, error);
                 return;
             }

             // TEMPORARY
             completion(data, nil);
         }];

        // Execute the request
        [eventsDataTask execute];
    }
    ```

    > [!NOTE]
    > Consider what the code in `getCalendarViewStartingAt` is doing.
    >
    > - The URL that will be called is `/v1.0/me/calendarview`.
    >   - The `startDateTime` and `endDateTime` query parameters define the start and end of the calendar view.
    >   - The `select` query parameter limits the fields returned for each events to just those the view will actually use.
    >   - The `orderby` query parameter sorts the results by start time.
    >   - The `top` query parameter requests 25 results per page.
    >   - the `Prefer: outlook.timezone` header causes the Microsoft Graph to return the start and end times of each event in the user's time zone.

1. Create a new **Cocoa Touch Class** in the **GraphTutorial** project named **GraphToIana**. Choose **NSObject** in the **Subclass of** field.
1. Open **GraphToIana.h** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/GraphToIana.h" id="GraphToIanaSnippet":::

1. Open **GraphToIana.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/GraphToIana.m" id="GraphToIanaSnippet":::

    This does a simple lookup to find an IANA time zone identifier based on the time zone name returned by Microsoft Graph.

1. Open **CalendarViewController.m** and replace its entire contents with the following code.

    ```objc
    #import "CalendarViewController.h"
    #import "SpinnerViewController.h"
    #import "GraphManager.h"
    #import "GraphToIana.h"
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
         withCompletionBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
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

Now you can replace the JSON dump with something to display the results in a user-friendly manner. In this section, you will modify the `getCalendarViewStartingAt` function to return strongly-typed objects, and modify `CalendarViewController` to use a table view to render the events.

### Update getCalendarViewStartingAt

1. Open **GraphManager.h**. Change the `GetCalendarViewCompletionBlock` type definition to the following.

    ```objc
    typedef void (^GetCalendarViewCompletionBlock)(NSArray<MSGraphEvent*>* _Nullable events, NSError* _Nullable error);
    ```

1. Open **GraphManager.m**. Replace the existing `getCalendarViewStartingAt` function with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/GraphManager.m" id="GetCalendarViewSnippet" highlight="42-61":::

### Update CalendarViewController

1. Create a new **Cocoa Touch Class** file in the **GraphTutorial** project named `CalendarTableViewCell`. Choose **UITableViewCell** in the **Subclass of** field.
1. Open **CalendarTableViewCell.h** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewCell.h" id="CalendarTableCellSnippet":::

1. Open **CalendarTableViewCell.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewCell.m" id="CalendarTableCellSnippet":::

1. Create a new **Cocoa Touch Class** file in the **GraphTutorial** project named `CalendarTableViewController`. Choose **UITableViewController** in the **Subclass of** field.
1. Open **CalendarTableViewController.h** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewController.h" id="CalendarTableViewControllerSnippet":::

1. Open **CalendarTableViewController.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarTableViewController.m" id="CalendarTableViewControllerSnippet":::

1. Open **Main.storyboard** and locate the **Calendar Scene**. Delete the scroll view from the root view.
1. Using the **Library**, add a **Navigation Bar** to the top of the view.
1. Double-click the **Title** in the navigation bar and update it to `Calendar`.
1. Using the **Library**, add a **Bar Button Item** to the right-hand side of the navigation bar.
1. Select the new bar button, then select the **Attributes Inspector**. Change **Image** to **plus**.
1. Add a **Container View** from the **Library** to the view under the navigation bar. Resize the container view to take all of the remaining space in the view.
1. Set constraints on the navigation bar and container view as follows.

    - **Navigation Bar**
        - Add constraint: Height, value: 44
        - Add constraint: Leading space to Safe Area, value: 0
        - Add constraint: Trailing space to Safe Area, value: 0
        - Add constraint: Top space to Safe Area, value: 0
    - **Container View**
        - Add constraint: Leading space to Safe Area, value: 0
        - Add constraint: Trailing space to Safe Area, value: 0
        - Add constraint: Top space to Navigation Bar Bottom, value: 0
        - Add constraint: Bottom space to Safe Area, value: 0

1. Locate the second view controller added to the storyboard when you added the container view. It is connected to the **Calendar Scene** by an embed segue. Select this controller and use the **Identity Inspector** to change **Class** to **CalendarTableViewController**.
1. Delete the **View** from the **Calendar Table View Controller**.
1. Add a **Table View** from the **Library** to the **Calendar Table View Controller**.
1. Select the table view, then select the **Attributes Inspector**. Set **Prototype Cells** to **1**.
1. Drag the bottom edge of the prototype cell to give you a larger area to work with.
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
        - Add constraint: Height, value: 15
        - Add constraint: Leading space to Content View Leading Margin, value: 0
        - Add constraint: Trailing space to Content View Trailing Margin, value: 0
        - Add constraint: Top space to Subject Label Bottom, value: Standard
    - **Duration Label**
        - Font: System 12.0
        - Color: Dark Gray Color
        - Add constraint: Height, value: 15
        - Add constraint: Leading space to Content View Leading Margin, value: 0
        - Add constraint: Trailing space to Content View Trailing Margin, value: 0
        - Add constraint: Top space to Organizer Label Bottom, value: Standard
        - Add constraint: Bottom space to Content View Bottom Margin, value: 0

1. Select the **EventCell**, then select the **Size Inspector**. Enable **Automatic** for **Row Height**.

    ![A screenshot of the calendar and calendar table view controllers](images/calendar-table-storyboard.png)

1. Open **CalendarViewController.h** and remove the `calendarJSON` property.

1. Open **CalendarViewController.m** and replace its contents with the following code.

    :::code language="objc" source="../demo/GraphTutorial/GraphTutorial/CalendarViewController.m" id="CalendarViewControllerSnippet":::

1. Run the app, sign in, and tap the **Calendar** tab. You should see the list of events.

    ![A screenshot of the table of events](./images/calendar-list.png)
