//
//  SignupViewController.m
//  iDleChat
//
//  Created by Reco on 16/1/26.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "SignupViewController.h"
#import "AppDelegate.h"
#import "LLLoginService.h"
#import "LLLoginAuth.h"
#import "LLSignupService.h"

@interface SignupViewController ()
{
    LLLoginService *loginService;
    LLLoginAuth *userAuth;
    LLSignupService *signupService;
    BOOL isRead;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nocationView;
@property (weak, nonatomic) IBOutlet UIButton *userPortocolButton;

@property (weak, nonatomic) IBOutlet UIButton *codeLable;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginService = [[LLLoginService alloc] init ];
    userAuth = [[loginService loginAuthDAO] get];
    signupService = [[LLSignupService alloc]init];
    self.username.placeholder = @"请输入手机号接收验证码";
    self.password.placeholder = @"请设置密码";
    self.password.clearsOnBeginEditing = YES;
    self.password.secureTextEntry = YES;
    self.codeLabel.placeholder = @"验证码";
    self.nocationView.hidden = YES;
    isRead = FALSE;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.userPortocolButton.text];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange]; 
    [self.userPortocolButton setAttributedTitle:str forState:UIControlStateNormal];
    self.userPortocolButton.textColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (IBAction)signup:(id)sender
{
    if(!isRead)
    {
        [UIAlertView showWithTitle:nil message:@"请仔细阅读拾里用户使用协议" cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    self.nocationView.hidden = NO;
    NSString *mobile = self.username.text;
    NSString *passwd = self.password.text;
    NSString *code = self.codeLabel.text;
//    if ([[LLEaseModUtil sharedUtil] isLoggedIn])
//    {
//        [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:nil];
//    }
    [self signup:mobile password:passwd code:code];
    
}

- (void)signup : (NSString *)userName
       password: (NSString *)password
           code: (NSString *)code
{
    UIImage *headPhotoImage = [UIImage imageNamed:@"default_headphoto"];
    [signupService signupWithUserName:userName
                             password:password
                             code:code
                               avatar:headPhotoImage
                              success:^(LLLoginAuth *loginAuth)
     {
         self.nocationView.hidden = YES;
         [LLFMDB setIdentifier:userAuth.uid];
         [LLAPICache setIdentifier:userAuth.uid];
         [[LLHTTPRequestOperationManager shareManager] setUserAuth:userAuth];
         [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:userAuth];
         [[LLPreference shareInstance] synchronize];
         
         // 保存账户密码信息
         userAuth.username = userName;
         [[loginService loginAuthDAO]add:userAuth];
         
         NSString *easeUserName = [NSString stringWithFormat:@"%@", userAuth.uid];
         NSString *easePassword = [password MD5Encode];
         [LLAppHelper saveUserName:userName password:password];
//         [[LLEaseModUtil sharedUtil] saveUserName:easeUserName password:easePassword];
         //用户切换账号，需要重新建立长连接和文件存放目录
         [LLFMDB setIdentifier:userAuth.uid];
         [LLAPICache setIdentifier:userAuth.uid];
         //[(AppDelegate *)self.context messageManagerStart];
         [(AppDelegate *)self.context sendDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"com.lbslm.deviceToken"]];
         //  [weakSelf reset];
         [self openURL:[NSURL URLWithString:@"lbslm:///root/login/signup/fill-personal"] params:nil animated:YES];
     }
     fail:^(NSError *error)
     {
         NSLog(@"%@",error);
         NSString *message = [error.userInfo objectForKey:@"message"];
         if(!message)
         {
             message = @"未知错误";
         }
         [UIAlertView showWithTitle:nil message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
     }];
    
    
}

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendMessageCode:(id)sender
{
    NSString * mobile = self.username.text;
    if( !mobile || [mobile isEqualToString:@""])
    {
        [UIAlertView showWithTitle:nil message:@"手机号码输入错误." cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    [self securityToken:mobile];
}

- (void)securityToken : (NSString *) mobile
{
    [LLAppHelper clearCookies];
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:LBSLM_API_CODE
      parameters:@{@"mobile": mobile,
                   LLAPICacheIgnoreParamsKey : @(1)
                   }
                success:^(id datas, BOOL hasNext)
                {
                    [self startTime];
                    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
                    NSString *JSESSIONID = @"";
                    for (NSHTTPCookie *cookie in cookies)
                    {
                        if ([cookie.name isEqualToString:@"SESSIONID"])
                        {
                            JSESSIONID = cookie.value;
                        }
                    }
                   NSString *cookieStr = [NSString stringWithFormat:@"SESSIONID=%@;",JSESSIONID];
                   LLHTTPRequestOperationManager *manager =  [LLHTTPRequestOperationManager shareManager];
                   [manager.requestSerializer setValue:cookieStr forHTTPHeaderField:@"Cookie"];
                }
                failure:^(NSError *error)
                {
                    NSString *message = [error.userInfo objectForKey:@"message"];
                    if(!message)
                    {
                        message = @"未知错误";
                    }
                    [UIAlertView showWithTitle:nil message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
                }
     ];
    
}

-(void)startTime
{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_l_timeButton setBackgroundColor: RGB_HEX(0x5fc225)];
                [_l_timeButton setTextColor:[UIColor whiteColor]];
                [_l_timeButton setTitle:@"发送验证码" forState:UIControlStateNormal];
                _l_timeButton.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
               // [UIView beginAnimations:nil context:nil];
               // [UIView setAnimationDuration:1];
                [_l_timeButton setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
                [_l_timeButton setTextColor:[UIColor grayColor]];
                [_l_timeButton setTitle:[NSString stringWithFormat:@"重新发送(%@s)",strTime] forState:UIControlStateNormal];
               // [UIView commitAnimations];
                _l_timeButton.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
- (IBAction)forwordProtocolClick:(id)sender
{
    isRead = TRUE;
   [self openURL:[NSURL URLWithString:@"lbslm:///root/login/signup/web"] params:nil animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
