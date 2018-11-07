# Integrate Microsoft Graph into the Application

The last exercise is to incorporate the Microsoft Graph into the application. For this application, you will use the Microsoft Graph REST API.

Alternatively, you can open the final solution from this demo located in this folder. Refer to the prerequisites for what you need to run the demo.

> To run the solution in this demo without recreating the solution, do the following:
> * from the project root run the command `carthage update` to download * build the MSAL library
> * Open the `Info.plist` file and replace the `ENTER_YOUR_CLIENT_ID` in the last setting with your Azure AD application ID

## Prerequisites

To complete this lab, you need the following:

* Office 365 tenancy
  * If you do not have one, you obtain one (for free) by signing up to the [Office 365 Developer Program](https://developer.microsoft.com/en-us/office/dev-program).
* Azure AD application registered using the [App Registration portal](https://apps.dev.microsoft.com) with a native platform configured.
* Desktop / laptop running MacOS
* [XCode v10.1](https://developer.apple.com/xcode/)
* [Cocoapods](https://cocoapods.org)

## Demo

1. Create a new controller for the calendar view:
    1. Select **File > New File**.
        1. Select **Cocoa Touch Class** and select **Next**.
        1. In the **Choose options for your new file** dialog, set the following values, select **Next** and then select **Create**:
            * **Class**: CalendarTableViewController
            * **Subclass of**: UITableViewController
            * **Also create XIB file**: unselected
            * **Language**: Objective-C
    1. Open the **CalendarTableViewController.h** file.
        1. Add the following code to the `CalendarTableViewController` interface:

            ```objc
            @property (strong, nonatomic) NSMutableArray* eventsList;
            ```

1. Associate the calendar events view with it's new controller:
    1. In the **Navigator** panel, select **Main.storyboard**.
    1. In the storyboard designer, select the **Root View Controller Scene > Root View Controller**
        1. In the **Utilities** panel, within the **Identity** inspector, set the **Class** to **CalendarTableViewController**.

            ![Screenshot associating the calendar view to the controller](../../Images/xcode-graph-01.png)

        1. In the **Utilities** panel, within the **Identity** inspector:
            * Set the **Identity > Storyboard ID** to **calendarList**.
            * Set the **Document > Label** to **CalendarList**.
    1. In the storyboard designer, select the **CalendarList Scene > CalendarList > Table View > Table View Cell**.
        1. In the **Utilities** panel, within the **Identity** inspector, set the **Document > Label** to **calendarListCell**.
        1. In the **Utilities** panel, within the **Attributes** inspector, set the **Table View Cell > Identifier** to **eventCellTableViewCell**.

1. Implement the user interface for the table cells that will display events.
    1. In the **Utilities** panel, drag two **Label** controls from the **Object** library into the white box for the table view cell.
        * Place the two tables vertically and left-aligned.
        * Stretch the width of the labels to go to the right edge of the screen to avoid wrapping.
    1. In the **Utilities** panel, within the **Attributes** inspector, modify the formatting of the two labels as you would like them to appear

        ![Screenshot associating the calendar view to the controller](../../Images/xcode-graph-02.png)

    1. In the **Utilities** panel, within the **Identity** inspector, set the **Document > Label** for the two labels to the following values:
        * subjectLabel
        * dateLabel
    1. In the **Utilities** panel, within the **Attributes** inspector, set the select each of the two labels and set the following properties:
        * subjectLabel
            * **Label > Label**: subjectLabel
            * **View > Tag**: 100
        * dateLabel
            * **Label > Label**: dateLabel
            * **View > Tag**: 200

    1. Open the **CalendarTableViewController.m** file.
    1. Add the following `import` statement after the existing ones:

        ```objc
        #import "AuthenticationManager.h"
        #import <MSAL/MSAL.h>
        ```

1. Implement the calendar view's controller:
    1. Open the **CalendarTableViewController.m** file.
    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        -(void)getEvents
        {
            // authProvider
            AuthenticationManager *authManager = [AuthenticationManager sharedInstance];

            UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(100,100,50,50)];
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
            [spinner setColor:[UIColor blackColor]];
            [self.view addSubview:spinner];
            spinner.hidesWhenStopped = YES;
            [spinner startAnimating];

            NSString *dataUrl = @"https://graph.microsoft.com/v1.0/me/events?$select=subject,start,end";
            NSURL *url = [NSURL URLWithString:dataUrl];
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
            request.HTTPMethod = @"GET";

            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"application/json, text/plain, */*" forHTTPHeaderField:@"Accept"];

            NSString *authorization = [NSString stringWithFormat:@"Bearer %@", authManager.accessToken];
            [request setValue:authorization forHTTPHeaderField:@"Authorization"];

            __weak CalendarTableViewController *weakSelf = self;
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        // ...
                                                        CalendarTableViewController *strongSelf = weakSelf;
                                                        NSError *jsonError = nil;

                                                        NSDictionary *jsonFinal = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                        if (jsonError)
                                                        {
                                                            NSLog(@"Error: %@", jsonError);
                                                        }
                                                        self.eventsList = [jsonFinal valueForKey:@"value"];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [spinner stopAnimating];
                                                            [spinner removeFromSuperview];
                                                            [strongSelf.tableView reloadData];
                                                        });
                                                    }];

            [task resume];
        }
        ```

    1. Add the following code to the `viewDidLoad()` method:

        ```objc
        self.eventsList = [[NSMutableArray alloc] init];
        [self getEvents];
        ```

    1. Add the following three utility methods to the `CalendarTableViewController` class:

        ```objc
        - (UIImage *)imageWithColor:(UIColor *)color {
            CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
            UIGraphicsBeginImageContext(rect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSetFillColorWithColor(context, [color CGColor]);
            CGContextFillRect(context, rect);

            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();

            return image;
        }
        -(NSString *)converStringToDateString:(NSString *)stringDate {
            NSString *result = @"";

            NSDateFormatter *retdateFormat = [[NSDateFormatter alloc] init];
            [retdateFormat setDateFormat:@"yyyy'/'MM'/'dd HH':'mm"];

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"];
            NSDate *convertData =[formatter dateFromString:stringDate];

            result = [retdateFormat stringFromDate:convertData];

            return result;
        }

        - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];

            UIButton* actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [actionButton setFrame:CGRectMake(15, 15, 100, 40)];
            [actionButton setBackgroundImage:[self imageWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
            [actionButton setTitle:@"Reload" forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(getEvents) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:actionButton];

            NSString *lbl1str = @"The events in the last 30 days.";
            UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 280, 30)];
            lbl1.text = lbl1str;
            lbl1.textAlignment = NSTextAlignmentLeft;
            lbl1.font = [UIFont systemFontOfSize:16];
            lbl1.textColor = [UIColor colorWithRed:136.00f/255.00f green:136.00f/255.00f blue:136.00f/255.00f alpha:1];
            [view addSubview:lbl1];

            return view;
        }
        ```

    1. Locate the method `numberOfSectionsInTableView()` in the `CalendarTableViewController` class. Replace the contents of this method with the following code:

        ```objc
        return 1;
        ```

    1. Locate the method `numberOfRowsInSection()` in the `CalendarTableViewController` class. Replace the contents of this method with the following code:

        ```objc
        return [self.eventsList count];
        ```

    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
        {
            return 100;
        }
        ```

    1. Add the following method to the `CalendarTableViewController` class:

        ```objc
        - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
            static NSString *CellIdentifier = @"eventCellTableViewCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            // Configure the cell...
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            UILabel *subjectLabel = (UILabel *)[cell viewWithTag:100];
            NSDictionary *calendarItem = [self.eventsList objectAtIndex:indexPath.row];
            subjectLabel.text = [calendarItem valueForKey:@"subject"]; // ((MSGraphEvent *)[self.eventsList objectAtIndex:indexPath.row]).subject;;

            NSString *startTime = (NSString *)[[calendarItem valueForKey:@"start"] valueForKey:@"dateTime"];
            NSString *endTime = (NSString *)[[calendarItem valueForKey:@"end"] valueForKey:@"dateTime"];

            NSString *startText = [NSString stringWithFormat:@"Start: %@",[self converStringToDateString:startTime]];
            NSString *endText = [NSString stringWithFormat:@"%@",[self converStringToDateString:endTime]];

            NSString *eventDatetime = startText;
            eventDatetime = [eventDatetime stringByAppendingString:@" - "];
            eventDatetime = [eventDatetime stringByAppendingString:endText];

            UILabel *dateLabel = (UILabel *)[cell viewWithTag:200];
            dateLabel.text = eventDatetime;

            return cell;
        }
        ```

