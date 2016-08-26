//
//  CallSessionViewController.m
//  ChatDemo-UI2.0
//
//  Created by dhcdht on 14-10-29.
//  Copyright (c) 2014年 dhcdht. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CallSessionViewController.h"
#import "UIViewController+HUD.h"
//#import "PSTAlertController+Helper.h"
#import "LLEMUserDAO.h"
#import "CallHelper.h"

#define kAlertViewTag_Close 1000

BOOL isHeadsetPluggedIn() {
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute,
                                              &routeSize,
                                              &route
                                              );
    
    
    
    if (!error && (route != NULL) && ([(__bridge NSString*)route rangeOfString:@"Head"].location != NSNotFound)) {
        return YES;
    }
    return NO;
}

void audioSessionPropertyListener_Voip(void* inClientData, AudioSessionPropertyID inID,
                                       UInt32 inDataSize, const void* inData) {
    if (isHeadsetPluggedIn()) {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    } else {
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
}

@interface CallSessionViewController ()<UIAlertViewDelegate, EMCallManagerDelegate>
{
    NSString *_chatter;
    int _callLength;
    
    int _callType;
    UIImageView *_bgImageView;
    UILabel *_statusLabel;
    UIImageView *_headerImageView;
    UILabel *_nameLabel;
    
    UILabel *_timeLabel;
    UIButton *_silenceButton;
    UILabel *_silenceLabel;
    UIButton *_speakerOutButton;
    UILabel *_outLabel;
    UIButton *_hangupButton;
    UIButton *_answerButton;
    
    AVAudioPlayer *_player;
    NSTimer *_timer;
    
    NSTimer *_vibrateTimer;
    
    LLEMUserDAO *_userDAO;
}

@property (strong, nonatomic) EMCallSession *callSession;
@property (nonatomic, assign) BOOL stopByMe;
@property (nonatomic, assign) BOOL startRingAfterEnterForeground;

@end

@implementation CallSessionViewController

@synthesize callSession = _callSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _callType = CallNone;
        _callSession = nil;
        _callLength = 0;
        
        _userDAO = [[LLEMUserDAO alloc] init];
        
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener_Voip, (__bridge  void *)self);
        
        if (!isHeadsetPluggedIn()) {
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        }
        
        [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (instancetype)initCallOutWithSession:(EMCallSession *)callSession
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _callType = CallOut;
        _callSession = callSession;
        _chatter = callSession.sessionChatter;
    }
    
    return self;
}

- (instancetype)initCallInWithSession:(EMCallSession *)callSession
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        _callType = CallIn;
        _callSession = callSession;
        _chatter = callSession.sessionChatter;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    [self _setupSubviews];
    [self _beginRing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:NULL];
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,audioSessionPropertyListener_Voip, (__bridge  void *)self);
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [_player stop];
    _player = nil;
    [_timer invalidate];
    _timer = nil;
    [_vibrateTimer invalidate];
    _vibrateTimer = nil;
}

- (LLUser *)userInfo {
    NSString *uid = [_chatter stringByReplacingOccurrencesOfString:@"" withString:@""];
    LLUser *userInfo = [_userDAO userInfoWithUID:uid];
    return userInfo;
}

#pragma mark - private

- (void)_layouSubviews
{
    LLUser *userInfo = [self userInfo];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    _statusLabel.font = [UIFont systemFontOfSize:15.0];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_statusLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_statusLabel.frame), self.view.frame.size.width, 15)];
    _timeLabel.font = [UIFont systemFontOfSize:14.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, CGRectGetMaxY(_statusLabel.frame) + 80, 100, 100)];
    _headerImageView.layer.masksToBounds = YES;
    _headerImageView.layer.cornerRadius = _headerImageView.width / 2;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
    [self.view addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 15, self.view.frame.size.width, 24)];
    _nameLabel.font = [UIFont systemFontOfSize:21.0];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_nameLabel];
    
    CGFloat tmpWidth = self.view.frame.size.width / 2;
//    _silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 40) / 2, self.view.frame.size.height - 230, 40, 40)];
//    [_silenceButton setImage:[UIImage imageNamed:@"call_silence"] forState:UIControlStateNormal];
//    [_silenceButton setImage:[UIImage imageNamed:@"call_silence_h"] forState:UIControlStateSelected];
//    [_silenceButton addTarget:self action:@selector(silenceAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_silenceButton];
    
