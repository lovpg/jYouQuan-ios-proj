//
//  LLUser.m
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUser.h"

@implementation LLUser

- (NSString *)uniqueId {
    return self.uid;
}

- (id)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        self.uid =  [aDecoder decodeObjectForKey:@"uid"];
        self.avatar =  [aDecoder decodeObjectForKey:@"avatar"];
        self.userName =  [aDecoder decodeObjectForKey:@"username"];
        self.nickname =  [aDecoder decodeObjectForKey:@"nickname"];
        self.gender =  [aDecoder decodeObjectForKey:@"gender"];
        self.region =  [aDecoder decodeObjectForKey:@"region"];
        self.speaking =  [aDecoder decodeObjectForKey:@"speaking"];
        self.learning =  [aDecoder decodeObjectForKey:@"learning"];
        self.interests =  [aDecoder decodeObjectForKey:@"interests"];
    }

    return self;
}

- (NSString *)easeUserName {
    if ([self.uid isEqualToString:@"10000"]) {
        return self.uid;
    }
    NSString *easeUsername = [NSString stringWithFormat:@"olla00%@", self.uid];
    return easeUsername;
}

- (NSString *)easePassword {
    NSString *easePassword = [self.userName MD5Encode];
    return easePassword;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.userName forKey:@"username"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.region forKey:@"region"];

}

- (void)setUid:(NSString *)uid{
    if ([uid isNumber]) {
        uid = [(NSNumber *)uid stringValue];
    }
    _uid = uid;
}



- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"native"]) {
        return [self setValue:value forKey:@"speaking"];
    }
    DDLogError(@"setValue: forUndefinedKey: for class:%@ key:%@",self,key);
}

- (id)valueForUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"native"]) {
        return [self valueForKey:@"speaking"];
    }
    DDLogError(@"valueForUndefinedKey: for class:%@ key:%@",self,key);
    return nil;
}

+ (NSArray *)myFriends {
    NSString *where = [NSString stringWithFormat:@"ollaURL='%@'",Olla_API_Friends_List];
    NSArray *friends = [LLUser selectWhere:where groupBy:nil orderBy:nil limit:nil];
    
    // 过滤重复
    NSMutableArray *uids = [NSMutableArray array];
    NSMutableArray *filterFriends = [NSMutableArray array];
    
    [friends enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LLUser *user = obj;
        if (![uids containsObject:user.uid]) {
            [filterFriends addObject:user];
            [uids addObject:user.uid];
        }
    }];
    
    return filterFriends;
}


//获得所有的 fans
+(NSArray*)myFans{
    
    NSString *where = [NSString stringWithFormat:@"ollaURL='%@'",Olla_API_Fans_List];
    NSArray *fans = [LLUser selectWhere:where groupBy:nil orderBy:nil limit:nil];
    
    // 过滤重复
    NSMutableArray *uids = [NSMutableArray array];
    NSMutableArray *filterFriends = [NSMutableArray array];
    
    [fans enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LLUser *user = obj;
        if (![uids containsObject:user.uid]) {
            [filterFriends addObject:user];
            [uids addObject:user.uid];
        }
    }];
    
    return filterFriends;
}
@end
