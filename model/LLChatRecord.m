//
//  LLChatRecord.m
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLChatRecord.h"
#import "LLIMUtil.h"

@implementation LLChatRecord

- (id)objectForKeyedSubscript:(id)key{
    
    return [self valueForKey:key];

}


// 将一条chats record 转出一个 message 对象
//- (LLMessage *)messageObjectWithMsgid:(NSString *)msgid timestamp:(double)timestamp{
//
//    LLMessage *message = [LLMessage object];
//    message.userID = self.uid;
//    message.timestamp = timestamp;
//    message.sendStatus = 1;
//    message.status = 0; // 未读（语音消息有用）
//    message.dest = 1;    //uid是否为登录用户
//
//    message.msgid = msgid;
//    
//    NSDictionary *dict = [self.fullMessage dictionaryRepresentation];
//    
//    if ([dict[@"type"] isEqualToString:@"text"]) {
//    
//        message.type = OllaMessageTypeText;
//        message.message = [dict[@"data"] dictionaryRepresentation][@"message"];
//    
//    }else if([dict[@"type"] isEqualToString:@"image"]){
//        message.type = OllaMessageTypeImage;
//        
//        LLImageObject *imageObject = [LLImageObject object];
//        imageObject.imageUrl = [dict[@"data"] dictionaryRepresentation][@"url"];
//        message.message = imageObject;
//        
//    }else if([dict[@"type"] isEqualToString:@"voice"]){
//        message.type = OllaMessageTypeVoice;
//        
//        LLAudioObject *voiceObject = [LLAudioObject object];
//        voiceObject.audioUrl = [dict[@"data"] dictionaryRepresentation][@"url"];
//        voiceObject.duration = [[dict[@"data"] dictionaryRepresentation][@"duration"] floatValue];
//        
//        message.message = voiceObject;
//        
//        /**
//         
//         采用自顶向下的分析方式来设计
//         {
//         cmd = receive;
//         data = "{\"url\":\"https:\\/\\/olla.laopao.com\\/image.do?f=\\/im\\/voice\\/0ad07663eaef45efa0b5f20ba562d4a9\\/im\\/voice\\/0ad07663eaef45efa0b5f20ba562d4a9.amr\",\"duration\":2.519781}";
//         msgid = 54D3D55A7ABC49039E0FB4D71C18200F;
//         type = voice;
//         uid = 16935256;
//         }
//         
//         */
//        
//    }
//    
//    return message;
//
//}


@end
