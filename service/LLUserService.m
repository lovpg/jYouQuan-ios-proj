//
//  LLUserService.m
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLUserService.h"

@implementation LLUserService

- (instancetype)init{

    if (self=[super init]) {
        userDAO = [[LLUserDAO alloc] init];
        meDAO = [[LLMeDAO alloc] init];
    }
    return self;
}

- (LLUser *)getMe
{
    return [meDAO get];
}

- (void)get:(NSString *)uid
    success:(void (^)(LLUser *user))success
       fail:(void (^)(NSError *error))fail
{
    [userDAO get:uid success:success fail:fail];
}


- (void)set:(LLUser *)user{
    [meDAO set:user];
}

- (void)updateValue:(NSString *)value forKey:(NSString *)key{
    [meDAO updateValue:value forKey:key];
}

// whatsup录音存储路径
- (NSString *)whatsupAudioRecordPath{
    return [meDAO whatsupAudioRecordPath];
}
// whatsup录音临时存储路径
- (NSString *)whatsupTempAudioRecordPath{
    return [meDAO whatsupTempAudioRecordPath];
}

// 如果没有本地的，就看有没有网络的
- (NSString *)whatsupAudioPath{
    return [meDAO whatsupAudioPath];
}

- (void)fillSuccess:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [meDAO fillSuccess:success fail:fail];
}

/**
 *  更新头像信息
 *  @param avatar  头像image
 *  @param path    upload url
 *  @param success
 *  @param fail
 */
- (void)updateAvatar:(UIImage *)avatar  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateAvatar:avatar success:success fail:fail];
}

- (void)updateCover:(UIImage *)cover  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateCover:cover success:success fail:fail];
}

/**
 *  跟新用户名
 *
 *  @param username
 *  @param pathURL
 *  @param success
 *  @param fail
 */
- (void)updateUserName:(NSString *)username
               success:(void (^)(NSDictionary *userInfo))success
                  fail:(void (^)(NSError *error))fail{
    [meDAO updateUserName:username success:success fail:fail];
}

- (void)updateEquipType:(NSString *)equipType
             success:(void (^)(NSDictionary *userInfo))success
                fail:(void (^)(NSError *error))fail
{
    [meDAO updateEquipType:equipType success:success fail:fail];
}

- (void)updateGender:(NSString *)gender  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateGender:gender success:success fail:fail];
}

- (void)hide:(NSString *)hide
             success:(void (^)(NSDictionary *userInfo))success
                fail:(void (^)(NSError *error))fail
{
    [meDAO hide:hide success:success fail:fail];
}

- (void)unhide:(NSString *)hide
       success:(void (^)(NSDictionary *userInfo))success
          fail:(void (^)(NSError *error))fail
{
   [meDAO unhide:hide success:success fail:fail];
}

- (void)updateBirth:(NSString *)birth  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateBirth:birth success:success fail:fail];
    
}

- (void)updateEmail:(NSString *)email  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateEmail:email success:success fail:fail];
    
}

- (void)updateRegion:(NSString *)region  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateRegion:region success:success fail:fail];
}

- (void)updateWhatsup:(NSString *)whatsup  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateWhatsup:whatsup success:success fail:fail];
}


- (void)updateWhatsupAudio:(NSString *)filePath  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateWhatsupAudio:filePath success:success fail:fail];
}


//
- (void)updateSpeaking:(NSString *)speaking  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateSpeaking:speaking success:success fail:fail];
}


- (void)updateLearning:(NSString *)learning  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateLearning:learning success:success fail:fail];
}


- (void)updateInterests:(NSString *)interests  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    [meDAO updateInterests:interests success:success fail:fail];
}

- (void)unfollow:(LLSimpleUser *)user {
    
    //    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    //    hud.labelText = @"Please wait...";
    //    [self.view addSubview:hud];
    //    [hud show:YES];
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Unfollow
     parameters:@{@"uid":user.uid}
     success:^(id datas,BOOL hasNext)
     {
         
         __strong typeof (self)strongSelf = weakSelf;
         
         //         [strongSelf.url.queryValue setValue:@0 forKey:@"follow"];
         //
         //         [hud removeFromSuperview];
         
         //TODO: follow 后就要在 myfriends列表消失
         //         LLSimpleUser *user = [[self.url queryValue] modelFromDictionaryWithClassName:[LLSimpleUser class]];
         //         [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaUnfollowSomeOneNotification" object:user userInfo:[self.url queryValue]];
         
         NSString *message = @"已取消关注.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
         
     } failure:^(NSError *error){
         //         [hud removeFromSuperview];
         //         //TODO: 添加关注失败
         //         NSString *message = @"Unfollow failed.";
         //         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         //         self.fansCell.followStateLabel.text = @"Followed";
     }];
}

- (void)follow:(LLSimpleUser *)user {
    
    //   MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    //    hud.labelText = @"Please wait...";
    //    [self.view addSubview:hud];
    //     [hud show:YES];
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Follow
     parameters:@{@"uid":user.uid} // @"url.queryValue.uid"
     success:^(id datas,BOOL hasNext){
         
         __strong typeof(self)strongSelf = weakSelf;
         //
         //         [strongSelf.url.queryValue setValue:@1 forKey:@"follow"];
         //
         //         [hud removeFromSuperview];
         
         //TODO: follow 后就要在 myfriends列表出现了
         //         LLSimpleUser *user = [[strongSelf.url queryValue] modelFromDictionaryWithClassName:[LLSimpleUser class]];
         //         [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaFollowSomeOneNotification" object:user userInfo:[strongSelf.url queryValue]];
         
         NSString *message = @"关注成功.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     } failure:^(NSError *error){
         DDLogError(@"添加关注失败：%@",error);
         //[hud removeFromSuperview];
         
         //         NSString *message = @"Follow failed.";
         //         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         //         self.fansCell.followStateLabel.text = @"+ Follow";
     }];
}
@end


