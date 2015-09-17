//
//  HJHttpClient.m
//  Baixing
//
//  Created by neoman on 8/20/13.

#import "HttpClient.h"
#import "NSData+JSON.h"
#import <Foundation/NSURL.h>
//#import <Reachability.h>
//#import "NSData+GZIP.h"
//#import "NSString+BCAdditions.h"
//#import "NSData+MD5.h"
//#import "BXConsts.h"
#import <UIKit/UIDevice.h>
//#import "UIDevice+IdentifierAddition.h"
#import "AFHTTPRequestOperation.h"
//#import "NSData+JSON.h"
#import "SVProgressHUD.h"


#define TIMEOUTINTERVAL                 20.0


static HttpClient *SingleTon;
static NSString* s_baseUrl;
static NSString* s_apiKey;
static NSString* s_apiSecret;

@implementation HttpClient

+ (void)configWith:(NSString*)baseUrl key:(NSString*)apiKey secret:(NSString*)apiSecret
{
    s_baseUrl = baseUrl;
    s_apiKey = apiKey;
    s_apiSecret = apiSecret;
}

+ (HttpClient *)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SingleTon = [[HttpClient alloc] initWithBaseURL:[NSURL URLWithString:s_baseUrl]];
//        SingleTon = [HttpClient clientWithBaseURL:[NSURL URLWithString:s_baseUrl]];
    });

    return SingleTon;
}

+ (void)resetBaseUrlString:(NSString*)baseUrl
{
    SingleTon = [[HttpClient alloc] initWithBaseURL:[NSURL URLWithString:s_baseUrl]];
//    SingleTon = [HttpClient clientWithBaseURL:[NSURL URLWithString:baseUrl]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - API methods
/**
 *  发送http get请求，从而调用相应api制定的接口
 *
 *  @param api      接口名称，注意区分graph和非graph接口
 *  @param par      接口所需的参数
 *  @param sucBlock 成功时需要调用的block
 *  @param errBlock 失败时需要调用的block，errBlock不为nil的时候，caller负责错误逻辑，包含UI提示；errBlock为nil的时候该函数会根据err不同的type提示对用户友好的信息
 */
- (void)getAPI:(NSString *)api
        params:(NSDictionary *)par
       success:(ResponseObject)sucBlock
       failure:(ResponseError) errBlock;
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:par];
//    NSString *path = [self generatePathWithApi:api];
    [params setObject:api forKey:@"api"];
    
    [self getPath:api params:params success:sucBlock failure:errBlock];
}

- (void)getPath:(NSString *)api
         params:(NSDictionary *)params
        success:(ResponseObject)sucBlock
        failure:(ResponseError) errBlock;
{
    NSString *path = [self generatePathWithApi:api];
    
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:path parameters:params error:nil];
    
//    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:params];
    [request setValue:s_apiKey forHTTPHeaderField:@"BAPI-APP-KEY"];
//    [request setValue:APP_VERSION forHTTPHeaderField:@"APP_VERSION"];
//    [request setValue:UDID forHTTPHeaderField:@"UDID"];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:TIMEOUTINTERVAL];
    
//    NSString* token = [params valueForKey:PARAM_USER_TOKEN];
//    if(token){
//        [request setValue:token forHTTPHeaderField:kHEADER_USERTOKEN];
//    }
    
//    if (api != nil) {
//        [request setValue:[self signApi:api WithBody:nil] forHTTPHeaderField:@"BAPI-HASH"];
//    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *err = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&err];
        if(err) {
        } else {
            obj = [obj objectForKey:@"result"];
            if (sucBlock) {
                sucBlock(obj);
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *err = nil;
        NSDictionary *errDic = [operation.responseData objectFromJSONDataWithError:&err];
        errBlock([Error errorWithCode:[[errDic objectForKey:@"code"] intValue] message:[errDic objectForKey:@"msg"]]);
    }];
    
    [operation start];
