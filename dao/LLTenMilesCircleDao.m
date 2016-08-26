//
//  LLTenMilesCircleDao.m
//  iDleChat
//
//  Created by Reco on 16/3/14.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LLTenMilesCircleDao.h"

@implementation LLTenMilesCircleDao

-(void) createTenMilesCircle:(LLTenMilesCircle *)tmcModel
                      avatar:(UIImage *)image
                     success:(void (^)(LLTenMilesCircle *tmc))success
                        fail:(void (^)(NSError *error))fail;
{
    [[LLHTTPWriteOperationManager shareWriteManager]
            POSTWithURL:@""
            parameters:@{
                         @"tmcname":tmcModel.tmcname,
                         @"category":tmcModel.category,
                         @"tags":tmcModel.tags,
                         @"open":tmcModel.open,
                         @"city":tmcModel.city,
                         @"sign":tmcModel.sign,
                         @"address":tmcModel.address,
                         @"location":tmcModel.location,
                         @"business":tmcModel.business
                         }
                        images:@[image]
                        success:^(NSDictionary *responseObject)
    {
        DDLogInfo(@"Create TMC Info = %@",responseObject);
        NSDictionary *data = responseObject[@"data"];
        if ([data isDictionary])
        {
            LLTenMilesCircle *tmc = [responseObject[@"data"] modelFromDictionaryWithClassName:[LLTenMilesCircle class]];
            success(tmc);
        }
        else
        {

        }
        
    }
    failure:^(NSError *error)
    {
        fail(error);
    }];

}
/**
 * 密令生成
 */
- (void) tokenGenerate : (NSString*) tmcid
                success:(void (^)(NSString *token))success
                   fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:@""
     parameters:@{
                  @"tmcid":tmcid
                  }
     success:^(NSDictionary *respondObject , BOOL hasNext)
     {
         
         success(nil);
         
     }
     failure:^(NSError *error)
     {
         
         fail(error);
     }];
}
/**
 * @method:关注
 */
-(void) follow : (NSString*) tmcid
        success:(void (^)(LLTenMilesCircle *tmc))success
           fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:@""
     parameters:@{
                  @"tmcid":tmcid
                  }
     success:^(NSDictionary *respondObject , BOOL hasNext)
    {
         
        success(nil);
         
    }
    failure:^(NSError *error)
    {
         
         fail(error);
     }];
}
/**
 * @method:取消关注
 */
-(void) unfollow : (NSString*)  tmcid
          success:(void (^)(LLTenMilesCircle *tmc))success
             fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:@""
     parameters:@{
                  @"tmcid":tmcid
                  }
     success:^(NSDictionary *respondObject , BOOL hasNext)
     {
         
         success(nil);
         
     }
     failure:^(NSError *error)
     {
         
         fail(error);
     }];
}

/**
 * @method:更新图像
 */
-(void) updateAvator: (NSString*) tmcid
              avator:(UIImage*)image
             success:(void (^)(LLTenMilesCircle *tmc))success
                fail:(void (^)(NSError *error))fail
{
    [[LLHTTPRequestOperationManager shareManager]
     POSTWithURL:@""
     parameters:@{
                  @"tmcid":tmcid
                  }
     images:@[image]
     success:^(NSDictionary *result)
     {
        
        // 发个通知 让me里面的头像更新
        success(nil);
    }
    failure:^(NSError *error)
    {
        fail(error);
    }];
}
@end