1. Update the login controller so after a successful login, it will programmatically load the calendar event view:
    1. In the **Navigator**, select the **LoginViewController.m**
    1. Locate the `loginAction()` method in the `LoginViewController` class.
    1. Within the `loginAction()` method, locate the following `else` statement:

        ```objc
        ..
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoadingUI:NO];
                MSALUser *currentUser = [authenticationManager user];

                NSString *successMessage = @"Authentication succeeded for: ";
                successMessage = [successMessage stringByAppendingString:[currentUser name]];
                successMessage = [successMessage stringByAppendingString:@" ("];
                successMessage = [successMessage stringByAppendingString:[currentUser displayableId]];
                successMessage = [successMessage stringByAppendingString:@")"];

                [self showMessage:successMessage withTitle:@"Success"];
            });
        }
        ```

    1. Replace the body of the `dispatch_async()` method with code that will update the login view and navigate to the **calendarList** view:

        ```objc
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLoadingUI:NO];
                self.loginButton.enabled = NO;
                self.logoutButton.enabled = YES;

                UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:NSBundle.mainBundle];
                UIViewController *calVC = [board instantiateViewControllerWithIdentifier:@"calendarList"];
                [self.navigationController pushViewController:calVC animated:YES];
            });
        }
        ```

1. Test the user interface:
    1. Select the play button in the toolbar to build & run the application in the iPhone simulator.
    1. When the application loads in the simulator, select **Signin with Microsoft**.
    1. When prompted, signin using your Office 365 account:
    1. After a successful signin, the app will navigate to the view that displays events from your calendar:

        ![Screenshot of the iOS prompting the user to login](../../Images/xcode-graph-03.png)

    1. Select the **Back** link at the top of the screen to go back to the login view where you can optionally signout.
