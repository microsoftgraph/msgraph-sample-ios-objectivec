//
//  GraphManager.h
//  GraphTutorial
//
//  Copyright (c) Microsoft. All rights reserved.
//  Licensed under the MIT license.
//

#import <Foundation/Foundation.h>
#import <MSGraphClientSDK/MSGraphClientSDK.h>
#import <MSGraphClientModels/MSGraphClientModels.h>
#import <MSGraphClientModels/MSCollection.h>
#import "AuthenticationManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetMeCompletionBlock)(MSGraphUser* _Nullable user, NSError* _Nullable error);
typedef void (^GetCalendarViewCompletionBlock)(NSArray<MSGraphEvent*>* _Nullable events, NSError* _Nullable error);

@interface GraphManager : NSObject

@property (nonatomic) NSString *graphTimeZone;

+ (id) instance;
- (void) getMeWithCompletionBlock: (GetMeCompletionBlock)completion;
- (void) getCalendarViewStartingAt: (NSString*)viewStart endingAt:(NSString*) viewEnd withCompletionBlock:(GetCalendarViewCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
