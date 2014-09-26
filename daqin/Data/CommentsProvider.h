//
//  CommentsProvider.h
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDefinition.h"

@interface CommentsProvider : NSObject

+ (void)commitCommentMessageId:(NSString*)msgId
                        userId:(NSString*)userId
                       replyId:(NSString*)replyId
                       message:(NSString*)message
                     timestamp:(NSString*)timestamp
                     onSuccess:(ResponseBlock)successBlock
                     onFailure:(ResponseError)failureBlock;

+ (void)getCommentsMessageId:(NSString*)msgId
                        from:(int)from
                        size:(int)size
                   onSuccess:(ResponseArray)successBlock
                   onFailure:(ResponseError)failureBlock;
@end
