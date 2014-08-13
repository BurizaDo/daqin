//
//  BXMessageInfo.h
//  Baixing
//
//  Created by neoman on 5/20/14.
//
//

#import <Foundation/Foundation.h>

@interface MessageInfo : NSObject

@property (nonatomic, copy) NSString        *name;
@property (nonatomic, copy) NSString        *content;
@property (nonatomic, strong) NSDate        *timeStamp;
@property (nonatomic, copy) NSString        *iconUrl;
@property (nonatomic, assign) NSUInteger    badgeCount;
@property (nonatomic, copy) NSString        *receiveId;

+ (instancetype)randomMessageInfo;

@end