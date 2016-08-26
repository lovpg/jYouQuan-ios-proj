//
//  OllaCamaraCaptureController.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-12.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

@interface OllaCamaraCaptureController : OllaController<AVCaptureVideoDataOutputSampleBufferDelegate>{

    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_previewLayer;
    

}

@property(nonatomic,strong) UIView *embedPreviewView;
@property(nonatomic,assign) AVCaptureVideoOrientation previewOrientation;
@property(nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;

- (id)initWithDelegate:(id)delegate;

- (void)captureStartRunning;
- (void)captureStopRunning;

// 抓获静态图像,可以放到后台线程做，捕获后在主线程给出image
- (void)captureStillImage:(void (^)(UIImage *image,NSError *error))finishBlock;

//- (void)captureVideoData;


@end
