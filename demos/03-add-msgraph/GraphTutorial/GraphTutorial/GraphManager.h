//
//  GraphManager.h
//  GraphTutorial
//
//  Copyright © 2019 Microsoft. All rights reserved.
//  Licensed under the MIT license. See LICENSE.txt in the project root for license information.
//

#import <Foundation/Foundation.h>
#import <MSGraphClientSDK/MSGraphClientSDK.h>
#import <MSGraphClientModels/MSGraphClientModels.h>
#import "AuthenticationManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^GetMeCompletionBlock)(MSGraphUser* _Nullable user, NSError* _Nullable error);
typedef void (^GetEventsCompletionBlock)(NSData* _Nullable data, NSError* _Nullable error);

@interface GraphManager : NSObject

+ (id) instance;
- (void) getMeWithCompletionBlock: (GetMeCompletionBlock)completionBlock;
- (void) getEventsWithCompletionBlock: (GetEventsCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
