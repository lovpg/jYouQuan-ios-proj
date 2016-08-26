//
//  LLUserService.h
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLUserDAO.h"
#import "LLMeDAO.h"
#import "LLSimpleUser.h"

@interface LLUserService : NSObject{
    LLUserDAO *userDAO;
    LLMeDAO *meDAO;
}


- (LLUser *)getMe;
- (void)set:(LLUser *)user;
- (void)updateValue:(NSString *)value forKey:(NSString *)key;

- (void)get:(NSString *)uid success:(void (^)(LLUser *user))success fail:(void (^)(NSError *error))fail;

// whatsup录音存储路径
- (NSString *)whatsupAudioRecordPath;

// whatsup录音临时存储路径
- (NSString *)whatsupTempAudioRecordPath;

// 如果没有本地的，就看有没有网络的
- (NSString *)whatsupAudioPath;

/**
 *  补充用户资料
 *
 *  @param success
 *  @param fail
 */
- (void)fillSuccess:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


/**
 *  更新头像信息
 *  @param avatar  头像image
 *  @param path    upload url
 *  @param success
 *  @param fail
 */
- (void)updateAvatar:(UIImage *)avatar  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

/**
 *  更新背景封面
 *
 *  @param cover
 *  @param success
 *  @param fail
 */
- (void)updateCover:(UIImage *)cover  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


/**
 *  跟新用户名
 *
 *  @param username
 *  @param pathURL
 *  @param success
 *  @param fail
 */
- (void)updateUserName:(NSString *)username  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)updateBirth:(NSString *)birth  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)updateEmail:(NSString *)email  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)updateGender:(NSString *)gender  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)hide:(NSString *)hide  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)unhide:(NSString *)hide  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)updateRegion:(NSString *)region  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)updateWhatsup:(NSString *)whatsup  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


- (void)updateWhatsupAudio:(NSString *)filePath  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


//
- (void)updateSpeaking:(NSString *)speaking  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


- (void)updateLearning:(NSString *)learning  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;


- (void)updateInterests:(NSString *)interests  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail;

- (void)follow:(LLSimpleUser *)user;

- (void)unfollow:(LLSimpleUser *)user;

@end
