//
//  ListingProvider.h
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDefinition.h"

@interface ListingProvider : NSObject
+ (void)getAllClubsLongitude:(double)longitude
                    latitude:(double)latitude
                onSuccess:(ResponseArray)resultBlock
                onFailure:(ResponseError)failureBlock;

+ (void)getUserListing:(NSString*)userId
                  from:(int)from size:(int)size
                onSuccess:(ResponseArray)resultBlock
                onFailure:(ResponseError)failureBlock;

+ (void)deleteUserMessage:(NSString*)userId
                    msgId:(NSString*)messageId
                onSuccess:(ResponseBlock)resultBlock
                onFailure:(ResponseError)failureBlock;

+ (void)getMarkedCount:(NSString*)messageId
             onSuccess:(ResponseObject)resultBlock
             onFailure:(ResponseError)failureBlock;

+ (void)markAsBeento:(NSString*)userId
           messageId:(NSString*)msgId
           hasBeento:(BOOL)beenTo
           onSuccess:(ResponseBlock)resultBlock
           onFailure:(ResponseError)failureBlock;

+ (void)hasBeenTo:(NSString*)userId
        messageId:(NSString*)msgId
        onSuccess:(ResponseObject)resultBlock
        onFailure:(ResponseError)failureBlock;
@end