//    [self enqueueHTTPRequestOperation:operation];
}

/**
 *  发送http post请求，从而调用相应api制定的接口
 *
 *  @param api      接口名称，注意区分graph和非graph接口
 *  @param params   接口所需的参数
 *  @param sucBlock 成功时需要调用的block
 *  @param errBlock 失败时需要调用的block，errBlock不为nil的时候，caller负责错误逻辑，包含UI提示；errBlock为nil的时候该函数会根据err不同的type提示对用户友好的信息
 */
- (void)postAPI:(NSString *)api
         params:(NSDictionary *)params
        success:(ResponseObject)sucBlock
        failure:(ResponseError)errBlock
{
    AFHTTPResponseSerializer* a;
    NSString *uri = [self generatePathWithApi:api];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:uri parameters:@{} error:nil];
//    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:uri parameters:@{}];

    if(params){
        NSError* err = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&err];
        NSString *requestBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [request setHTTPShouldHandleCookies:NO];

    [request setTimeoutInterval:TIMEOUTINTERVAL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *err = nil;
        NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        id obj = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&err];
        if(err) {
        } else {
            obj = [obj objectForKey:@"result"];
            if (sucBlock) {
                sucBlock(obj);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError* err = nil;
        NSDictionary *errDic = [operation.responseData objectFromJSONDataWithError:&err];
        errBlock([Error errorWithCode:[[errDic objectForKey:@"code"] intValue] message:[errDic objectForKey:@"msg"]]);

    }];

    [operation start];
//    [self enqueueHTTPRequestOperation:operation];
}
//
//- (void)postTrackingJson:(NSString *)json
//            commonParams:(NSDictionary*)commonDic
//            success:(ResponseObject)sucBlock
//            failure:(ResponseError)errBlock
//{
//    Reachability *reach = [Reachability reachabilityForInternetConnection];
//    NSString *networkValue = @"none";
//    if ([reach isReachable]) {
//        networkValue = [reach isReachableViaWiFi] ? @"wifi" : @"cell";
//    }    
//    
//    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    
//    [params setObject:commonDic forKey:@"commonJson"];
//    [params setObject:jsonArr forKey:@"json"];
//    
//    NSString *uri = [self generatePathWithApi:kHJAPI_MOBILE_TRACK_DATA];
//    
//    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:uri parameters:@{}];
//    
//    NSString *requestBody = [params JSONString];
//    NSData *bodyData = [requestBody dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *gzipBody = [bodyData gzippedData];
//    
//    [request setHTTPBody:gzipBody];
//    [request setValue:s_apiKey forHTTPHeaderField:@"BAPI-APP-KEY"];
//    [request setValue:[self signApi:kHJAPI_MOBILE_TRACK_DATA withData:gzipBody] forHTTPHeaderField:@"BAPI-HASH"];
//    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:UDID forHTTPHeaderField:@"UDID"];
//    [request setHTTPShouldHandleCookies:NO];
//    
//    NSString* token = [params valueForKey:PARAM_USER_TOKEN];
//    if(token){
//        [request setValue:token forHTTPHeaderField:kHEADER_USERTOKEN];
//    }
//    
//    [request setTimeoutInterval:TIMEOUTINTERVAL];
//    DDLogWarn(@"http post: %@\n heads: %@\n body: %@", uri, request.allHTTPHeaderFields, requestBody);
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        DDLogInfo(@"http post url: %@\n response: %@", operation.request.URL, operation.responseString);
//        NSError *err = nil;
//        id obj = [responseObject objectFromJSONDataWithError:&err];
//        if(err) {
//            if (errBlock) {
//                BXError *bxerr = [BXError errorWithNSError:err type:kBxErrorJson];
//                [self processError:bxerr withErrBlock:errBlock];
//            }
//        } else {
//            obj = [obj objectForKey:@"result"];
//            if (sucBlock) {
//                sucBlock(obj);
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        DDLogError(@"http post url: %@\n response: %@", operation.request.URL, operation.responseString);
//        BXError *bxError = [self transformError:error withOperation:operation];
//        [self processError:bxError withErrBlock:errBlock];
//    }];
//    
//    [self enqueueHTTPRequestOperation:operation];
//}
//
//#pragma mark - private methods
//
///**
// * 参见 https://github.com/baixing/haojing/wiki/Haojing-API-V0.2%28HTTP%29
// */
//- (NSString *)signApi:(NSString *)api WithBody:(NSString *)body
//{
//    body = body==nil? @"" : body;
//    NSString *token = [NSString stringWithFormat:@"%@%@%@%@", APIPREFIX, api, body, s_apiSecret];
//
//    NSString *md5 = [token md5];
//    return md5;
//}
//
//- (NSString *)signApi:(NSString *)api withData:(NSData *)data
//{
//    NSMutableData *param = [[NSMutableData alloc] init];
//    
//    [param appendData:[[NSString stringWithFormat:@"%@%@", APIPREFIX, api] dataUsingEncoding:NSUTF8StringEncoding]];
//    [param appendData:data];
//    [param appendData:[s_apiSecret dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    return [param md5];
//}

