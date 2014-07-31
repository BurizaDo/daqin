//
//  ListingProvider.h
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListingProvider : NSObject
+ (void)getAllListingFrom:(int)from size:(int)size
                onSuccess:(void(^)(NSArray *areas))resultBlock
                onFailure:(void(^)(NSString* error))failureBlock;

@end
