//
//  KZVideoViewController.m
//  KZWeChatSmallVideo_OC
//
//  Created by Corporal on 16/7/18.
//  Copyright © 2016年 Corporal. All rights reserved.
//

#import "KZVideoViewController.h"
#import "KZVideoSupport.h"
#import "KZVideoConfig.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "LLShareViewController.h"

#import "VJ_VideoFolderManager.h"
#import "VJ_VideoRecorderToolView.h"

@interface KZVideoViewController()<KZControllerBarDelegate,AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate,
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
    AVCaptureDevice *_videoDevice; // 闪光灯 前置摄像头都要用到
//    AVCaptureVideoDataOutput *_videoDataOut;
//    AVCaptureAudioDataOutput *_audioDataOut;
    
    
    
    CMTime _currentSampleTime;
    BOOL _recoding;
    
    dispatch_queue_t _recoding_queue;
    
//    KZVideoModel *_currentRecord;
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

@property(nonatomic, strong) VJ_CameraBtn * cameraModelChangeBtn;
@property(nonatomic, strong) VJ_CameraFlashBtn * openFlashBtn;


@end


@implementation KZVideoViewController

- (void)viewDidLoad
{
    _Typeshowing = KZVideoViewShowTypeSingle;
    _showType = _Typeshowing;
//    __currentVideoVC = self;
    [VJ_VideoFolderManager createVideoFolderIfNotExist];
    [VJ_VideoFolderManager deleteRecordVideoCache];
    
    self.view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        [self setupSubViews];
        self.view.hidden = NO;
        self.actionView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight([KZVideoConfig viewFrameWithType:_Typeshowing]));
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.actionView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.4];
        } completion:^(BOOL finished) {
            [self VideoViewDidAppear];
        }];

//    [self setupVideo];
    
    //初始化摄像头并呈现画面，默认后置摄像头启动
    [self startCamera:AVCaptureDevicePositionBack];
    
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.tabBarController.tabBar.hidden = YES;
   

}

- (void)viewWillDisappear:(BOOL)animated
{
    
//    self.tabBarController.tabBar.hidden = NO;
}

- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
    
}


- (void)endAniamtion
{
    [self closeView];
}

