//
//  GraphManager.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import "GraphManager.h"

@interface GraphManager()

@property MSHTTPClient* graphClient;

@end

@implementation GraphManager

+ (id) instance {
    static GraphManager *singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        singleInstance = [[self alloc] init];
    });

    return singleInstance;
}

- (id) init {
    if (self = [super init]) {
        // Create the Graph client
        self.graphClient = [MSClientFactory
                            createHTTPClientWithAuthenticationProvider:AuthenticationManager.instance];
    }

    return self;
}

- (void) getMeWithCompletionBlock:(GetMeCompletionBlock)completion {
    // GET /me
    NSString* meUrlString = [NSString stringWithFormat:@"%@/me?%@",
                             MSGraphBaseURL,
                             @"$select=displayName,mail,mailboxSettings,userPrincipalName"];
    NSURL* meUrl = [[NSURL alloc] initWithString:meUrlString];
    NSMutableURLRequest* meRequest = [[NSMutableURLRequest alloc] initWithURL:meUrl];

    MSURLSessionDataTask* meDataTask =
    [[MSURLSessionDataTask alloc]
        initWithRequest:meRequest
        client:self.graphClient
        completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                completion(nil, error);
                return;
            }

            // Deserialize the response as a user
            NSError* graphError;
            MSGraphUser* user = [[MSGraphUser alloc] initWithData:data error:&graphError];

            if (graphError) {
                completion(nil, graphError);
            } else {
                completion(user, nil);
            }
        }];

    // Execute the request
    [meDataTask execute];
}

// <GetCalendarViewSnippet>
- (void) getCalendarViewStartingAt:(NSString *)viewStart endingAt:(NSString *)viewEnd withCompletionBlock:(GetCalendarViewCompletionBlock)completion {
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

        NSError* graphError;

         // Deserialize to an events collection
         MSCollection* eventsCollection = [[MSCollection alloc] initWithData:data error:&graphError];
         if (graphError) {
             completion(nil, graphError);
             return;
         }

         // Create an array to return
         NSMutableArray* eventsArray = [[NSMutableArray alloc]
                                     initWithCapacity:eventsCollection.value.count];

         for (id event in eventsCollection.value) {
             // Deserialize the event and add to the array
             MSGraphEvent* graphEvent = [[MSGraphEvent alloc] initWithDictionary:event];
             [eventsArray addObject:graphEvent];
         }

         completion(eventsArray, nil);
     }];

    // Execute the request
    [eventsDataTask execute];
}
// </GetCalendarViewSnippet>

@end
