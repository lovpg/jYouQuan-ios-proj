//
//  LLMessage.h
//  Olla
//
//  Created by nonstriater on 14-7-18.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MessageType){
    OllaMessageTypeText=1,
    OllaMessageTypeImage=2,
    OllaMessageTypeVoice=3,
    OllaMessageTypeTimestamp
};


@interface LLMessage : NSObject

@property(nonatomic,strong) NSString *msgLocalID;// 比如判断一条消息对方是否已读，目前不需要
@property(nonatomic,strong) NSString *msgid;
@property(nonatomic,assign) double timestamp; //ms

/** 多媒体数据对象，可以为 NSString ImageObject，MusicObject，VideoObject，WebpageObject等。 */
@property(nonatomic,strong) id message;


@property(nonatomic,assign) MessageType type; // 枚举~1.2.3

@property(nonatomic,assign) int sendStatus; // 0. 正在发送 1. 发送成功 2. 失败
@property(nonatomic,assign) int status; // 0 未读， 1 已读  只对语音有效
@property(nonatomic,assign) int dest; // 0 自己 ，1-n他人

@property(nonatomic,strong) NSString *userID; //??


//msgLocalID,timestamp,message,type,status,dest
+ (id)object;

+ (LLMessage *)textMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest text:(NSString *)text;

+ (LLMessage *)voiceMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest url:(NSString *)url duration:(double)duration;


+ (LLMessage *)imageMessageWithMsgid:(NSString *)msgid timestamp:(double)timestamp sendStatus:(int)sendStatus status:(int)status dest:(int)dest url:(NSString *)url thumbImageUrl:(NSString *)thumbURL image:(UIImage *)image;


@end


//将对象转JSON字符串
@interface LLImageObject : NSObject

@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) NSString *imageUrl;
@property(nonatomic,strong) NSString *thumbImageUrl;
@property(nonatomic,assign) long length;
@property(nonatomic,assign) CGFloat thumbWidth;
@property(nonatomic,assign) CGFloat thumbHeight;
@property(nonatomic,assign) long thumbLength;
@property(nonatomic,strong) NSString *aesKey;


+ (id)object;

@end

@interface LLAudioObject : NSObject

@property(nonatomic,strong) NSData *audioData;
@property(nonatomic,strong) NSString *aesKey;
@property(nonatomic,strong) NSString *audioUrl;
@property(nonatomic,assign) CGFloat length; // 音频大小 Bytes
@property(nonatomic,assign) CGFloat duration;//音频长度

+ (id)object;

@end



/**
 
wechat 的图片
 <msg><img aeskey="39326239646662646665633232306431" encryver="1" cdnthumbaeskey ="39326239646662646665633232306431" cdnmidimgurl="304b02010004443042020100020436445b0c02030f424202041e3fcf8c020453a180d30420333637313739363833354063686174726f6f6d34325f313430333039333230310201000201000400" length="67723" antispamcheckstatus="0" antispamret="0" cdnthumburl="304b02010004443042020100020436445b0c02030f424202041e3fcf8c020453a180d30420333637313739363833354063686174726f6f6d34325f313430333039333230310201000201000400" cdnthumblength="3117" cdnthumbheight="120" cdnthumbwidth="67" /></msg>|4|2|3|1
 */


/*

@interface LLMusicObject : NSObject

@end


@interface LLVedioObject : NSObject

@end


@interface LLFileObject : NSObject

@end

@interface LLWebPageObject : NSObject

@end

*/