- (NSString *)generatePathWithApi:(NSString *)api
{
    NSMutableString *path = [[NSMutableString alloc] init];
    [path appendString:s_baseUrl];
    [path appendString:@"?api="];
    [path appendString:api];
    
    return path;
}

//- (NSString *)generateApiWithPath:(NSString *)path
//{
//    NSRange prefixRange = [path rangeOfString:APIPREFIX];
//    if (prefixRange.location != NSNotFound) {
//        
//        return [path stringByReplacingCharactersInRange:prefixRange withString:@""];
//    }
//    
//    return nil;
//}
//
//- (BXError *)transformError:(NSError *)error withOperation:(AFHTTPRequestOperation *)operation
//{
//    NSError *err = nil;
//    BXError *bxError = [BXError errorWithNSError:error type:kBXErrorNetwork];
//    NSDictionary *errDic = [operation.responseData objectFromJSONDataWithError:&err];
//    if (err) {
//        bxError.type = kBxErrorJson;
//        bxError.bxMessage = @"服务异常, 请稍后重试";
//    } else {
//        bxError.type = kBXErrorServer;
//        bxError.bxCode = [[errDic objectForKey:@"error"] intValue];
//        bxError.bxMessage = [[errDic objectForKey:@"message"] description].length ? [errDic objectForKey:@"message"] : @"服务异常，稍后重试";
//        NSDictionary* extDic = [errDic objectForKey:@"ext"];
//        if (extDic && [extDic isKindOfClass:[NSDictionary class]] &&(![extDic isEqual:[ NSNull null ]])) {
//            bxError.bxExt = [[BXErrorExt alloc] init];
//            bxError.bxExt.bangui = [extDic objectForKey:@"bangui"];
//            bxError.bxExt.rule = [extDic objectForKey:@"rule"];
//            bxError.bxExt.ruleInfo = [extDic objectForKey:@"ruleInfo"];
//            bxError.bxExt.action = [extDic objectForKey:@"action"];
//        }
//    }
//    return bxError;
//}
//
//- (void)processError:(BXError *)error withErrBlock:(ResponseError)errBlock
//{
//    if (errBlock) {
//        errBlock(error);
//        return;
//    }
//
//    NSString *msg = nil;
//    switch (error.type) {
//        case kBXErrorNetwork:
//            msg = @"网络异常，请稍候重试!";
//            break;
//        default:            //kBxErrorJson, kBXErrorServer这两种错误走这个，底层不知道server返回的不同bxcode的意义
//            msg = @"服务异常，请稍后重试!";
//            break;
//    }
//    [SVProgressHUD showErrorWithStatus:msg];
//}
//

@end
