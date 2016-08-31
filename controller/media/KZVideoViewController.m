//
//  KZVideoViewController.m
//  KZWeChatSmallVideo_OC
//
//  Created by HouKangzhu on 16/7/18.
//  Copyright © 2016年 侯康柱. All rights reserved.
//

#import "KZVideoViewController.h"
#import "KZVideoSupport.h"
#import "KZVideoConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "KZVideoListViewController.h"
#import "LLShareViewController.h"

#import "VJ_VideoFolderManager.h"

@interface KZVideoViewController()<KZControllerBarDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,

    AVCaptureAudioDataOutputSampleBufferDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    UIGestureRecognizerDelegate,
    AVCaptureFileOutputRecordingDelegate> {
    
    KZStatusBar *_topSlideView;
    
    UIView *_videoView;
    KZFocusView *_focusView;
    UILabel *_statusInfo;
    UILabel *_cancelInfo;
    
    KZControllerBar *_ctrlBar;
    
    AVCaptureSession *_videoSession;
    AVCaptureVideoPreviewLayer *_videoPreLayer;
    
    // 录制采集设备
    AVCaptureDevice *_videoDevice;
    
    AVCaptureVideoDataOutput *_videoDataOut;
    AVCaptureAudioDataOutput *_audioDataOut;
    
    AVAssetWriter *_assetWriter;
    AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferInput;
    AVAssetWriterInput *_assetWriterVideoInput;
    AVAssetWriterInput *_assetWriterAudioInput;
    CMTime _currentSampleTime;
    BOOL _recoding;
    
    dispatch_queue_t _recoding_queue;
//      dispatch_queue_create("com.video.queue", DISPATCH_QUEUE_SERIAL)
    
    KZVideoModel *_currentRecord;
    BOOL _currentRecordIsCancel;
    UIView *_eyeView;
    
    
    
    // 新的定义
    //从设备获取数据
    AVCaptureDeviceInput * _videoDeviceInput;
    AVCaptureDevice *_audioDevice;
    AVCaptureDeviceInput * _audioDeviceInput;
    //写入文件
    AVCaptureMovieFileOutput *_captureMovieFileOutput;
    AVCaptureConnection * _connection;

}

@property (nonatomic, assign) KZVideoViewShowType showType;

@end

//static KZVideoViewController *__currentVideoVC = nil;

@implementation KZVideoViewController

- (void)viewDidLoad
{
    _showType = _Typeshowing;
//    __currentVideoVC = self;
    [VJ_VideoFolderManager createVideoFolderIfNotExist];
    [VJ_VideoFolderManager deleteRecordVideoCache];
    
    [self setupSubViews];
//    self.view.hidden = YES;
    
//    BOOL videoExist = [KZVideoUtil existVideo];
//    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
//    [keyWindow addSubview:self.view];
    
    
//    if (_showType == KZVideoViewShowTypeSingle && videoExist)
//    {
//        
//        [self ctrollVideoOpenVideoList:nil];
//        kz_dispatch_after(0.4, ^{
//            self.view.hidden = NO;
//        });
//        
//    }
    
//    else {
        self.view.hidden = NO;
        self.actionView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight([KZVideoConfig viewFrameWithType:_Typeshowing]));
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.actionView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.4];
        } completion:^(BOOL finished) {
            [self viewDidAppear];
        }];
//    }
    [self setupVideo];
    
}



- (void)startAnimationWithType:(KZVideoViewShowType)showType
{
    _showType = showType;
//    __currentVideoVC = self;
    
    [self setupSubViews];
    self.view.hidden = YES;
    BOOL videoExist = [KZVideoUtil existVideo];
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    [keyWindow addSubview:self.view];
    if (_showType == KZVideoViewShowTypeSingle && videoExist)
    {
        
        [self ctrollVideoOpenVideoList:nil];
        kz_dispatch_after(0.4, ^{
            self.view.hidden = NO;
        });
        
    }
    else {
        self.view.hidden = NO;
        self.actionView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight([KZVideoConfig viewFrameWithType:showType]));
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.actionView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.4];
        } completion:^(BOOL finished) {
            [self viewDidAppear];
        }];
    }
    [self setupVideo];
}