//    _silenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_silenceButton.frame), CGRectGetMaxY(_silenceButton.frame) + 5, 40, 20)];
//    _silenceLabel.backgroundColor = [UIColor clearColor];
//    _silenceLabel.textColor = [UIColor whiteColor];
//    _silenceLabel.font = [UIFont systemFontOfSize:13.0];
//    _silenceLabel.textAlignment = NSTextAlignmentCenter;
//    _silenceLabel.text = @"mute";
//    [self.view addSubview:_silenceLabel];
    
//    _speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 40) / 2, self.view.frame.size.height - 230, 40, 40)];
//    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out"] forState:UIControlStateNormal];
//    [_speakerOutButton setImage:[UIImage imageNamed:@"call_out_h"] forState:UIControlStateSelected];
//    [_speakerOutButton addTarget:self action:@selector(speakerOutAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_speakerOutButton];
    
//    _outLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_speakerOutButton.frame) - 10, CGRectGetMaxY(_speakerOutButton.frame) + 5, 60, 20)];
//    _outLabel.backgroundColor = [UIColor clearColor];
//    _outLabel.textColor = [UIColor whiteColor];
//    _outLabel.font = [UIFont systemFontOfSize:13.0];
//    _outLabel.textAlignment = NSTextAlignmentCenter;
//    _outLabel.text = @"hands off";
//    [self.view addSubview:_outLabel];
    
    _hangupButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 103) / 2, self.view.frame.size.height - 120, 103, 43)];
    [_hangupButton setBackgroundImage:[UIImage imageNamed:@"call_hang"] forState:UIControlStateNormal];
    [_hangupButton addTarget:self action:@selector(hangupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_hangupButton];
    
    _answerButton = [[UIButton alloc] initWithFrame:CGRectMake(tmpWidth + (tmpWidth - 103) / 2, self.view.frame.size.height - 120, 103, 43)];
    [_answerButton setBackgroundImage:[UIImage imageNamed:@"call_pickup"] forState:UIControlStateNormal];
    [_answerButton addTarget:self action:@selector(answerAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)_setupSubviews
{
    [self _layouSubviews];
    
    NSString *uid = [_chatter stringByReplacingOccurrencesOfString:@"" withString:@""];
    LLUser *userInfo = [_userDAO userInfoWithUID:uid];
    
    
    if (_callType == CallIn) {
        _statusLabel.text = @"waiting to answer...";
        _nameLabel.text = userInfo.nickname;
        _timeLabel.text = @"";
        _callLength = 0;
        
        CGFloat tmpWidth = self.view.frame.size.width / 2;
        _hangupButton.frame = CGRectMake((tmpWidth - 103) / 2, self.view.frame.size.height - 120, 103, 43);
        [self.view addSubview:_answerButton];
        _silenceButton.hidden = YES;
        _silenceLabel.hidden = YES;
        _speakerOutButton.hidden = YES;
        _outLabel.hidden = YES;
        
    }
    else if (_callType == CallOut)
    {
        _statusLabel.text = @"connecting...";
        _nameLabel.text = userInfo.nickname;
        
        [_answerButton removeFromSuperview];
        _hangupButton.frame = CGRectMake((self.view.frame.size.width - 103) / 2, self.view.frame.size.height - 120, 103, 43);
        _silenceButton.hidden = NO;
        _silenceLabel.hidden = NO;
        _speakerOutButton.hidden = NO;
        _outLabel.hidden = NO;
    }
    
    
    if (_callSession) {
//        _statusLabel.text = @"通话进行中...";
//        _nameLabel.text = _chatter;
//        
//        [_answerButton removeFromSuperview];
//        _hangupButton.frame = CGRectMake((self.view.frame.size.width - 200) / 2, self.view.frame.size.height - 120, 200, 40);
//        _silenceButton.hidden = NO;
//        _silenceLabel.hidden = NO;
//        _speakerOutButton.hidden = NO;
//        _outLabel.hidden = NO;
    }
}

//- (void)_callOutWithChatter:(NSString *)chatter
//{
//    EMError *error = nil;
//    _callSession = [[EaseMob sharedInstance].callManager asyncCallAudioWithChatter:chatter timeout:50 error:&error];
//    if (error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:error.description delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
//        alertView.tag = kAlertViewTag_Close;
//        [alertView show];
//    }
//}

- (void)_close
{
    [self hideHud];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callControllerClose" object:nil];
    
    
//    self.view.hidden = YES;
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_insertMessageWithStr:(NSString *)string sender:(NSString *)sender receiver:(NSString *)receiver
{
//    NSString *string = [NSString stringWithFormat:@"[ollacall]%@",str];
    
    
    BOOL isSendMsg = [string isEqualToString:@"The other side is not online"];
    
    NSString *sendString = string;
    if (isSendMsg) {
        sendString = @"call failed";
    }
    
    EMChatText *chatText = [[EMChatText alloc] initWithText:sendString];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    NSString *messageId = [[NSString stringWithFormat:@"%@", [NSDate date]] MD5Encode];
    
    EMMessage *message = [[EMMessage alloc] initMessageWithID:messageId sender:sender receiver:receiver bodies:@[textBody]];
    message.ext = @{@"ollacall":@"1"};
    message.timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    if ([CallHelper sharedHelper].isInIMChatView) {
        message.isRead = YES;
    } else {
        message.isRead = NO;
    }
    if (isSendMsg) {
        [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil];
    } else {
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"insertCallMessage" object:message];
}

- (void)_beginRing
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        self.startRingAfterEnterForeground = YES;
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        LLUser *userInfo = [self userInfo];
        NSString *aleryBody = nil;
        if (userInfo) {
            aleryBody = [NSString stringWithFormat:@"%@ calling you...", userInfo.nickname];
        } else {
            aleryBody = @"Someone calling you...";
        }
        notification.alertBody = aleryBody;
        notification.soundName = @"notificationCallRing.m4a";
        notification.alertAction = @"Open";
        notification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    } else {
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:NULL];
        
        [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:NULL];
        
        if (_player) {
            [_player stop];
            _player = nil;
        }
        
        NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"m4r"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        [_player setVolume:1];
        _player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
        if([_player prepareToPlay])
        {
            [_player play]; //播放
            
            if (_callType == CallIn) {
                
                if (_vibrateTimer) {
                    [_vibrateTimer invalidate];
                    _vibrateTimer = nil;
                }
                _vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_vibrate) userInfo:nil repeats:YES];
            }
        }
    }
    
}

