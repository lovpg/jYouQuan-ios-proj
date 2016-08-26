//
//  LLAudioCoderProtocol.h
//  Olla
//
//  Created by nonstriater on 14-7-30.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLAudioCoderProtocol <NSObject>

- (void)encode;// wav ==> amr or ogg
- (void)decode;// amr,ogg ==> wav

@end
