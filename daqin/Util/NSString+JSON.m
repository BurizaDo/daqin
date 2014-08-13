//
//  NSString+JSON.m
//  Baixing
//
//  Created by neoman on 5/7/14.
//
//

#import "NSString+JSON.h"
#import "NSData+JSON.h"


@implementation NSString (JSON)

- (id)objectFromJSONString
{
    NSData *d = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [d objectFromJSONData];
}

- (id)objectFromJSONStringWithError:(NSError *__autoreleasing *)error
{
    NSData *d = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [d objectFromJSONDataWithError:error];
}

@end