- (void)endAniamtion {
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.backgroundColor = [UIColor clearColor];
//        self.actionView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight([KZVideoConfig viewFrameWithType:_showType]));
//    } completion:^(BOOL finished) {
        [self closeView];
//    }];
}

- (void)closeView {
    [_videoSession stopRunning];
    [_videoPreLayer removeFromSuperlayer];
    _videoPreLayer = nil;
    [_videoView removeFromSuperview];
    _videoView = nil;
    
    _videoDevice = nil;
    _videoDataOut = nil;
    _assetWriter = nil;
    _assetWriterAudioInput = nil;
    _assetWriterVideoInput = nil;
    _assetWriterPixelBufferInput = nil;
//    [self.view removeFromSuperview];
//    __currentVideoVC = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    NSLog(@" VideoVC ~~~~ 消亡啦~\(≧▽≦)/~啦啦啦");
}



- (void)setupSubViews {
//    _view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTopBarAction:)];
    [self.view addGestureRecognizer:ges];
    
    _actionView = [[UIView alloc] initWithFrame:[KZVideoConfig viewFrameWithType:_showType]];
    [self.view addSubview:_actionView];
    _actionView.backgroundColor = kzThemeBlackColor;
    _actionView.clipsToBounds = YES;
    
    
    BOOL isSmallStyle = _showType == KZVideoViewShowTypeSmall;
    
    CGSize videoViewSize = [KZVideoConfig videoViewDefaultSize];
    CGFloat topHeight = isSmallStyle ? 20.0 : 64.0;
    
    CGFloat allHeight = _actionView.frame.size.height;
    CGFloat allWidth = _actionView.frame.size.width;
    
    CGFloat buttomHeight =  isSmallStyle ? kzControViewHeight : allHeight - topHeight - videoViewSize.height;
    
    _topSlideView = [[KZStatusBar alloc] initWithFrame:CGRectMake(0, 0, allWidth, topHeight) style:_showType];
    if (!isSmallStyle) {
        [_topSlideView addCancelTarget:self selector:@selector(endAniamtion)];
    }
    [self.actionView addSubview:_topSlideView];
    
    
    _ctrlBar = [[KZControllerBar alloc] initWithFrame:CGRectMake(0, allHeight - buttomHeight, allWidth, buttomHeight)];
    [_ctrlBar setupSubViewsWithStyle:_showType];
    _ctrlBar.delegate = self;
    [self.actionView addSubview:_ctrlBar];

    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topSlideView.frame), videoViewSize.width, videoViewSize.height)];
    [self.actionView addSubview:_videoView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusAction:)];
    tapGesture.delaysTouchesBegan = YES;
    [_videoView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoomVideo:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    doubleTapGesture.delaysTouchesBegan = YES;
    [_videoView addGestureRecognizer:doubleTapGesture];
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    
    _focusView = [[KZFocusView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _focusView.backgroundColor = [UIColor clearColor];
    
    _statusInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_videoView.frame) - 30, _videoView.frame.size.width, 20)];
    _statusInfo.textAlignment = NSTextAlignmentCenter;
    _statusInfo.font = [UIFont systemFontOfSize:14.0];
    _statusInfo.textColor = [UIColor whiteColor];
    _statusInfo.hidden = YES;
    [self.actionView addSubview:_statusInfo];
    
    _cancelInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 24)];
    _cancelInfo.center = _videoView.center;
    _cancelInfo.textAlignment = NSTextAlignmentCenter;
    _cancelInfo.textColor = kzThemeWhiteColor;
    _cancelInfo.backgroundColor = kzThemeWaringColor;
    _cancelInfo.hidden = YES;
    [self.actionView addSubview:_cancelInfo];
    
    
    [_actionView sendSubviewToBack:_videoView];
}

