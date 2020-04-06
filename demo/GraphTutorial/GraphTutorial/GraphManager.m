//
//  GraphManager.m
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
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

- (void) getMeWithCompletionBlock:(GetMeCompletionBlock)completionBlock {
    // GET /me
    NSString* meUrlString = [NSString stringWithFormat:@"%@/me", MSGraphBaseURL];
    NSURL* meUrl = [[NSURL alloc] initWithString:meUrlString];
    NSMutableURLRequest* meRequest = [[NSMutableURLRequest alloc] initWithURL:meUrl];

    MSURLSessionDataTask* meDataTask =
    [[MSURLSessionDataTask alloc]
        initWithRequest:meRequest
        client:self.graphClient
        completion:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                completionBlock(nil, error);
                return;
            }

            // Deserialize the response as a user
            NSError* graphError;
            MSGraphUser* user = [[MSGraphUser alloc] initWithData:data error:&graphError];

            if (graphError) {
                completionBlock(nil, graphError);
            } else {
                completionBlock(user, nil);
            }
        }];

    // Execute the request
    [meDataTask execute];
}

// <GetEventsSnippet>
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

         NSError* graphError;

         // Deserialize to an events collection
         MSCollection* eventsCollection = [[MSCollection alloc] initWithData:data error:&graphError];
         if (graphError) {
             completionBlock(nil, graphError);
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

         completionBlock(eventsArray, nil);
     }];

    // Execute the request
    [eventsDataTask execute];
}
// </GetEventsSnippet>

@end
