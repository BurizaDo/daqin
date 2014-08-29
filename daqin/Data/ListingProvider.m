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
#import "EventDefinition.h"

@implementation ListingProvider

+ (void)getAllListingFrom:(int)from size:(int)size
                onSuccess:(ResponseArray)resultBlock
                onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"start":[NSNumber numberWithInt:from], @"size":[NSNumber numberWithInt:size]};
    [[HttpClient sharedClient] postAPI:@"getMessage" params:param success:^(id obj) {
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
    } failure:^(Error* error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
}

+ (void)getUserListing:(NSString*)userId
                  from:(int)from size:(int)size
             onSuccess:(ResponseArray)resultBlock
             onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"userId" : userId,
                            @"from":[NSNumber numberWithInt:from],
                            @"size":[NSNumber numberWithInt:size]};
    [[HttpClient sharedClient] postAPI:@"getUserMessage" params:param success:^(id obj) {
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
    } failure:^(Error* error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
    
}


@end