- (void)setupVideo {
    NSString *unUseInfo = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        unUseInfo = @"模拟器不可以的..";
    }
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthStatus == ALAuthorizationStatusRestricted || videoAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"相机访问受限...";
    }
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioAuthStatus == ALAuthorizationStatusRestricted || audioAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"录音访问受限...";
    }
    if (unUseInfo != nil) {
        _statusInfo.text = unUseInfo;
        _statusInfo.hidden = NO;
        _eyeView = [[KZEyeView alloc] initWithFrame:_videoView.bounds];
        [_videoView addSubview:_eyeView];
        return;
    }
    
    // 创建录制线程
    _recoding_queue = dispatch_queue_create("com.kzsmallvideo.queue", DISPATCH_QUEUE_SERIAL);
    
    /*
    NSArray *devicesVideo = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *devicesAudio = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesVideo[0] error:nil];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:devicesAudio[0] error:nil];
    
    _videoDevice = devicesVideo[0];
    
    _videoDataOut = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOut.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOut.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOut setSampleBufferDelegate:self queue:_recoding_queue];
    
    _audioDataOut = [[AVCaptureAudioDataOutput alloc] init];
    [_audioDataOut setSampleBufferDelegate:self queue:_recoding_queue];
    
    _videoSession = [[AVCaptureSession alloc] init];
    if ([_videoSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _videoSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    if ([_videoSession canAddInput:videoInput]) {
        [_videoSession addInput:videoInput];
    }
    if ([_videoSession canAddInput:audioInput]) {
        [_videoSession addInput:audioInput];
    }
    if ([_videoSession canAddOutput:_videoDataOut]) {
        [_videoSession addOutput:_videoDataOut];
    }
    if ([_videoSession canAddOutput:_audioDataOut]) {
        [_videoSession addOutput:_audioDataOut];
    }
     */
    
    // 新的代码
    //视频设备配置为摄像头
    NSError * vError = nil;
    NSError * aError = nil;
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&vError];
    
    //添加一个音频输入设备
    _audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioDevice error:&aError];
    
    //视频保存文件操作
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //初始化Session
    _videoSession = [[AVCaptureSession alloc]init];
    
    //将设备输出添加到会话中
    if ([_videoSession canAddOutput:_captureMovieFileOutput]) {
        [_videoSession addOutput:_captureMovieFileOutput];
    }
    if ([_videoSession canAddInput:_videoDeviceInput]) {
        [_videoSession addInput:_videoDeviceInput];
        [_videoSession addInput:_audioDeviceInput];
        _connection =[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([_connection isVideoStabilizationSupported ]) {
            _connection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    [_videoSession beginConfiguration];
    
    //设置分辨率
    if ([_videoSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        _videoSession.sessionPreset = AVCaptureSessionPresetMedium;
    } else {
        _videoSession.sessionPreset = AVCaptureSessionPresetLow;
    }
    
    [_videoSession commitConfiguration];

    
    
    

    CGFloat viewWidth = CGRectGetWidth(_actionView.frame);
    _videoPreLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_videoSession];
    _videoPreLayer.frame = CGRectMake(0, -CGRectGetMinY(_videoView.frame), viewWidth, viewWidth*kzVideo_w_h);
    _videoPreLayer.position = CGPointMake(viewWidth/2, CGRectGetHeight(_videoView.frame)/2);
    _videoPreLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_videoView.layer addSublayer:_videoPreLayer];
    
    
    [_videoSession startRunning];
    
    [self viewWillAppear];
}

/**
 * 判断摄像头的设备是否可用，并使启用默认设备
 */
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}



- (void)viewWillAppear
{
    _eyeView = [[KZEyeView alloc] initWithFrame:_videoView.bounds];
    [_videoView addSubview:_eyeView];
}

