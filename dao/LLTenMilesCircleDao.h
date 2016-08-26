//
//  LLTenMilesCircleDao.h
//  iDleChat
//
//  Created by Reco on 16/3/14.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLTenMilesCircle.h"

@interface LLTenMilesCircleDao : NSObject

- (void)createTenMilesCircle:(LLTenMilesCircle*)tmcModel
                      avatar:(UIImage *)image
                     success:(void (^)(LLTenMilesCircle *tmc))success
                        fail:(void (^)(NSError *error))fail;

/**
 * @method:关注
 */
-(void) follow :  (NSString*) tmcid
        success:(void (^)(LLTenMilesCircle *tmc))success
           fail:(void (^)(NSError *error))fail;
/**
 * @method:取消关注
 */
-(void) unfollow :  (NSString*) tmcid
          success:(void (^)(LLTenMilesCircle *tmc))success
             fail:(void (^)(NSError *error))fail;

/**
 * @method:更新图像
 */
-(void) updateAvator: (NSString*) tmcid
              avator:(UIImage*)image
             success:(void (^)(LLTenMilesCircle *tmc))success
                fail:(void (^)(NSError *error))fail;

/**
 * 密令生成
 */
- (void) tokenGenerate : (NSString*) tmcid
                success:(void (^)(NSString *token))success
                   fail:(void (^)(NSError *error))fail;

@end
