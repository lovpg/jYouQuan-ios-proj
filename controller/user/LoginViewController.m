//
//  LoginViewController.m
//  iDleChat
//
//  Created by Reco on 16/1/25.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+Hex.h"
#import "LLLoginService.h"
#import "AppDelegate.h"

@interface LoginViewController ()
{
    LLLoginService *loginService;
}

@property (weak, nonatomic) IBOutlet OllaButton *signupButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.center = self.headView.center;
    loginService = [[LLLoginService alloc] init ];
    self.userAuth = [[loginService loginAuthDAO] get];
    if ((NSInteger*)[self.userAuth .username length] > 12)
    {
        [self doAction:_signupButton];
    }
    self.indicatorView.hidden = YES;
    _passwordTextField.secureTextEntry = YES;// 密码模式,加密
    _passwordTextField.keyboardType = UIKeyboardTypeDefault;//设置键盘类型
    _passwordTextField.returnKeyType = UIReturnKeyDone;// return键名替换
    self.usernameTextFeild.placeholder = @"机手注册手机号";
    self.passwordTextField.placeholder = @"请输入密码";
    if(self.userAuth)
    {
        _usernameTextFeild.text = self.userAuth.username;
        _passwordTextField.text = @"";
    }
        
   // animationViewCenter = animationContainerView.center;

   // self.loginButton.backgroundColor = [UIColorHex colorWithHexString:@"#4cae4c"];
}




- (IBAction)login:(id)sender
{
    //还原位置
    [self viewTapGestureHandler:nil];
    [_loginButton setTitle:@"" forState:UIControlStateNormal];
    NSString *account = [self loginAccount];
    NSString *password = [self loginPassword];
    _loginButton.enabled = NO;
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
//    if ([[LLEaseModUtil sharedUtil] isLoggedIn])
//    {
//        [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:nil];
//    }
    [LLAppHelper clearCookies];
    __weak LoginViewController *weakSelf = self;
    [loginService loginWithUserName:account
                           password:password
                            success:^(LLLoginAuth *loginAuth,LLUser *user)
     {
        [LLFMDB setIdentifier:user.uid];
        [LLAPICache setIdentifier:user.uid];
        [[LLHTTPRequestOperationManager shareManager] setUserAuth:loginAuth];
        [[LLHTTPWriteOperationManager shareWriteManager] setUserAuth:loginAuth];
        [[LLPreference shareInstance] synchronize];
        // 保存账户密码信息
        NSString *easeUserName = [NSString stringWithFormat:@"%@", loginAuth.uid];
        NSString *easePassword = [password MD5Encode];
        [LLAppHelper saveUserName:account password:password];
        [[LLEaseModUtil sharedUtil] saveUserName:easeUserName password:easePassword];
        //用户切换账号，需要重新建立长连接和文件存放目录
        [LLFMDB setIdentifier:loginAuth.uid];
        [LLAPICache setIdentifier:loginAuth.uid];
        //[(AppDelegate *)self.context messageManagerStart];
        [(AppDelegate *)self.context sendDeviceToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"com.lbslm.deviceToken"]];
        [[[UIApplication sharedApplication] delegate] window].rootViewController = [self.context rootViewControllerWithURLKey:@"lbslm"];
        
    }
    fail:^(NSError *error)
    {
        NSLog(@"%@",error);
       [weakSelf loginErrorHandler:error];
    }];
}
- (void)loginErrorHandler:(NSError *)error
{
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    _loginButton.enabled = YES;
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
    
    if (error)
    {
        NSDictionary *userInfo = error.userInfo;
        if ([userInfo objectForKey:@"message"])
        {
            [UIAlertView showWithTitle:nil message:userInfo[@"message"] cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
            NSLog(@"%@",userInfo[@"message"]);
        }
        else
        {
            [UIAlertView showWithTitle:nil message:error.localizedDescription cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
        }
    }
    
    
}
- (void)reset
{
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    _loginButton.enabled = YES;
    self.indicatorView.hidden = YES;
    [self.indicatorView stopAnimating];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.userAuth .username length] > 12)
    {
        self.usernameTextFeild.text = @"";
    }
    
}


- (void)doAction:(id)sender
{
    [super doAction:sender];
    //还原位置
    [self viewTapGestureHandler:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSString *)loginAccount
{
    return _usernameTextFeild.text;
}

- (NSString *)loginPassword{
    return _passwordTextField.text;
}

//还原动画
- (void)viewTapGestureHandler:(UITapGestureRecognizer *)gesture{
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}



@end