- (void)closeView {
    [_videoSession stopRunning];
    [_videoPreLayer removeFromSuperlayer];
    _videoPreLayer = nil;
    [_videoView removeFromSuperview];
    _videoView = nil;
    
    _videoDevice = nil;
//    _videoDataOut = nil;
    
    
    
    
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
    
    // 两个功能按键的加入
    //摄像头切换按钮
    self.cameraModelChangeBtn = [[VJ_CameraBtn alloc]init];
    self.cameraModelChangeBtn.frame = CGRectMake(Screen_Width - 65, 22, 40, 40);
//    self.cameraModelChangeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.cameraModelChangeBtn.layer.masksToBounds = YES;
//    self.cameraModelChangeBtn.layer.borderWidth = 1;
    [self.cameraModelChangeBtn addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [_topSlideView addSubview:self.cameraModelChangeBtn];
    //闪光灯控制按钮
    
    self.openFlashBtn = [[VJ_CameraFlashBtn alloc]init];
    self.openFlashBtn.frame = CGRectMake(Screen_Width - 120, 22, 40, 40);
//    self.openFlashBtn.layer.borderWidth = 1;
//    self.openFlashBtn.layer.masksToBounds = YES;
//    self.openFlashBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.openFlashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    [_topSlideView addSubview:self.openFlashBtn];
    
    
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


#pragma mark - 视频模块功能
- (void)startCamera:(AVCaptureDevicePosition)captureDeviceType
{
    NSString *unUseInfo = nil;
    if (TARGET_IPHONE_SIMULATOR)
    {
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
    if (unUseInfo != nil)
    {
        _statusInfo.text = unUseInfo;
        _statusInfo.hidden = NO;
        _eyeView = [[KZEyeView alloc] initWithFrame:_videoView.bounds];
        [_videoView addSubview:_eyeView];
        return;
    }
    
    // 创建录制线程
    _recoding_queue = dispatch_queue_create("com.kzsmallvideo.queue", DISPATCH_QUEUE_SERIAL);
    
    
    // 新的代码
    //视频设备配置为摄像头
    NSError * vError = nil;
    NSError * aError = nil;
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:captureDeviceType];
    _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&vError];
    
    //添加一个音频输入设备
    _audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioDevice error:&aError];
    
    //视频保存文件操作
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //初始化Session
    _videoSession = [[AVCaptureSession alloc]init];
    
    //将设备输出添加到会话中
    if ([_videoSession canAddOutput:_captureMovieFileOutput])
    {
        [_videoSession addOutput:_captureMovieFileOutput];
    }
    if ([_videoSession canAddInput:_videoDeviceInput])
    {
        [_videoSession addInput:_videoDeviceInput];
        [_videoSession addInput:_audioDeviceInput];
        _connection =[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([_connection isVideoStabilizationSupported ])
        {
            _connection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    [_videoSession beginConfiguration];
    
    //设置分辨率
    if ([_videoSession canSetSessionPreset:AVCaptureSessionPresetMedium])
    {
        _videoSession.sessionPreset = AVCaptureSessionPresetMedium;
    } else
    {
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
    
    [self VideoViewWillAppear];
}

/**
 * 判断摄像头的设备是否可用，并使启用默认设备
 */
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}



- (void)VideoViewWillAppear
{
    _eyeView = [[KZEyeView alloc] initWithFrame:_videoView.bounds];
    [_videoView addSubview:_eyeView];
}

- (void)VideoViewDidAppear {
    
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
    } completion:^(BOOL finished)
    {
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

#pragma mark - deviceAction --
/**
 * 前后置摄像头切换
 */
- (void)changeCamera:(id)sender
{
    NSError * error;
    if ([_videoDevice lockForConfiguration:&error]) {
        [self stopCamera];
        if(self.cameraModelChangeBtn.cameraType == BackCamera)
        {
            self.openFlashBtn.hidden = YES;
//            [self.openFlashBtn setCameraFlashOFF];
            [self startCamera:AVCaptureDevicePositionFront];
        } else
        {
            [self startCamera:AVCaptureDevicePositionBack];
            self.openFlashBtn.hidden = NO;
        }
        [self.cameraModelChangeBtn touchCameraBtn];
        [_videoDevice unlockForConfiguration];
    } else
    {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

/**
 * 打开闪光灯响应
 */
- (void) openFlash:(id)sender {
    NSError * error = nil;
    if([_videoDevice lockForConfiguration:&error]){
        //判断当前按钮状态
        if(self.openFlashBtn.flashState == FlashOn)
        {
            [_videoDevice setTorchMode:AVCaptureTorchModeOff];
            [_videoDevice setFlashMode:AVCaptureFlashModeOff];
        }
        else
        {
            [_videoDevice setTorchMode:AVCaptureTorchModeOn];
            [_videoDevice setFlashMode:AVCaptureFlashModeOn];
        }
        [self.openFlashBtn touchCameraFlashBtn];
        [_videoDevice unlockForConfiguration];
    } else {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}



/**
 * 关闭相机
 */
-(void)stopCamera
{
    
    
    [_videoSession stopRunning];
//    [_videoPreLayer removeFromSuperlayer];
//    _videoPreLayer = nil;
//    [_videoView removeFromSuperview];
//    _videoView = nil;

    _videoDevice = nil;
    
//    [self setupSubViews];
//    [self VideoViewDidAppear];
//    [self VideoViewWillAppear];
    
    self.actionView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight([KZVideoConfig viewFrameWithType:_Typeshowing]));
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.actionView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.4];
    } completion:^(BOOL finished) {
        [self VideoViewDidAppear];
    }];



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

- (void)ctrollVideoDidEnd:(KZControllerBar *)controllerBar
{
    _topSlideView.isRecoding = NO;
    _recoding = NO;
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





#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate 摄像头画面代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"开始录制...");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
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
                        
                        
//                        LLShareViewController *shareVC = [[LLShareViewController alloc]init];
//                        shareVC.thumbImage = image;
//                                self.delegate = shareVC;
                        //        [self.navigationController pushViewController:shareVC animated:YES];
//                                if (_delegate)
//                                {
//                                    [_delegate videoViewController:self didRecordVideo:_currentRecord];
                        //            [self endAniamtion];
                        
//                                }
                        NSDictionary *dictionary = @{@"videoPic" : image};
                        [self openURL:[self.url URLByAppendingPathComponent:@"share"] params:dictionary animated:YES];

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
