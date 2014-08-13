//
//  BXStore.h
//  Baixing
//
//  Created by zengming on 12-12-1.
//
//  对 BXConfig 的方式不满意，包含了 ad、登录、更新的逻辑
//  bxstore， 只做一件事：持久存储，与 EGOCache, 数据库配合使用
//  * 轻量级数据存储用 BXUserDefaults, (BXStore 只封装 userDefaultObject 读写)
//  * 大量数据用 plist 文件存储, by defailt in Cache path, can use Document path
//  * 还有 user、city 等公用数据读写 TODO: move it

#import <UIKit/UIImage.h>
#import <EGOCache.h>

@class Store;

#define BCCache             [Store sharedInstance]

#define BXUserDefaults      [NSUserDefaults standardUserDefaults]    //for short code

#define BXDocumentPath      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, \
                                                        NSUserDomainMask, \
                                                        YES \
                                                        )[0]

#define BXLibaryPath        NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, \
                                                        NSUserDomainMask, \
                                                        YES \
                                                        )[0]

#define BXCachePath         NSSearchPathForDirectoriesInDomains(NSCachesDirectory, \
                                                        NSUserDomainMask, \
                                                        YES \
                                                        )[0]


typedef enum {
    kStorePathDocument,
    kStorePathCache,
    kStorePathTmp
} StorePath;


@interface Store : NSObject

+ (instancetype) sharedInstance;

/**
 *  调用 EGOCache 处理缓存，自动捕获并处理异常
 *
 *  @param obj
 *  @param key
 *
 *  @return
 */
- (id<NSCoding>)cacheForKey:(NSString*)key;
- (void)removeCacheForKey:(NSString *)key;
- (void)setCache:(id<NSCoding>)obj forKey:(NSString*)key;
- (void)setCache:(id<NSCoding>)obj forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;


/**
 *  plist 存储，可指定存储到不同路径
 *
 *  @param array
 *  @param key
 *
 *  @return
 */
- (BOOL)setPlistArray:(NSArray*)array forKey:(NSString*)key;
- (NSArray *)plistArrayForKey:(NSString *)key;

- (BOOL)setPlistObject:(id)obj forKey:(NSString*)key;
- (id)plistObjectForKey:(NSString *)key;

- (BOOL)setPlistArray:(NSArray*)array forKey:(NSString*)key inPath:(StorePath)storePath;
- (NSArray *)plistArrayForKey:(NSString *)key inPath:(StorePath)storePath;

- (id)plistObjectForKey:(NSString *)key inPath:(StorePath)storePath;
- (BOOL)setPlistObject:(id)obj forKey:(NSString*)key inPath:(StorePath)storePath;


/**
 *  UserDefault 存储
 *
 *  @param obj
 *  @param key
 */
- (void)setUserDefaultObject:(id<NSCoding>)obj forKey:(NSString*)key;
- (id)userDefaultObjectForKey:(NSString*)key;


- (int)counterForKey:(NSString*)key increase:(BOOL)increase;

/**
 *
 */
- (void)clearAllData;

+ (NSString *)getImagePath;

@end
