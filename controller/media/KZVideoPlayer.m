//
//  KZVideoPlayer.m
//  KZWeChatSmallVideo_OC
//
//  Created by Corporal on 16/7/21.
//  Copyright © 2016年 Corporal. All rights reserved.
//

#import "KZVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>

@implementation KZVideoPlayer {
    AVPlayer *_player;
    
    UIView   *_ctrlView;
    UIView   *_backGroudView;
    CALayer  *_playStatus;
    
    UILabel  *_promptLabel;
    
    
    BOOL _isPlaying;
}

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl
{
    if (self = [super initWithFrame:frame])
    {
        _autoReplay = YES;
        _videoUrl = videoUrl;
        [self setupSubViews];
    }
    return self;
}

- (void)play {
    if (_isPlaying) {
        return;
    }
    [self tapAction];
}

- (void)stop
{
    if (_isPlaying) {
        [self tapAction];
    }
}


- (void)setupSubViews
{
    // 设置播放的项目
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_videoUrl];
    // 初始化player对象
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    
    _backGroudView = [[UIView alloc] initWithFrame:self.bounds];
    _backGroudView.backgroundColor = [UIColor blackColor];
    [self addSubview:_backGroudView];
    

//    _ctrlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Width - 50)];
    _ctrlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height - 60)];
    _ctrlView.center = self.center;
    _ctrlView.backgroundColor = [UIColor clearColor];
    [_backGroudView addSubview:_ctrlView];
    
    // 设置播放页面
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // 设置播放页面的大小
    playerLayer.frame = _ctrlView.frame;
    // 设置播放窗口和当前视图至今啊的比例显示内容
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    // 添加播放视图到_backGroundView上
    [_backGroudView.layer addSublayer:playerLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    _promptLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 40)];
    _promptLabel.center = CGPointMake(Screen_Width / 2.0, _ctrlView.bottom + 18);
    _promptLabel.font = [UIFont systemFontOfSize:15.0f];
    _promptLabel.text = @"轻触退出";
    _promptLabel.textColor = [UIColor whiteColor];
    [_backGroudView addSubview:_promptLabel];
    _promptLabel.hidden = YES;
    // 设置播放的默认音量值
    _player.volume = 1.0f;
    [_player play];
//    [self setupStatusView];
//    [self tapAction];
}

- (void)setupStatusView {
    CGPoint selfCent = CGPointMake(self.bounds.size.width/2+10, self.bounds.size.height/2);
    CGFloat width = 40;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, selfCent.x - width/2, selfCent.y - width/2);
    CGPathAddLineToPoint(path, nil, selfCent.x - width/2, selfCent.y + width/2);
    CGPathAddLineToPoint(path, nil, selfCent.x + width/2 - 4, selfCent.y);
    CGPathAddLineToPoint(path, nil, selfCent.x - width/2, selfCent.y - width/2);
    
    CGColorRef color = [UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.5].CGColor;
    
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.frame = self.bounds;
    trackLayer.strokeColor = [UIColor clearColor].CGColor;
    trackLayer.fillColor = color;
    trackLayer.opacity = 1.0;
    trackLayer.lineCap = kCALineCapRound;
    trackLayer.lineWidth = 1.0;
    trackLayer.path = path;
    [_ctrlView.layer addSublayer:trackLayer];
    _playStatus = trackLayer;
    
    CGPathRelease(path);
}

- (void)tapAction
{
//    if (_isPlaying)
//    {
//        [_player pause];
//    }
//    else
//    {
//        [_player play];
//    }
//    _isPlaying = !_isPlaying;
//    _playStatus.hidden = !_playStatus.hidden;
    [self removeFromSuperviews];
    
}

- (void)playEnd {
    
    if (!_autoReplay)
    {
        return;
    }
    [_player seekToTime:kCMTimeZero completionHandler:^(BOOL finished)
    {
        _promptLabel.hidden = NO;
        [_player play];
//        [self removeFromSuperviews];
    }];
}

- (void)removeFromSuperviews
{
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    [super removeFromSuperview];

}

- (void)dealloc
{
    NSLog(@"player dalloc");
}
@end
