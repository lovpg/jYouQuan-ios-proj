//
//  OllaCamaraCaptureController.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-12.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaCamaraCaptureController.h"

@implementation OllaCamaraCaptureController

- (id)init{
   return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self commonInitial];
    }
    return self;
}


- (void)commonInitial{

    _captureSession = [[AVCaptureSession alloc] init];
    
    //配置输入设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // bool adjustingFocus 自动对焦
    
    NSError *error = nil;
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!inputDevice) {
        NSLog(@"ERROR: input device create fail..");
        return ;
    }
    [_captureSession addInput:inputDevice];
    
    
    //创建输出设备,AVCaptureStillImageOutput就可以截获图片
    // AVCaptureVedioDataOutput 捕获视频数据
    
    
}

- (void)setStillImageOutput:(AVCaptureStillImageOutput *)stillImageOutput{
    if (_stillImageOutput != stillImageOutput) {
        _stillImageOutput = stillImageOutput;
        [_captureSession addOutput:stillImageOutput];
    }
    
}

- (void)setVideoDataOutput:(AVCaptureVideoDataOutput *)videoDataOutput{
    if (_videoDataOutput != videoDataOutput) {
        _videoDataOutput = videoDataOutput;
        [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        [_captureSession addOutput:videoDataOutput];
    }

}



- (void)setEmbedPreviewView:(UIView *)embedPreviewView{
    
    if (_embedPreviewView != embedPreviewView) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _previewLayer.frame = embedPreviewView.bounds;
        _previewLayer.contentsGravity = AVLayerVideoGravityResizeAspectFill;
        [embedPreviewView.layer addSublayer:_previewLayer];
        _embedPreviewView = embedPreviewView;
    }

}

- (void)setPreviewOrientation:(AVCaptureVideoOrientation)previewOrientation{
    if (!_previewLayer) {
        return ;
    }

    if (_previewOrientation != previewOrientation) {
        [CATransaction begin];
        _previewOrientation = previewOrientation;
        _previewLayer.connection.videoOrientation = previewOrientation;
        [CATransaction commit];
    }
    
}


- (void)captureStartRunning{

    [_captureSession startRunning];
}
- (void)captureStopRunning{
    [_captureSession stopRunning];
}


- (void)captureStillImage:(void (^)(UIImage *image,NSError *error))finishBlock{
    if (!_stillImageOutput) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            finishBlock(nil,[[NSError alloc] initWithDomain:@"com.olla.captureImage" code:400 userInfo:@{@"message":@"stillImageOutput is nil"}]);
        });
        return;
    }

    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    if (!videoConnection) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            finishBlock(nil,[[NSError alloc] initWithDomain:@"com.olla.captureImage" code:401 userInfo:@{@"message":@"avcaptureconnection is nil"}]);
        });

        return;
    }
    
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef sampleBuffer,NSError *error){
    
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            finishBlock(image,nil);
        });
        
    }];
    
}



-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}



- (void)dealloc{

    [_captureSession stopRunning];
    _captureSession = nil;
}








@end
