//
//  LLMeDataSource.m
//  Olla
//
//  Created by null on 14-10-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLMeDAO.h"

@implementation LLMeDAO

//本地没有就取取网络
- (LLUser *)get{
    
    LLUser *user = nil;
    NSDictionary *userInfo = [[LLPreference shareInstance] valueForKey:@"userInfo"];
    if (userInfo && [userInfo isDictionary])
    {
        user =  [userInfo modelFromDictionaryWithClassName:[LLUser class]];
        return user;
    }
    
    //老地方(2.1版)去拿下数据看看
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"userInfo"]];
    if (userDict)
    {
        user = [userDict modelFromDictionaryWithClassName:[LLUser class]];
        [self set:user];
        return user;
    }
    
    return nil;
    
}

- (void)set:(LLUser *)user
{
    
    //要去NSNull
    [[LLPreference shareInstance] setValue:[[user dictionaryRepresentation] propertyListDictionary] forKey:@"userInfo"];
    [[LLPreference shareInstance] synchronize];
}


- (NSString *)whatsupAudioRecordPath{
    
    NSString *uid = [[LLPreference shareInstance] uid];
    NSString *audioName = [NSString stringWithFormat:@"whatsup_%@.wav",uid];
    NSString *audioPath = [[OllaSandBox libCachePath] stringByAppendingPathComponent:audioName];
    return audioPath;
    
}

- (NSString *)whatsupTempAudioRecordPath{
    NSString *uid = [[LLPreference shareInstance] uid];
    NSString *audioName = [NSString stringWithFormat:@"whatsup_%@.tmp.wav",uid];
    NSString *audioPath = [[OllaSandBox libCachePath] stringByAppendingPathComponent:audioName];
    return audioPath;
}


- (NSString *)whatsupAudioPath
{
    
    NSString *local = [self whatsupAudioRecordPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:local]) {
        return local;
    }
    
    return [self get].voice;
}


- (void)updateValue:(NSString *)value forKey:(NSString *)key
{
    LLUser *me = [self get];
    @try
    {
        [me setValue:value forKey:key];
    }
    @catch (NSException *exception)
    {
        DDLogWarn(@"更新用户信息异常 [me setValue:%@ forKey:%@] ",value,key);
    }
    @finally
    {
       [self set:me];
    }
    
}

- (void)fillSuccess:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    LLUser *userInfo = [self get];
    if (!userInfo) {
        fail(nil);
        return;
    }
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_User
     parameters:@{@"gender":userInfo.gender,
                  @"nickname":userInfo.nickname,
                  @"email":userInfo.region,
                  @"learning":userInfo.learning,
                  @"sign":userInfo.sign
                  }
     success:^(NSDictionary *respondObject , BOOL hasNext){
         success(respondObject);
         
     } failure:^(NSError *error){
         fail(error);
     }];
}

- (void)updateUserName:(NSString *)username success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Name
     parameters:@{@"nickname":username}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:username forKey:@"nickname"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
}

- (void)updateEquipType:(NSString *)equipType
                success:(void (^)(NSDictionary *userInfo))success
                   fail:(void (^)(NSError *error))fail
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Equip_Type
     parameters:@{@"equipType":equipType}
     success:^(NSDictionary *respondObject , BOOL hasNext)
    {
         
         [self updateValue:equipType forKey:@"equipType"];
         success(respondObject);
         
     }
     failure:^(NSError *error)
    {
         
         fail(error);
     }];
    
}

- (void)updateGender:(NSString *)gender success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Gender
     parameters:@{@"gender":gender}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:gender forKey:@"gender"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
    
}
- (void)hide:(NSString *)hide
     success:(void (^)(NSDictionary *userInfo))success
        fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:@""
     parameters:nil
     success:^(NSDictionary *respondObject , BOOL hasNext)
    {
         
         [self updateValue:@"1" forKey:@"hide"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
}

- (void)unhide:(NSString *)hide
       success:(void (^)(NSDictionary *userInfo))success
          fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:@""
     parameters:nil
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:@"0" forKey:@"hide"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
}
// updateBirth

- (void)updateBirth:(NSString *)birth success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail {
    
    
    
    [[LLHTTPRequestOperationManager shareManager]
     
     GETWithURL:Olla_API_Edit_Birth
     
     parameters:@{@"birth":birth}
     
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         
         
         [self updateValue:birth forKey:@"birth"];
         
         success(respondObject);
         
         
         
     } failure:^(NSError *error){
         
         
         
         fail(error);
         
     }];
    
}

- (void)updateEmail:(NSString *)email success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail {
    
    
    
    [[LLHTTPRequestOperationManager shareManager]
     
     GETWithURL:Olla_API_Edit_Email
     
     parameters:@{@"email":email}
     
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:email forKey:@"email"];
         success(respondObject);
     } failure:^(NSError *error){

         fail(error);
     }];
    
}

- (void)updateRegion:(NSString *)region success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Region
     parameters:@{@"region":region}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:region forKey:@"region"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];

}

- (void)updateWhatsup:(NSString *)whatsup success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Whatsup
     parameters:@{@"sign":whatsup}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:whatsup forKey:@"sign"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];

}

- (void)updateSpeaking:(NSString *)speaking success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Speaking
     parameters:@{@"speaking":speaking}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:speaking forKey:@"speaking"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
    
}


- (void)updateLearning:(NSString *)learning success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Learning
     parameters:@{@"learning":learning}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:learning forKey:@"learning"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
}


- (void)updateInterests:(NSString *)interests success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{

    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Edit_Interests
     parameters:@{@"interests":interests}
     success:^(NSDictionary *respondObject , BOOL hasNext){
         
         [self updateValue:interests forKey:@"interests"];
         success(respondObject);
         
     } failure:^(NSError *error){
         
         fail(error);
     }];
    
}


///跟新头像语音介绍等////////////////////////////////

- (void)updateAvatar:(UIImage *)image success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    [[LLHTTPRequestOperationManager shareManager] POSTWithURL:Olla_API_Edit_Headphoto parameters:nil images:@[image] success:^(NSDictionary *result) {
        [self updateValue:result[@"data"] forKey:@"avatar"];
        
        // 发个通知 让me里面的头像更新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaHeadPhotoChangeNotification" object:nil userInfo:nil];
        
        success(result);
    } failure:^(NSError *error) {
        fail(error);
    }];
}

- (void)updateCover:(UIImage *)cover  success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    [[LLHTTPRequestOperationManager shareManager] POSTWithURL:Olla_API_Edit_Cover parameters:nil images:@[cover] success:^(NSDictionary *responseObject) {
        DDLogInfo(@"update cover ok %@",responseObject);
        [self updateValue:responseObject[@"data"] forKey:@"cover"];
        // 发个通知 让me里面的cover更新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaCoverPhotoChangeNotification" object:nil userInfo:@{@"cover":responseObject[@"data"]}];
    } failure:^(NSError *error) {
        DDLogError(@"update cover  %@",error);
        fail(error);
    }];
    
}


- (void)updateWhatsupAudio:(NSString *)filePath success:(void (^)(NSDictionary *userInfo))success fail:(void (^)(NSError *error))fail{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[LLHTTPRequestOperationManager shareManager] POSTWithURL:Olla_API_Edit_Audio parameters:nil data:[NSData dataWithContentsOfFile:filePath] success:^(NSDictionary *respond){
        DDLogInfo(@"upload ok:%@",respond);
        [self updateValue:respond[@"data"] forKey:@"voice"];
        success(respond);
   
    } failure:^(NSError *error){
        
        DDLogError(@"whatup语音 upload error:%@",error);
        fail(error);
    }];

}

@end


