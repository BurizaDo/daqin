//
//  NSDictionary+JSON.m
//  Baixing
//
//  Created by neoman on 5/7/14.
//
//

#import "NSDictionary+JSON.h"


@implementation NSDictionary (JSON)

- (NSString *)JSONString
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end