- (void)_stopRing
{
    [_player stop];
    _player = nil;
    [_vibrateTimer invalidate];
    _vibrateTimer = nil;
}

- (void)_vibrate {
    if (![[[LLPreference shareInstance] valueForKey:@"Vibrate"] boolValue]) {
        return;
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTag_Close)
    {
        [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReason_Null];
//        [[EaseMob sharedInstance].callManager asyncTerminateCallSessionWithId:_callSession.sessionId reason:eCallReason_Null];
        [self _close];
    }
}

#pragma mark - ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    
    NSString *sender = nil;
    NSString *receiver = nil;
    
    if ([_callSession.sessionId isEqualToString:callSession.sessionId])
    {
        UIAlertView *alertView = nil;
        if (error) {
            sender = [[LLEaseModUtil sharedUtil] easeUserName];
            receiver = _callSession.sessionChatter;
            
            [self _stopRing];
            
            NSString *errorMsg = @"call failed";
            
            if ([error.description isEqualToString:@"The other side is not online"]) {
                errorMsg = error.description;
            }
            
            [self _insertMessageWithStr:errorMsg sender:sender receiver:receiver];
            
            _statusLabel.text = @"connect fail";
            alertView = [[UIAlertView alloc] initWithTitle:nil message:error.description delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"OK") otherButtonTitles:nil, nil];
            alertView.tag = kAlertViewTag_Close;
            [alertView show];
        }
        else{
            
            if (self.stopByMe) {
                sender = [NSString stringWithFormat:@"%@", [[LLPreference shareInstance] uid]];
                receiver = _callSession.sessionChatter;
            } else {
                sender = _callSession.sessionChatter;
                receiver = [NSString stringWithFormat:@"%@", [[LLPreference shareInstance] uid]];
            }
            
            if (callSession.status == eCallSessionStatusDisconnected) {
                [self _stopRing];
                NSString *str = @"call finished";
                if(_callLength == 0)
                {
                    if (reason == eCallReason_Hangup) {
                        str = @"call cancelled";
                    }
                    else if (reason == eCallReason_Reject) {
                        
                        if (self.stopByMe) {
                            if (_callType == CallIn) {
                                str = @"reject call";
                            } else {
                                str = @"call cancelled";
                            }
                            
                        } else {
                            if (_callType == CallIn) {
                                str = @"call cancelled";
                            } else {
                               str = @"your call is rejected by the other side";
                            }
                        }
                    }
                    else if (reason == eCallReason_Busy){
                        str = @"the other side is busy";
                    } else {
                        str = @"call failed";
                    }
                }
                
                [self _insertMessageWithStr:str sender:sender receiver:receiver];
                
                _statusLabel.text = @"call hang up";
                [_answerButton removeFromSuperview];
                [_hangupButton removeFromSuperview];
                [self _close];
            }
            else if (callSession.status == eCallSessionStatusAccepted)
            {
                [self hideHud];
                [self _stopRing];
                [self setSpeakerEnable:NO];
                _statusLabel.text = @"speak now...";
                _callLength = 0;
                _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
                
                if(_callType == CallIn)
                {
                    [_answerButton removeFromSuperview];
                    _hangupButton.frame = CGRectMake((self.view.frame.size.width - 103) / 2, self.view.frame.size.height - 120, 103, 43);
                    _silenceButton.hidden = NO;
                    _silenceLabel.hidden = NO;
                    _speakerOutButton.hidden = NO;
                    _outLabel.hidden = NO;
                }
            }
        }
    }
}

