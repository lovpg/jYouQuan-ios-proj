//
//  OllaPreference.h
//  Olla
//
//  Created by null on 14-10-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLUser.h"
@interface LLPreference : NSObject

@property(nonatomic,strong) NSString *uid;
@property(nonatomic,strong) NSMutableDictionary *userInfo;

+ (LLPreference *)shareInstance;
- (LLUser *)user;
- (id)initWithNamespace:(NSString *)fullNamespace;
- (NSString *)easeUserName;
- (NSString *)easePassword;


- (id)valueForKey:(NSString *)defaultName;
- (void)setValue:(id)value forKey:(NSString *)defaultName;
- (void)removeValueForKey:(NSString *)defaultName;

- (BOOL)synchronize;



@end
