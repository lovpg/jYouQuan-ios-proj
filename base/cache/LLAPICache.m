//
//  LLAPICache.m
//  Olla
//
//  Created by Pat on 15/8/11.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLAPICache.h"
#import "NSDictionary+additions.h"

#define OLLA_API_VERSION 1

NSString* const LLAPICacheIgnoreParamsKey = @"LLAPICacheIgnoreParamsKey";

@interface LLAPICache () {
    NSFileManager *fileManager;
}
@property (nonatomic,strong) NSString *identifier;
@property (nonatomic, strong) NSString *apiPath;

@end

@implementation LLAPICache

DEF_SINGLETON(LLAPICache, sharedCache);

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        fileManager = [[NSFileManager alloc] init];
    }
    return self;
}

+ (void)setIdentifier:(NSString *)identifier {
    if (identifier.length == 0) {
        return;
    }
    
    if ([[LLAPICache sharedCache].identifier isEqualToString:identifier]) {
        return;
    }
    [LLAPICache sharedCache].identifier = identifier;
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *ollaAPIPath = [documentPath stringByAppendingPathComponent:@"OllaAPI"];
    if ([LLAppHelper isTestEnv]) {
        ollaAPIPath = [ollaAPIPath stringByAppendingString:@"TestEnv"];
    }
    ollaAPIPath = [ollaAPIPath stringByAppendingPathComponent:identifier];
    if (![[NSFileManager defaultManager] fileExistsAtPath:ollaAPIPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:ollaAPIPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [LLAPICache sharedCache].apiPath = ollaAPIPath;
}

- (void)setCacheArray:(NSArray *)array params:(NSDictionary *)params forURL:(NSString *)url {
    if (array.count == 0 || url.length == 0) {
        return;
    }
    
    if ([params isKindOfClass:[NSDictionary class]] && [params intForKey:@"pageId"] > 1) {
        // 只缓存第一页的数据
        return;
    }
    
    [[GCDQueue globalQueue] queueBlock:^{
        Class clazz = [array.firstObject class];
        NSAssert(![clazz isKindOfClass:[OllaModel class]], @"缓存对象必须继承 OllaModel!");
        
        NSString *ollaURL = [self convertURL:url params:params];
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            BaseModel *model = obj;
            model.ollaURL = ollaURL;
        }];
        // 删除老数据
        NSString *where = [NSString stringWithFormat:@"ollaURL='%@'",ollaURL];
        [clazz deleteWhere:where];
        [clazz saveModels:array];
    }];
    
}

- (void)setCacheData:(NSData *)data params:(NSDictionary *)params forURL:(NSString *)url {
    if (data.length == 0 || url.length == 0) {
        return;
    }
    
    if ([params isKindOfClass:[NSDictionary class]] && [params intForKey:@"pageId"] > 1) {
        // 只缓存第一页的数据
        return;
    }
    
    [[GCDQueue globalQueue] queueBlock:^{
        NSString *ollaURL = [self convertURL:url params:params];
        NSString *path = [self filePathWithOllaURL:ollaURL];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:NULL];
        }
        
        if ([fileManager createFileAtPath:path contents:data attributes:NULL]) {
            DDLogInfo(@"缓存 API 数据成功: %@", ollaURL);
        }
    }];

}

- (NSArray *)cacheArrayWithURL:(NSString *)url params:(NSDictionary *)params class:(Class)clazz {
    NSInteger size = 20;
    if ([params isKindOfClass:[NSDictionary class]]) {
        int paramSize = [params intForKey:@"size"];
        if (paramSize > 0) {
            size = paramSize;
        }
    }
    return [self cacheArrayWithURL:url params:params class:clazz orderBy:nil limit:size];
}

- (NSArray *)cacheArrayWithURL:(NSString *)url
                        params:(NSDictionary *)params
                         class:(Class)clazz
                       orderBy:(NSString *)orderBy
                         limit:(NSInteger)limit
{
    if (url.length == 0) {
        return nil;
    }
    
    NSAssert(![clazz isKindOfClass:[OllaModel class]], @"缓存对象必须继承 OllaModel!");
    
    NSString *ollaURL = [self convertURL:url params:params];
    NSString *path = [self filePathWithOllaURL:ollaURL];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        id value = data.jsonValue;
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *array = value;
            NSMutableArray *objArray = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                id obj = [dict modelFromDictionaryWithClassName:clazz];
                if (obj) {
                    [objArray addObject:obj];
                }
                if (objArray.count >= limit) {
                    break;
                }
            }
            return objArray;
        }
    }
    
    return nil;
}

- (NSString *)convertURL:(NSString *)url params:(NSDictionary *)params {
    if (!params || params.count == 0 || [params boolForKey:LLAPICacheIgnoreParamsKey]) {
        return url;
    }
    NSArray *keys = [params.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *resultURL = [NSMutableString string];
    [resultURL appendString:url];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj;
        NSString *value = params[key];
        NSString *saperator = (idx == 0) ? @"?" : @"&";
        [resultURL appendFormat:@"%@%@=%@", saperator, key, value];
    }];
    return resultURL;
}

- (NSString *)filePathWithOllaURL:(NSString *)url {
    return [self.apiPath stringByAppendingPathComponent:url.MD5Encode];
}

@end