- (void)viewDidAppear {
    
    if (TARGET_IPHONE_SIMULATOR)  return;
    
    UIView *sysSnapshot = [_eyeView snapshotViewAfterScreenUpdates:NO];
    CGFloat videoViewHeight = CGRectGetHeight(_videoView.frame);
    CGFloat viewViewWidth = CGRectGetWidth(_videoView.frame);
    _eyeView.alpha = 0;
    UIView *topView = [sysSnapshot resizableSnapshotViewFromRect:CGRectMake(0, 0, viewViewWidth, videoViewHeight/2) afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    CGRect btmFrame = CGRectMake(0, videoViewHeight/2, viewViewWidth, videoViewHeight/2);
    UIView *btmView = [sysSnapshot resizableSnapshotViewFromRect:btmFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    btmView.frame = btmFrame;
    [_videoView addSubview:topView];
    [_videoView addSubview:btmView];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        topView.transform = CGAffineTransformMakeTranslation(0,-videoViewHeight/2);
        btmView.transform = CGAffineTransformMakeTranslation(0, videoViewHeight);
        topView.alpha = 0.3;
        btmView.alpha = 0.3;
    } completion:^(BOOL finished) {
        [topView removeFromSuperview];
        [btmView removeFromSuperview];
        [_eyeView removeFromSuperview];
        _eyeView = nil;
        [self focusInPointAtVideoView:CGPointMake(_videoView.bounds.size.width/2, _videoView.bounds.size.height/2)];
    }];
    
    __block UILabel *zoomLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    zoomLab.center = CGPointMake(_videoView.center.x, CGRectGetMaxY(_videoView.frame) - 50);
    zoomLab.font = [UIFont boldSystemFontOfSize:14];
    zoomLab.text = @"双击放大";
    zoomLab.textColor = [UIColor whiteColor];
    zoomLab.textAlignment = NSTextAlignmentCenter;
    [_videoView addSubview:zoomLab];
    [_videoView bringSubviewToFront:zoomLab];
    
    kz_dispatch_after(1.6, ^{
        [zoomLab removeFromSuperview];
    });
}

- (void)focusInPointAtVideoView:(CGPoint)point {
    CGPoint cameraPoint= [_videoPreLayer captureDevicePointOfInterestForPoint:point];
    _focusView.center = point;
    [_videoView addSubview:_focusView];
    [_videoView bringSubviewToFront:_focusView];
    [_focusView focusing];
    
    NSError *error = nil;
    if ([_videoDevice lockForConfiguration:&error]) {
        if ([_videoDevice isFocusPointOfInterestSupported]) {
            _videoDevice.focusPointOfInterest = cameraPoint;
        }
        if ([_videoDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            _videoDevice.focusMode = AVCaptureFocusModeAutoFocus;
        }
        if ([_videoDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            _videoDevice.exposureMode = AVCaptureExposureModeAutoExpose;
        }
        if ([_videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            _videoDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        }
        [_videoDevice unlockForConfiguration];
    }
    if (error) {
        NSLog(@"聚焦失败:%@",error);
    }
    kz_dispatch_after(1.0, ^{
        [_focusView removeFromSuperview];
    });
}

#pragma mark - Actions --
- (void)focusAction:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:_videoView];
    [self focusInPointAtVideoView:point];
}

- (void)zoomVideo:(UITapGestureRecognizer *)gesture {
    NSError *error = nil;
    if ([_videoDevice lockForConfiguration:&error]) {
        CGFloat zoom = _videoDevice.videoZoomFactor == 2.0?1.0:2.0;
        _videoDevice.videoZoomFactor = zoom;
        [_videoDevice unlockForConfiguration];
    }
}

- (void)moveTopBarAction:(UIPanGestureRecognizer *)gesture {
    CGPoint pointAtView = [gesture locationInView:self.view];
    CGRect dafultFrame = [KZVideoConfig viewFrameWithType:_showType];
    
    if (pointAtView.y < dafultFrame.origin.y) {
        return;
    }
    
    CGPoint pointAtTop = [gesture locationInView:_topSlideView];
    if (pointAtTop.y > -10 && pointAtTop.y < 30) {
        CGRect actionFrame = _actionView.frame;
        actionFrame.origin.y = pointAtView.y;
        _actionView.frame = actionFrame;
        
        CGFloat alpha = 0.4*(kzSCREEN_HEIGHT - pointAtView.y)/CGRectGetHeight(_actionView.frame);
        self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: alpha];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (pointAtView.y >= CGRectGetMidY(dafultFrame)) {
            [self endAniamtion];
        }
        else {
            [UIView animateWithDuration:0.3 animations:^{
                _actionView.frame = dafultFrame;
                self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.4];
            }];
        }
    }
}

#pragma mark - controllerBarDelegate 

