//
//  CommentsProvider.m
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "CommentsProvider.h"
#import"HttpClient.h"
#import "Comment.h"

@implementation CommentsProvider

+ (void)commitCommentMessageId:(NSString*)msgId
                        userId:(NSString*)userId
                       replyId:(NSString*)replyId
                       message:(NSString*)message
                     timestamp:(NSString*)timestamp
                     onSuccess:(ResponseBlock)successBlock
                     onFailure:(ResponseError)failureBlock{
    NSMutableDictionary* param = [@{@"messageId":msgId, @"userId":userId, @"message":message, @"timestamp":timestamp} mutableCopy];
    if(replyId != nil){
        [param setValue:replyId forKey:@"replyId"];
    }
    [[HttpClient sharedClient] postAPI:@"commitComment" params:param success:^(id object) {
        successBlock();
    } failure:^(Error *error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
}

+ (void)getCommentsMessageId:(NSString*)msgId
                        from:(int)from
                        size:(int)size
                   onSuccess:(ResponseArray)successBlock
                   onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"messageId":msgId, @"from":[NSNumber numberWithInt:from], @"size":[NSNumber numberWithInt:size]};
    [[HttpClient sharedClient] getAPI:@"getComments" params:param success:^(id object) {
        NSArray* ary = object;
        NSMutableArray* comments = [[NSMutableArray alloc] init];
        for(NSDictionary* dic in ary){
            Comment* cmt = [Comment parseFromDictionary:dic];
            [comments addObject:cmt];
        }
        successBlock(comments);
    } failure:^(Error *error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
}

@end
