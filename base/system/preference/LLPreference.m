//
//  OllaPreference.m
//  Olla
//
//  Created by null on 14-10-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLPreference.h"

@interface LLPreference ()
{
    NSString *_currentPath;
    NSString *_fullNamespace;
}

@end

@implementation LLPreference

+ (LLPreference *)shareInstance{
    
    static LLPreference *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLPreference alloc] init];
    });
    
    return instance;
}

- (instancetype)init{
    return [self initWithNamespace:@"com.between.olla"];
}

- (id)initWithNamespace:(NSString *)fullNamespace
{
    self = [super init];
    if (self) {
        _fullNamespace = fullNamespace;
    }
    return self;
}

- (LLUser *)user
{
    NSDictionary *userInfo = [self valueForKey:@"userInfo"];
    if (userInfo && [userInfo isDictionary]) {
        LLUser *user = [userInfo modelFromDictionaryWithClassName:[LLUser class]];
        return user;
    }
    return nil;
}

- (void)setUid:(NSString *)uid
{
    if (_uid != uid) {
     
        _uid = uid;
        if ([uid length]==0)
        {
            DDLogWarn(@"uid设置为空？");
            return;
        }
 
        NSString *path = [[OllaSandBox libPrefPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@.plist",_fullNamespace ,uid]];
        if (![OllaSandBox createFileIfNotExist:path])
        {
            DDLogError(@"创建文件失败:path=%@",path);
            return;
        }
        _userInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        if(!_userInfo)
        {
            _userInfo = [NSMutableDictionary dictionary];
        }
        
        _currentPath = path;
    }
}

- (NSString *)easeUserName
{
    if (!self.uid)
    {
        return nil;
    }
    NSString *easeUserName = [NSString stringWithFormat:@"%@", self.uid];
    return easeUserName;
}

- (NSString *)easePassword
{
    if (!self.user.userName) {
        return nil;
    }
    NSString *easePassword = [self.user.userName MD5Encode];
    return easePassword;
}

- (id)valueForKey:(NSString *)defaultName
{
    if ([self.uid length]==0)
    {
        DDLogError(@"设置uid先");
        return nil;
    }
    DDLogInfo(@"-valueForKey preference %@.%@.plist",_fullNamespace, self.uid);
    return [_userInfo valueForKey:defaultName];
}

- (void)setValue:(id)value forKey:(NSString *)defaultName{
    if ([self.uid length]==0) {
        DDLogError(@"设置uid先");
        return;
    }
    DDLogInfo(@"-setValue:forKey: preference %@.%@.plist",_fullNamespace, self.uid);
    [_userInfo setValue:value forKey:defaultName];
    [self synchronize];
}

- (void)removeValueForKey:(NSString *)defaultName{
    if ([self.uid length]==0) {
        DDLogError(@"设置uid先");
        return;
    }
    [_userInfo removeObjectForKey:defaultName];
    [self synchronize];
}

- (BOOL)synchronize{

   return [_userInfo writeToFile:_currentPath atomically:YES];
}

@end


