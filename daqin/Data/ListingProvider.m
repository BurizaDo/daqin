//
//  ListingProvider.m
//  daqin
//
//  Created by BurizaDo on 7/28/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import "ListingProvider.h"
#import "HttpClient.h"
#import "Club.h"
#import "EventDefinition.h"

@implementation ListingProvider

+ (void)getAllClubsLongitude:(double)longitude
                    latitude:(double)latitude
                   onSuccess:(ResponseArray)resultBlock
                onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"longitude":[NSNumber numberWithDouble:longitude], @"latitude":[NSNumber numberWithDouble:latitude]};
    [[HttpClient sharedClient] postAPI:@"getClubs" params:param success:^(id obj) {
        NSArray* ary = obj;
        NSMutableArray* clubs = [[NSMutableArray alloc] init];
        for(NSDictionary* dic in ary){
            Club* club = [[Club alloc] init];
            club.name = [dic objectForKey:@"name"];
            club.clubId = [[dic objectForKey:@"id"] integerValue];
            club.longitude = [[dic objectForKey:@"longitude"] doubleValue];
            club.latitude = [[dic objectForKey:@"latitude"] doubleValue];
            club.address = [dic objectForKey:@"address"];
            club.images = [dic objectForKey:@"images"];
            [clubs addObject:club];
        }
        resultBlock(clubs);
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
//            Route* route = [[Route alloc] init];
//            route.routeId = [dic objectForKey:@"id"];
//            route.destination = [dic objectForKey:@"destination"];
//            route.description = [dic objectForKey:@"message"];
//            route.user = [User parseFromDictionary:[dic objectForKey:@"user"]];
//            route.startTime = [dic objectForKey:@"start_time"];
//            route.endTime = [dic objectForKey:@"end_time"];
//            [routes addObject:route];
        }
        resultBlock(routes);
    } failure:^(Error* error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
    
}

+ (void)deleteUserMessage:(NSString*)userId
                    msgId:(NSString*)messageId
                onSuccess:(ResponseBlock)resultBlock
                onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"userId" : userId,
                            @"messageId":messageId};
    
    [[HttpClient sharedClient] postAPI:@"deleteMessage" params:param success:^(id obj) {
        resultBlock();
    } failure:^(Error* error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
    
}

+ (void)getMarkedCount:(NSString*)messageId
             onSuccess:(ResponseObject)resultBlock
             onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"messageId":messageId};
    [[HttpClient sharedClient] getAPI:@"getMarkedCount" params:param success:^(id object) {
        resultBlock(object);
    } failure:^(Error *error) {
        failureBlock(error);
    }];
}

+ (void)markAsBeento:(NSString*)userId
           messageId:(NSString*)msgId
           hasBeento:(BOOL)beenTo
           onSuccess:(ResponseBlock)resultBlock
           onFailure:(ResponseError)failureBlock{
    NSNumber* bt = [NSNumber numberWithBool:beenTo];
    NSDictionary* param = @{@"messageId":msgId, @"userId":userId, @"hasBeenTo":bt};
    [[HttpClient sharedClient] getAPI:@"markAsBeenTo" params:param success:^(id object) {
        resultBlock(object);
    } failure:^(Error *error) {
        failureBlock(error);
    }];
}

+ (void)hasBeenTo:(NSString*)userId
        messageId:(NSString*)msgId
        onSuccess:(ResponseObject)resultBlock
        onFailure:(ResponseError)failureBlock{
    NSDictionary* param = @{@"userId":userId, @"messageId":msgId};
    [[HttpClient sharedClient] getAPI:@"hasBeenTo" params:param success:^(id object) {
        resultBlock(object);
    } failure:^(Error *error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
}


@end
