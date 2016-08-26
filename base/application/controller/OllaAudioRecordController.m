//
//  OllaAudioRecordController.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaAudioRecordController.h"

@interface OllaAudioRecordController (){

    AVAudioRecorder *audioRecord;
}

@end


@implementation OllaAudioRecordController


- (id)initWithFilePath:(NSString *)path{
    self = [super init];
    if (!self) {
        return nil;
    }

    NSDictionary *setting = @{};
    
    NSError *error = nil;
    audioRecord = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:path] settings:setting error:&error];
    if (error) {
        NSLog(@"Audio Recorder init ERROR:%@",error);
    }
    
    return self;
}


- (void)setRecordSetting:(NSDictionary *)recordSetting{

    if (_recordSetting!=recordSetting) {
        _recordSetting = recordSetting;
    }

}

- (void)record{


}




@end
