//
//  NSData+JSON.h
//  Baochuan
//
//  Created by Zhong Jiawu on 13-6-5.
//  Copyright (c) 2013年 Baixing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JSON)

- (id)objectFromJSONData;

- (id)objectFromJSONDataWithError:(NSError *__autoreleasing *)error;

@end
