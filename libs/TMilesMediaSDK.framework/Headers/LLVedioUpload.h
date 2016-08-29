//
//  LLVedioUpload.h
//  TMilesMediaSDK
//
//  Created by Reco on 16/8/29.
//  Copyright © 2016年 广州市拾里信息科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLVedioUpload : NSObject


- (void) upload : (NSString *)filename
           data : (NSData *)data;

@end