#pragma mark - action

- (void)timerAction:(id)sender
{
    _callLength += 1;
    int hour = _callLength / 3600;
    int m = (_callLength - hour * 3600) / 60;
    int s = _callLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        if (s < 10) {
            _timeLabel.text = [NSString stringWithFormat:@"00:0%i", s];
        } else {
            _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
        }
    }
}

- (void)silenceAction:(id)sender
{
    _silenceButton.selected = !_silenceButton.selected;
    if (_silenceButton.selected) {
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:0];
    } else {
        [[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
    }
    
}

- (void)speakerOutAction:(id)sender
{
    _speakerOutButton.selected = !_speakerOutButton.selected;
    
    if (_speakerOutButton.selected) {
        [self setSpeakerEnable:YES];
    } else {
        [self setSpeakerEnable:NO];
    }
    
}

- (void)hangupAction:(id)sender
{
    self.stopByMe = YES;
    [_timer invalidate];
    [self showHint:@"hanging up..."];
    [self _stopRing];
    
    EMCallStatusChangedReason reason = eCallReason_Hangup;
    if(_callLength == 0)
    {
        reason = _callType == CallIn ? eCallReason_Reject : eCallReason_Hangup;
    } else {
    
        NSString *sender = [NSString stringWithFormat:@"%@", [[LLPreference shareInstance] uid]];
        NSString *receiver = _callSession.sessionChatter;
        
        [self _insertMessageWithStr:@"call finished" sender:sender receiver:receiver];
    }
    
    [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:reason];
    
//    [[EaseMob sharedInstance].callManager asyncTerminateCallSessionWithId:_callSession.sessionId reason:reason];

    [self _close];
}

- (void)answerAction:(id)sender
{
    [self showHint:@"wating..."];
    [self _stopRing];
    
    [[EaseMob sharedInstance].callManager asyncAnswerCall:_callSession.sessionId];
    
//    [[EaseMob sharedInstance].callManager asyncAcceptCallSessionWithId:_callSession.sessionId];
}

- (void)setSpeakerEnable:(BOOL)enable {
    if (enable) {
//        [self setBluetoothInputEnable:NO];
//        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
//        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error:NULL];
//        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:NULL];
//        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    } else {
//        [self setBluetoothInputEnable:YES];
//         [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
//        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:NULL];
//        [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:NULL];
        
    }
}

- (void)setBluetoothInputEnable:(BOOL)enable {
    UInt32 allowBluetoothInput = enable ? 1 : 0;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
                             sizeof (allowBluetoothInput),
                             &allowBluetoothInput
                             );
    
    // check the audio route
    UInt32 size = sizeof(CFStringRef);
    CFStringRef route;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
    NSLog(@"route = %@", route);
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.startRingAfterEnterForeground) {
        self.startRingAfterEnterForeground = NO;
        [self _beginRing];
    }
}

@end
