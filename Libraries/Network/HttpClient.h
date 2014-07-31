//
//  HJHttpClient.h
//  Baixing
//
//  Created by neoman on 8/20/13.
//
//

#import "AFHTTPClient.h"
typedef void (^ResponseObject)(id obj);
@interface HttpClient : AFHTTPClient

+ (HttpClient *)sharedClient;

+ (void)configWith:(NSString*)baseUrl key:(NSString*)apiKey secret:(NSString*)apiSecret;

+ (void)resetBaseUrlString:(NSString*)baseUrl;

// GET API
- (void)getAPI:(NSString *)api
        params:(NSDictionary *)params
        success:(ResponseObject)sucBlock
       failure:(void (^)(NSString* errMsg)) errBlock;

// get Path
- (void)getPath:(NSString *)path
         params:(NSDictionary *)params
        success:(ResponseObject)sucBlock
        failure:(void (^)(NSString* errMsg)) errBlock;

// POST API
- (void)postAPI:(NSString *)api
         params:(NSDictionary *)params
        success:(ResponseObject)sucBlock
        failure:(void (^)(NSString* errMsg)) errBlock;

// Track data API
- (void)postTrackingJson:(NSString *)json
             commonParams:(NSDictionary*)commonDic
                 success:(ResponseObject)sucBlock
                 failure:(void (^)(NSString* errMsg)) errBlock;

@end
