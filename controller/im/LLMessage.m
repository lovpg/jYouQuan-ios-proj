//
//  LLMessage.m
//  Olla
//
//  Created by nonstriater on 14-7-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLMessage.h"
#import "LLIMUtil.h"

@implementation LLMessage

+ (id)object{
    return [[LLMessage alloc] init];
}

+ (LLMessage *)textMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest text:(NSString *)text{

    LLMessage *message = [[LLMessage alloc] init];
    message.msgid = msgid;
    message.message = text;
    message.timestamp = (timestamp==0)?[[NSDate date] timeIntervalSince1970]*1000:timestamp;
    message.type = 1;
    message.sendStatus = sendStatus;
    message.dest = dest;
    
    return message;
}

+ (LLMessage *)voiceMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest url:(NSString *)url duration:(double)duration{

    LLAudioObject *ao = [LLAudioObject object];
    ao.duration = duration;
    ao.audioUrl = url;
    
    LLMessage *message = [LLMessage object];
    message.msgid = msgid;
    message.timestamp = (timestamp==0)?[[NSDate date] timeIntervalSince1970]*1000:timestamp;
    message.type = 3;
    message.sendStatus = sendStatus;
    message.dest = dest;//表示自己
    message.status = status;// 0未读  是否未读,目前voice消息独有
    message.message = ao;// 音频数据
    
    return message;
    
}


+ (LLMessage *)imageMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest url:(NSString *)url thumbImageUrl:(NSString *)thumbURL image:(UIImage *)image{

    LLImageObject *io = [LLImageObject object];
    
    io.length = 0;
    io.aesKey = nil;
    io.thumbLength = 0;
    io.thumbImageUrl = thumbURL;
    io.imageUrl = url;  
    io.image = [LLIMUtil thumbImageWithOrignialImage:image]; // thumb image
    CGSize thumbSize = [LLIMUtil imageMessageSizeWithOrignialImage:image];
    io.thumbHeight = thumbSize.height;
    io.thumbWidth = thumbSize.width;
    
    LLMessage *message = [[LLMessage alloc] init];
    message.msgid = msgid;
    message.timestamp = (timestamp==0)?[[NSDate date] timeIntervalSince1970]*1000:timestamp;
    message.type = 2;
    message.sendStatus = sendStatus;
    message.dest = dest;
    message.message = io;//图片url数据
    
    return message;
}




@end


@implementation LLAudioObject

+ (id)object{
    return [[LLAudioObject alloc] init];
}

@end



@implementation LLImageObject

+ (id)object{
    return [[LLImageObject alloc] init];
}

@end










