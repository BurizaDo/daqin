//
//  LoginProtocol.h
//  daqin
//
//  Created by BurizaDo on 8/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum {
    LOGINTYPE_WEIBO,
    LOGINTYPE_QQ
}LoginType;

@protocol LoginDelegate <NSObject>
-(void)handleLoginResponse:(NSString*)response type:(LoginType)type;
-(void)handleUserResponse:(User*)user;
@end
