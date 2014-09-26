//
//  Comment.m
//  daqin
//
//  Created by BurizaDo on 9/23/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "Comment.h"

@implementation Comment
+ (instancetype)parseFromDictionary:(NSDictionary*)dic{
    Comment* cmt = [Comment new];
    cmt.messageId = [dic objectForKey:@"messageId"];
    cmt.message = [dic objectForKey:@"message"];
    cmt.user = [User parseFromDictionary:[dic objectForKey:@"user"]];
    if([dic objectForKey:@"replyUser"]){
        cmt.replyUser = [User parseFromDictionary:[dic objectForKey:@"replyUser"]];
    }
    cmt.timestamp = [[dic objectForKey:@"timestamp"] longLongValue];
    return cmt;
}
@end
