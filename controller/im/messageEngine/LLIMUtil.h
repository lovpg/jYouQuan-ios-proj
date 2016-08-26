//
//  LLIMUtil.h
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMessage.h"

@interface LLIMUtil : NSObject

+ (NSString *)messageIDGenerator;

//图片的存储路径
+ (NSString *)imageStorePathWithUid:(NSString *)uid ouid:(NSString *)ouid;
+ (NSString *)imagePathWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid;
+ (NSString *)thumbImagePathWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid;
+ (NSString *)imageNameWithMsgid:(NSString *)msgid;
+ (NSString *)thumbImageNameWithMsgid:(NSString *)msgid;

// 语音
+ (NSString *)voiceWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid;
+ (NSString *)voiceStorePathWithUid:(NSString *)uid ouid:(NSString *)ouid;
+ (NSString *)voiceStoreNameWithMsgid:(NSString *)msgid;

//是否需要时间戳
+ (LLMessage *)timestampMessageWithLastMessage:(LLMessage *)lastMessage currentMessage:(LLMessage *)currentMessage;
+ (LLMessage *)timestampMessageWithLastMessage:(LLMessage *)message __deprecated_msg("method deprecated,use `timestampMessageWithLastMessage:currentMessage:` instead");

//resizingImage
+ (UIImage *)leftResizingBackgroundImage;
+ (UIImage *)rightResizingBackgroundImage;

+ (CGSize)imageMessageSizeWithOrignialImage:(UIImage *)image;
+ (UIImage *)thumbImageWithOrignialImage:(UIImage *)image;

+ (NSString *)imThumbImageURLWithURLString:(NSString *)key width:(CGFloat)width height:(CGFloat)height;

@end
