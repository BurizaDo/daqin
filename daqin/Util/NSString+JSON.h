//
//  NSString+JSON.h
//  Baixing
//
//  Created by neoman on 5/7/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)

- (id)objectFromJSONString;
- (id)objectFromJSONStringWithError:(NSError *__autoreleasing *)error;

@end
