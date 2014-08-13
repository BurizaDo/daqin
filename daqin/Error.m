//
//  Error.m
//  daqin
//
//  Created by BurizaDo on 8/13/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "Error.h"

@implementation Error
+ (instancetype) errorWithCode:(int)code message:(NSString*)msg{
    Error* error = [Error new];
    error.errorCode = code;
    error.errorMsg = msg;
    return error;
}
@end
