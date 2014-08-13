//
//  BXStore.m
//  Baixing
//
//  Created by zengming on 12-12-1.
//
//

#import "Store.h"

@interface Store ()


@end

@implementation Store

static Store *_sharedInstance = nil;

+ (instancetype) sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance)
            _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
    
}


- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString*)getFilePathWithPath:(StorePath)storePath fileName:(NSString*)fileName {
    NSString *resultString = nil;
    switch (storePath) {
        case kStorePathCache: {
            resultString = [NSString stringWithFormat:@"%@/%@.plist", BXCachePath, fileName];
            break;
        }
        case kStorePathDocument: {
            resultString = [NSString stringWithFormat:@"%@/%@.plist", BXDocumentPath, fileName];
            break;
        }
        case kStorePathTmp: {
            resultString = [NSString stringWithFormat:@"%@/%@.plist",
                            NSTemporaryDirectory(), fileName];
            break;
        }
        default:
//            DDLogError(@"Saw God. Unknown StorePath.[%u]", storePath);
            break;
    }

    return resultString;
}

#pragma mark - egocache

- (id<NSCoding>)cacheForKey:(NSString*)key
{
    id result = nil;
    @try {
        result = [[EGOCache globalCache] objectForKey:key];
    }
    @catch (NSException *exception) {
        [[EGOCache globalCache] removeCacheForKey:key];
    }
    return result;
}

- (void)setCache:(id<NSCoding>)obj forKey:(NSString*)key
{
    return [[EGOCache globalCache] setObject:obj forKey:key];
}

- (void)setCache:(id<NSCoding>)obj forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    return [[EGOCache globalCache] setObject:obj forKey:key withTimeoutInterval:timeoutInterval];
}

- (void)removeCacheForKey:(NSString *)key
{
    [[EGOCache globalCache] removeCacheForKey:key];
}

// public actions

- (NSArray *)plistArrayForKey:(NSString *)key {
    return [self plistArrayForKey:key inPath:kStorePathCache];
}

- (BOOL)setPlistArray:(NSArray*)array forKey:(NSString*)key {
    return [self setPlistArray:array forKey:key inPath:kStorePathCache];
}

- (id)plistObjectForKey:(NSString *)key {
    return [self plistObjectForKey:key inPath:kStorePathCache];
}

- (BOOL)setPlistObject:(id)obj forKey:(NSString*)key {
    return [self setPlistObject:obj forKey:key inPath:kStorePathCache];
}

- (NSArray *)plistArrayForKey:(NSString *)key inPath:(StorePath)storePath {
    NSString *filePath = [self getFilePathWithPath:storePath fileName:key];
    return [NSArray arrayWithContentsOfFile:filePath];
}

- (BOOL)setPlistArray:(NSArray*)array forKey:(NSString*)key inPath:(StorePath)storePath {
    NSString *filePath = [self getFilePathWithPath:storePath fileName:key];
    BOOL suc = [array writeToFile:filePath atomically:YES];
//    if (!suc) {
//        DDLogError(@"plist save error:%@,%u,%@", key, storePath, array);
//    }
    return suc;
}

- (id)plistObjectForKey:(NSString *)key inPath:(StorePath)storePath {
    NSString *filePath = [self getFilePathWithPath:storePath fileName:key];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

- (BOOL)setPlistObject:(id)obj forKey:(NSString*)key inPath:(StorePath)storePath {
    NSString *filePath = [self getFilePathWithPath:storePath fileName:key];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    BOOL suc = [data writeToFile:filePath atomically:YES];
//    if (!suc) {
//        DDLogError(@"plist save error:%@,%u,%@", key, storePath, obj);
//    }
    return suc;
}

- (void)setUserDefaultObject:(id<NSCoding>)obj forKey:(NSString*)key {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [BXUserDefaults setObject:data forKey:key];
    [BXUserDefaults synchronize];
}

- (id)userDefaultObjectForKey:(NSString*)key {
    NSData *data = [BXUserDefaults objectForKey:key];
    if (data) {
        @try {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }@catch (NSException *e) {
            [BXUserDefaults removeObjectForKey:key];
            [BXUserDefaults synchronize];
            return nil;
        }
    }
    return nil;
}

- (int)counterForKey:(NSString *)key increase:(BOOL)increase
{
    NSNumber *number = [BXUserDefaults objectForKey:key];
    int n = [number intValue];
    if (increase) {
        number = [NSNumber numberWithInt:n+1];
        [BXUserDefaults setObject:number forKey:key];
        [BXUserDefaults synchronize];
        return n+1;
    } else {
        return n;
    }
}

- (void)clearAllData
{
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:BXDocumentPath error:&error]){
//        DDLogError(@"clear document path: %@", error);
    } else if(![[NSFileManager defaultManager] createDirectoryAtPath:BXDocumentPath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:&error]) {
//        DDLogError(@"create document dir : %@", error);
    }

    if (![[NSFileManager defaultManager] removeItemAtPath:BXCachePath error:&error]) {
//        DDLogError(@"clear cache path: %@", error);
    } else if (![[NSFileManager defaultManager] createDirectoryAtPath:BXCachePath
                                         withIntermediateDirectories:YES
                                                          attributes:nil
                                                               error:&error]) {
//        DDLogError(@"create cache dir : %@", error);
    }
    
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary]
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];

    [[EGOCache globalCache] clearCache];
}


+ (NSString *)getImagePath
{
    NSUUID *uuid = [NSUUID new];
    NSString *uuidString = [uuid UUIDString];
    
    return [BXCachePath stringByAppendingPathComponent:uuidString];
}

@end