- (void)ctrollVideoDidStart:(KZControllerBar *)controllerBar {
//    _currentRecord = [KZVideoUtil createNewVideo];
    _currentRecordIsCancel = NO;
//    NSURL *outURL = [NSURL fileURLWithPath:_currentRecord.videoAbsolutePath];
//    [self createWriter:outURL];
    if(![_captureMovieFileOutput isRecording]) {
        [_captureMovieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:[VJ_VideoFolderManager getVideoMOVFilePathString]]
                                             recordingDelegate:self];
    }

    
    _topSlideView.isRecoding = YES;
    _statusInfo.textColor = kzThemeTineColor;
    _statusInfo.text = @"↑上移取消";
    _statusInfo.hidden = NO;
    kz_dispatch_after(0.5, ^{
        _statusInfo.hidden = YES;
    });
    
    _recoding = YES;
//    NSLog(@"视频开始录制");
}

- (void)ctrollVideoDidEnd:(KZControllerBar *)controllerBar {
    _topSlideView.isRecoding = NO;
    _recoding = NO;
//    [self saveVideo:^(NSURL *outFileURL) {
//        LLShareViewController *shareVC = [[LLShareViewController alloc]init];
//        self.delegate = shareVC;
////        [self.navigationController pushViewController:shareVC animated:YES];
//        if (_delegate)
//        {
//            [_delegate videoViewController:self didRecordVideo:_currentRecord];
////            [self endAniamtion];
//            [self.navigationController pushViewController:shareVC animated:YES];
//        }
//    }];
    
//    NSLog(@"视频录制结束");
    if([_captureMovieFileOutput isRecording])
    {
        [_captureMovieFileOutput stopRecording];
    }
}

- (void)ctrollVideoDidCancel:(KZControllerBar *)controllerBar reason:(KZRecordCancelReason)reason{
    _currentRecordIsCancel = YES;
    _topSlideView.isRecoding = NO;
    _recoding = NO;
    if (reason == KZRecordCancelReasonTimeShort) {
        [KZVideoConfig showHinInfo:@"录制时间过短" inView:_videoView frame:CGRectMake(0,CGRectGetHeight(_videoView.frame)/3*2,CGRectGetWidth(_videoView.frame),20) timeLong:1.0];
    }
//    NSLog(@"当前视频录制取消");
}

- (void)ctrollVideoWillCancel:(KZControllerBar *)controllerBar {
    if (!_cancelInfo.hidden) {
        return;
    }
    _cancelInfo.text = @"松手取消";
    _cancelInfo.hidden = NO;
    kz_dispatch_after(0.5, ^{
        _cancelInfo.hidden = YES;
    });
}

- (void)ctrollVideoDidRecordSEC:(KZControllerBar *)controllerBar {
    _topSlideView.isRecoding = YES;
//    NSLog(@"视频录又过了 1 秒");
}

- (void)ctrollVideoDidClose:(KZControllerBar *)controllerBar {
//    NSLog(@"录制界面关闭");
    if (_delegate && [_delegate respondsToSelector:@selector(videoViewControllerDidCancel:)]) {
        [_delegate videoViewControllerDidCancel:self];
    }
    [self endAniamtion];
}

