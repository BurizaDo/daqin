//
//  ListingProvider.m
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ListingProvider.h"
#import "HttpClient.h"
#import "Route.h"

@implementation ListingProvider

+ (void)getAllListingFrom:(int)from size:(int)size
                onSuccess:(void(^)(NSArray *areas))resultBlock
                onFailure:(void(^)(NSString* error))failureBlock{
    [[HttpClient sharedClient] postAPI:@"getMessage" params:nil success:^(id obj) {
        NSArray* ary = obj;
        NSMutableArray* routes = [[NSMutableArray alloc] init];
        for(NSDictionary* dic in ary){
            Route* route = [[Route alloc] init];
            route.destination = [dic objectForKey:@"destination"];
            route.description = [dic objectForKey:@"message"];
            route.user = [User parseFromDictionary:[dic objectForKey:@"user"]];
            route.startTime = [dic objectForKey:@"start_time"];
            route.endTime = [dic objectForKey:@"end_time"];
            [routes addObject:route];
        }
        resultBlock(routes);
    } failure:^(NSString *errMsg) {
        if(failureBlock){
            failureBlock(errMsg);
        }
    }];
}

@end
