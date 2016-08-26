//
//  LLMessageReceiveService.h
//  Olla
//
//  Created by null on 14-12-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

//接受消息处理服务
@interface LLMessageReceiveService : NSObject

- (void)receiveText:(NSString *)text;
- (void)receiveImageWithURL:(NSString *)url;
- (void)receiveVoiceWithURL:(NSString *)url;

@end