- (void)ctrollVideoOpenVideoList:(KZControllerBar *)controllerBar {
//    NSLog(@"查看视频列表");
    KZVideoListViewController *listVC = [[KZVideoListViewController alloc] init];
    __weak typeof(self) blockSelf = self;
    listVC.selectBlock = ^(KZVideoModel *selectModel) {
        _currentRecord = selectModel;
        
        // 跳到下个视图要将视图置为nil
        [_videoSession stopRunning];
        [_videoPreLayer removeFromSuperlayer];
        _videoPreLayer = nil;
        [_videoView removeFromSuperview];
        _videoView = nil;
        _videoDevice = nil;
        _videoDataOut = nil;
        _assetWriter = nil;
        _assetWriterAudioInput = nil;
        _assetWriterVideoInput = nil;
        _assetWriterPixelBufferInput = nil;

        LLShareViewController *shareVC = [[LLShareViewController alloc]init];
        blockSelf.delegate = shareVC;
        if (_delegate)
        {
            [_delegate videoViewController:blockSelf didRecordVideo:_currentRecord];
            [self.navigationController pushViewController:shareVC animated:YES];
        }
//        [blockSelf closeView];
    };
    
    listVC.didCloseBlock = ^{
        if (_showType == KZVideoViewShowTypeSingle) {
            [blockSelf viewDidAppear];
        }
    };
    [listVC showAnimationWithType:_showType];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (!_recoding) return;
    
    @autoreleasepool {
        _currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:_currentSampleTime];
        }
        if (captureOutput == _videoDataOut) {
            if (_assetWriterPixelBufferInput.assetWriterInput.isReadyForMoreMediaData) {
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                BOOL success = [_assetWriterPixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:_currentSampleTime];
                if (!success) {
                    NSLog(@"Pixel Buffer没有append成功");
                }
            }
        }
        if (captureOutput == _audioDataOut) {
            [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

- (void)createWriter:(NSURL *)assetUrl {
    _assetWriter = [AVAssetWriter assetWriterWithURL:assetUrl fileType:AVFileTypeQuickTimeMovie error:nil];
    int videoWidth = [KZVideoConfig defualtVideoSize].width;
    int videoHeight = [KZVideoConfig defualtVideoSize].height;
    /*
    NSDictionary *videoCleanApertureSettings = @{
                                               AVVideoCleanApertureWidthKey:@(videoHeight),
                                               AVVideoCleanApertureHeightKey:@(videoWidth),
                                            AVVideoCleanApertureHorizontalOffsetKey:@(200),
                                            AVVideoCleanApertureVerticalOffsetKey:@(0)
                                               };
    NSDictionary *videoAspectRatioSettings = @{
                                               AVVideoPixelAspectRatioHorizontalSpacingKey:@(3),
                                               AVVideoPixelAspectRatioVerticalSpacingKey:@(3)
                                               };
    NSDictionary *codecSettings = @{
                                    AVVideoAverageBitRateKey:@(960000),
                                    AVVideoMaxKeyFrameIntervalKey:@(1),
                                    AVVideoProfileLevelKey:AVVideoProfileLevelH264Main30,
                                    AVVideoCleanApertureKey: videoCleanApertureSettings,
                                    AVVideoPixelAspectRatioKey:videoAspectRatioSettings
                                    };
     */
    NSDictionary *outputSettings = @{
                          AVVideoCodecKey : AVVideoCodecH264,
                          AVVideoWidthKey : @(videoHeight),
                          AVVideoHeightKey : @(videoWidth),
                          AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
//                          AVVideoCompressionPropertiesKey:codecSettings
                          };
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI / 2.0);
    
    
    NSDictionary *audioOutputSettings = @{
                                         AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                         AVEncoderBitRateKey:@(64000),
                                         AVSampleRateKey:@(44100),
                                         AVNumberOfChannelsKey:@(1),
                                         };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    NSDictionary *SPBADictionary = @{
                                     (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (__bridge NSString *)kCVPixelBufferWidthKey : @(videoWidth),
                                     (__bridge NSString *)kCVPixelBufferHeightKey  : @(videoHeight),
                                     (__bridge NSString *)kCVPixelFormatOpenGLESCompatibility : ((__bridge NSNumber *)kCFBooleanTrue)
                                     };
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:SPBADictionary];
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }

}

- (void)saveVideo:(void(^)(NSURL *outFileURL))complier
{
    
    if (_recoding) return;
    
    if (!_recoding_queue)
    {
        complier(nil);
        return;
    };
    
    dispatch_async(_recoding_queue, ^{
        NSURL *outputFileURL = [NSURL fileURLWithPath:_currentRecord.videoAbsolutePath];
        [_assetWriter finishWritingWithCompletionHandler:^{
 
            if (_currentRecordIsCancel) return ;
            
            [KZVideoUtil saveThumImageWithVideoURL:outputFileURL second:1];
            
            if (complier) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complier(outputFileURL);
                });
            }
            if (!_savePhotoAlbum) {
                BOOL ios8Later = [[[UIDevice currentDevice] systemVersion] floatValue] >= 8;
                if (ios8Later) {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (!error && success) {
                            NSLog(@"保存相册成功!");
                        }
                        else {
                            NSLog(@"保存相册失败! :%@",error);
                        }
                    }];
                    
                }
                else {
                    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
                        if (!error) {
                            NSLog(@"保存相册成功!");
                        }
                        else {
                            NSLog(@"保存相册失败!");
                        }
                    }];
                    
                }
                
            }
        }];
    });
    
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate 摄像头画面代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"开始录制...");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"录制结束...%@",outputFileURL);
    NSURL * videoFilePath = [NSURL URLWithString:[VJ_VideoFolderManager getVideoMOVFilePathString]];
    NSLog(@"压缩前大小 %f MB",[VJ_VideoFolderManager fileSize:videoFilePath]);
    [self compositionMp4VideoFile:outputFileURL];
}


