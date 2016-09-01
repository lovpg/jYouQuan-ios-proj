
//
//  VJ_VideoRecorderToolView.m
//  test
//
//  Created by Vincent_Jac on 16/8/10.
//  Copyright © 2016年 Vincent_Jac. All rights reserved.
//

#import "VJ_VideoRecorderToolView.h"

#pragma mark - 录制按钮
@implementation VJ_RecordBtn
- (instancetype)init {
    self = [[self class] buttonWithType:UIButtonTypeCustom];
    self.recordState = OverRecord;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 50;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1;
    [self setTitle:@"开始" forState:UIControlStateNormal];
    return  self;
}

- (void)touchBtn {
    //设置相机按钮图标变换
    if(self.recordState == OverRecord) {
        self.recordState = StartRecording;
        [self setTitle:@"录制中" forState:UIControlStateNormal];
    } else {
        self.recordState = OverRecord;
        [self setTitle:@"开始" forState:UIControlStateNormal];
    }
}
@end


#pragma mark - 前后置摄像头切换按钮
@implementation VJ_CameraBtn

- (instancetype)init {
    self = [[self class] buttonWithType:UIButtonTypeCustom];
    self.cameraType = BackCamera;
//    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = 3;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.borderWidth = 1;
    [self setBackgroundImage:[UIImage imageNamed:@"changeCamer"] forState:UIControlStateNormal];
    return  self;
}

- (void)touchCameraBtn {
    //设置相机按钮图标变换
    if(self.cameraType == BackCamera) {
        self.cameraType = FontCamera;
//        [self setTitle:@"前" forState:UIControlStateNormal];
    } else {
        self.cameraType = BackCamera;
//        [self setTitle:@"后" forState:UIControlStateNormal];
    }
}
@end



#pragma mark - 闪光灯按钮

@implementation VJ_CameraFlashBtn

- (instancetype)init
{
    self = [[self class] buttonWithType:UIButtonTypeCustom];
    self.flashState = FlashOFF;
//    self.layer.masksToBounds = YES;
//    self.layer.cornerRadius = 3;
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.borderWidth = 1;
    [self setBackgroundImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
    return  self;
}

- (void) touchCameraFlashBtn
{
    //设置闪光灯按钮图标变换
    if(self.flashState == FlashOFF)
    {
        self.flashState = FlashOn;
        [self setBackgroundImage:[UIImage imageNamed:@"flashOn"] forState:UIControlStateNormal];
    }
    else
    {
        self.flashState = FlashOFF;
        [self setBackgroundImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
    }
}

- (void)setCameraFlashOFF {
    self.flashState = FlashOFF;
    [self setTitle:@"OFF" forState:UIControlStateNormal];
}
@end

#pragma mark - 录制时间Label
@interface VJ_RecordMinuteNumberLabel() {
    CGFloat _recordnumber;
    NSTimer * _timer;
}
@end

@implementation VJ_RecordMinuteNumberLabel

- (instancetype) initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _recordnumber = 0;
        self.font = [UIFont systemFontOfSize:13];
        self.textColor = [UIColor greenColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return  self;
}

- (void)beginRecord {
    _recordnumber = 0;
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(recordTimerAction) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    [_timer fire];
}

- (void)endRecord {
    [_timer invalidate];
    _timer = nil;
    __weak UILabel * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.text = [NSString stringWithFormat:@"%.0f\"",_recordnumber];
    });
}

- (void)recordTimerAction {
    _recordnumber += 1;
    __weak UILabel * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.text = [NSString stringWithFormat:@"%.0f\"",_recordnumber];
    });
}

@end

#pragma mark - 聚焦按钮

@implementation VJ_FocusView {
    CGFloat _width;
    CGFloat _height;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _width = CGRectGetWidth(frame);
        _height = _width;
    }
    return self;
}

- (void) focusingEvent {
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat len = 4;
    
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddRect(context, self.bounds);
    
    CGContextMoveToPoint(context, 0, _height/2);
    CGContextAddLineToPoint(context, len, _height/2);
    
    CGContextMoveToPoint(context, _width/2, _height);
    CGContextAddLineToPoint(context, _width/2, _height - len);
    
    CGContextMoveToPoint(context, _width, _height/2);
    CGContextAddLineToPoint(context, _width - len, _height/2);
    
    CGContextMoveToPoint(context, _width/2, 0);
    CGContextAddLineToPoint(context, _width/2, len);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end