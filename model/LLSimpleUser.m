//
//  LLSimpleUser.m
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLSimpleUser.h"

@implementation LLSimpleUser

- (NSString *)uniqueId {
    return self.uid;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    
    if (self = [super init])
    {
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.region = [aDecoder decodeObjectForKey:@"country"];
        self.sign = [aDecoder decodeObjectForKey:@"sign"];
        self.distanceText = [aDecoder decodeObjectForKey:@"distanceText"];
        self.location = [aDecoder decodeObjectForKey:@"location"];
        
    }
    
    return self;
}

- (NSString *)easeUserName {
    if ([self.uid isEqualToString:@"10000"]) {
        return self.uid;
    }
    NSString *easeUsername = [NSString stringWithFormat:@"%@", self.uid];
    return easeUsername;
}

- (NSString *)easePassword {
    NSString *easePassword = [self.nickname MD5Encode];
    return easePassword;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.region forKey:@"country"];
    
    [aCoder encodeObject:self.sign forKey:@"sign"];
    
    [aCoder encodeObject:self.distanceText forKey:@"distanceText"];
    
    [aCoder encodeObject:self.location forKey:@"silocationgn"];

    
}


- (void)setUid:(NSString *)uid{
    if ([uid isNumber]) {
        uid = [(NSNumber *)uid stringValue];
    }
    _uid = uid;
}


//+ (NSDictionary *)modelMap{
//    return @{@"region":@"country"};
//}

+ (LLSimpleUser *)random{

    LLSimpleUser *user = [[LLSimpleUser alloc] init];
    
//    user.uid = [];
//    user.nickname = [];// 构造用户信息
//    user.gender = [];
//    user.country = [];
//    user.avatar = [];

    return user;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"simple user %@", self.userName];
}



@end