/**
 * 压缩
 */
- (void)compositionMp4VideoFile:(NSURL *)origonPath {
    //获取视频资源
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:origonPath options:nil];
    // 图像裁剪部分
    AVAssetTrack * assetTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:assetTrack];
    CGFloat rate;
    CGFloat renderW = Screen_Width;
    rate = renderW / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
    CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, -(assetTrack.naturalSize.width - assetTrack.naturalSize.height) / 2.0+1*(Screen_Width - Screen_Width)/2));
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);
    [layerInstruction setTransform:layerTransform atTime:kCMTimeZero];
    [layerInstruction setOpacity:0.0 atTime:avAsset.duration];
    
    NSMutableArray *layerInstructionArray = [[NSMutableArray alloc] init];
    [layerInstructionArray addObject:layerInstruction];
    
    AVMutableVideoCompositionInstruction *mainInstruciton = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruciton.timeRange = CMTimeRangeMake(kCMTimeZero, avAsset.duration);
    mainInstruciton.layerInstructions = layerInstructionArray;
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruciton];
    mainCompositionInst.frameDuration = CMTimeMake(1,100);
    mainCompositionInst.renderSize = CGSizeMake(renderW, renderW);

    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        //原有导出方式
        //        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        //裁剪导出方式
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.videoComposition = mainCompositionInst;
        //
        
        //判断MP4文件是否有占位，如果有旧删除。
        NSString * mp4Path = [VJ_VideoFolderManager getVideoCompositionFilePathString];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:mp4Path]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:mp4Path error:&error];
            if (error) {
                NSLog(@"删除视频文件出错:%@", error);
            } else {
                NSLog(@"删除MP4文件成功，即将将转码后的文件导出到路径：%@",mp4Path);
            }
        } else {
            NSLog(@"当前目录下没有MP4文件存在，即将将转码后的文件导出到路径：%@",mp4Path);
        }
        
        exportSession.outputURL = [NSURL fileURLWithPath:[VJ_VideoFolderManager getVideoCompositionFilePathString]];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"MP4格式视频导出失败，错误信息: %@", [[exportSession error] localizedDescription]);
                    break;
                }
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"导出取消");
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"导出成功，导出的MP4文件大小为:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self playRecordVideo];
                        
                        UIImage *image = [self thumbnailImageForVideo:exportSession.outputURL atTime:1];
                        
                        
                        LLShareViewController *shareVC = [[LLShareViewController alloc]init];
                        shareVC.thumbImage = image;
//                                self.delegate = shareVC;
                        //        [self.navigationController pushViewController:shareVC animated:YES];
//                                if (_delegate)
//                                {
//                                    [_delegate videoViewController:self didRecordVideo:_currentRecord];
                        //            [self endAniamtion];
                                    [self.navigationController pushViewController:shareVC animated:YES];
//                                }

                    });
                    break;
                }
                default:{
                    break;
                }
                    
            }
        }];
    }
}

- (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size
{
    // 获取视频第一帧
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(size.width, size.height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 10) actualTime:NULL error:&error];
    if (error == nil)
    {
        return [UIImage imageWithCGImage:img];
    }
    return nil;
}

- (UIImage *) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    
    
    assetImageGenerator.appliesPreferredTrackTransform =YES;        assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    
    CFTimeInterval thumbnailImageTime = time;
    
    NSError *thumbnailImageGenerationError = nil;
    
    thumbnailImageRef = [assetImageGenerator
                           copyCGImageAtTime:CMTimeMake(thumbnailImageTime,60) actualTime:NULL error:&thumbnailImageGenerationError];
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:<#(nullable CMTime *)#> error:<#(NSError *__autoreleasing  _Nullable * _Nullable)#>]
    
    if (!thumbnailImageRef)
        
        DDLogInfo(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] :nil;
    
    return thumbnailImage;
    
}


@end
