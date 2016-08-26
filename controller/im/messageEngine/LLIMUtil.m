//
//  LLIMUtil.m
//  Olla
//
//  Created by null on 14-9-6.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMUtil.h"

@implementation LLIMUtil

+ (NSString *)messageIDGenerator{
    
    return [[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
}


// 图片存储 /// //////////////////////////////
+ (NSString *)imagePathWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid;{

    NSString *path = [LLIMUtil imageStorePathWithUid:uid ouid:ouid];
    NSString *name = [LLIMUtil imageNameWithMsgid:msgid];
    return [path stringByAppendingPathComponent:name];
}


+ (NSString *)thumbImagePathWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid;{
    
    NSString *path = [LLIMUtil imageStorePathWithUid:uid ouid:ouid];
    NSString *thumb = [LLIMUtil thumbImageNameWithMsgid:msgid];
    return [path stringByAppendingPathComponent:thumb];
    
}


+ (NSString *)imageNameWithMsgid:(NSString *)msgid;{
    return [NSString stringWithFormat:@"%@.pic",msgid];
}

+ (NSString *)thumbImageNameWithMsgid:(NSString *)msgid;{//
    return [NSString stringWithFormat:@"%@.pic.thumb",msgid];
}

+ (NSString *)imageStorePathWithUid:(NSString *)uid ouid:(NSString *)ouid{
    
    NSString *imageStorePath = nil;

    imageStorePath = [[[OllaSandBox documentPath] stringByAppendingPathComponent:[uid MD5Encode]] stringByAppendingPathComponent:@"img"];
    if ([OllaSandBox createPathIfNotExist:imageStorePath]) {
        imageStorePath = [imageStorePath stringByAppendingPathComponent:[ouid MD5Encode]];
        if ([OllaSandBox createPathIfNotExist:imageStorePath]) {
              return imageStorePath;//md5(myuid)/img/md5(fuid)/md5(timestamp).pic
        }else{
                DDLogError(@"file ERROR: create directory fail %@",imageStorePath);
                return nil;
        }
    }else{
            DDLogError(@"file ERROR: create directory fail %@",imageStorePath);
            return nil;
   }
   
    
    return imageStorePath;
    
}



// 语音存储 /// //////////////////////////////

+ (NSString *)voiceStorePathWithUid:(NSString *)uid ouid:(NSString *)ouid{
    
    NSString *_voiceStorePath = nil;
    if (!_voiceStorePath) {
        _voiceStorePath = [[[OllaSandBox documentPath] stringByAppendingPathComponent:[uid MD5Encode]] stringByAppendingPathComponent:@"audio"];
        if ([OllaSandBox createPathIfNotExist:_voiceStorePath]) {
            _voiceStorePath = [_voiceStorePath stringByAppendingPathComponent:[ouid MD5Encode]];
            if ([OllaSandBox createPathIfNotExist:_voiceStorePath]) {
                return _voiceStorePath;//md5(myuid)/audio/md5(fuid)/md5(timestamp).pic
            }else{
                DDLogError(@"file ERROR: create directory fail %@",_voiceStorePath);
                return nil;
            }
        }else{
            DDLogError(@"file ERROR: create directory fail %@",_voiceStorePath);
            return nil;
        }
    }
    
    return _voiceStorePath;
    
  
}

// 不指定小数位，默认是小数点后6位，
+ (NSString *)voiceStoreNameWithMsgid:(NSString *)msgid{
    return [NSString stringWithFormat:@"%@.aud",msgid];
}

+ (NSString *)voiceWithUid:(NSString *)uid ouid:(NSString *)ouid msgid:(NSString *)msgid{

    NSString *path = [LLIMUtil voiceStorePathWithUid:uid ouid:ouid];
    NSString *name = [LLIMUtil voiceStoreNameWithMsgid:msgid];
    
    return [path stringByAppendingPathComponent:name];

}


// 是否需要时间戳消息
+ (LLMessage *)timestampMessageWithLastMessage:(LLMessage *)message{
    
    double now = [[NSDate date] timeIntervalSince1970]*1000;
    if (message) {
        double lastTime = message.timestamp;
        if ((now - lastTime)/1000 < 1*60 ) {//5分钟
            return nil;
        }
    }

    LLMessage *timeMessage = [[LLMessage alloc] init];
    timeMessage.msgid = [LLIMUtil messageIDGenerator];
    timeMessage.type = OllaMessageTypeTimestamp;
    timeMessage.timestamp = now;
    return timeMessage;

}

+ (LLMessage *)timestampMessageWithLastMessage:(LLMessage *)lastMessage currentMessage:(LLMessage *)currentMessage{

    double lastTime = lastMessage.timestamp;
    double currentTime = currentMessage.timestamp;
    if ((currentTime - lastTime)/1000 < 1*60 ) {//1分钟
        return nil;
    }
    
    LLMessage *timeMessage = [[LLMessage alloc] init];
    timeMessage.msgid = [LLIMUtil messageIDGenerator];
    timeMessage.type = OllaMessageTypeTimestamp;
    timeMessage.timestamp = currentTime;
    return timeMessage;
}


+ (UIImage *)leftResizingBackgroundImage{
    return [[UIImage imageNamed:@"im_bubble_l"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 30, 36 , 15) resizingMode:UIImageResizingModeStretch];
}

+ (UIImage *)rightResizingBackgroundImage{
    return [[UIImage imageNamed:@"im_bubble_r"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 15, 36 , 30) resizingMode:UIImageResizingModeStretch];;
}

/**
 *  宽高最多120p(参考微信)
 *
 *  @param image 原图大小
 *
 *  @return 返回缩略图尺寸
 */
+ (CGSize)imageMessageSizeWithOrignialImage:(UIImage *)image{

    if (!image) {
        return CGSizeZero;
    }
    
    CGFloat thumbMax = 120.f;
    
    CGFloat originalWidth = image.size.width;
    CGFloat originalHeight = image.size.height;
    
    CGFloat maxEdge = MAX(originalWidth, originalHeight);
    CGFloat ratio = maxEdge/thumbMax;
    
    return CGSizeMake(floor(originalWidth/ratio), floor(originalHeight/ratio));
}

+ (UIImage *)thumbImageWithOrignialImage:(UIImage *)image{

    if (!image) {
        return nil;
    }
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize thumbSize = [LLIMUtil imageMessageSizeWithOrignialImage:image];
    UIImage *thumbImage = [image resizeImageWithSize:CGSizeMake(thumbSize.width*scale, thumbSize.height*scale)]; // thumb image
    return thumbImage;
}


+ (NSString *)imThumbImageURLWithURLString:(NSString *)key width:(CGFloat)width height:(CGFloat)height{
    NSString *extention = [key pathExtension];
    CGFloat scale = [UIScreen mainScreen].scale;
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"_%.0fx%.0f_crop.%@",width*scale,height*scale,extention]];
}


@end
