//
//  OllaAudioRecordController.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//


@interface OllaAudioRecordController : OllaController

@property(nonatomic,strong) NSString *recordFilePath;
@property(nonatomic,strong) NSDictionary *recordSetting;

- (id)initWithFilePath:(NSString *)path;
- (void)record;

@end
