//
//  Error.h
//  daqin
//
//  Created by BurizaDo on 8/13/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Error : NSObject
@property (nonatomic) int errorCode;
@property (nonatomic, copy) NSString* errorMsg;

+ (instancetype) errorWithCode:(int)code message:(NSString*)msg;
@end
