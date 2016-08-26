//
//  LLAudioMessageStoreage.h
//  Olla
//
//  Created by nonstriater on 14-7-31.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLMessageStoreageProtocol <NSObject>

- (NSString *)messageStorePath;
- (NSString *)messageStoreName:(id)key;

@end
