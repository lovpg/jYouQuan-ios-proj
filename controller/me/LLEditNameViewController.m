//
//  LLEditNameViewController.m
//  Olla
//
//  Created by nonstriater on 14-7-15.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLEditNameViewController.h"
#import "LLHTTPRequestOperationManager.h"

extern NSString *OllaNicknameChangeNotification;

@interface LLEditNameViewController ()
{
    LLUserService *userService;
}

@property (nonatomic, strong) UITextField *nameTextField;;


@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;




@end

@implementation LLEditNameViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 更换返回按钮图标
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backer"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finish"] style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    self.title = @"修改昵称";
    self.backGroundImage.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.9];
    _nameTextField = [[UITextField alloc]initWithFrame:CGRectMake(5, 95, Screen_Width - 10, 30)];
    _nameTextField.backgroundColor = [UIColor whiteColor];
    _nameTextField.layer.cornerRadius = 3;
    _nameTextField.clipsToBounds = YES;
    [self.backGroundImage addSubview:_nameTextField];
    
    userService = [[LLUserService alloc] init];
    _nameTextField.text = [userService getMe].nickname;
    
}

- (void)back
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [_nameTextField becomeFirstResponder];
}


- (void)save:(id)sender{
    
    if (![self checkInputLegal])
    {
        return;
    }
    
    //上传网络
    __weak typeof(self) weakSelf = self;
    [userService updateUserName:_nameTextField.text success:^(NSDictionary *userInfo) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf successHandler:userInfo];
    } fail:^(NSError *error) {
        DDLogError(@"更新昵称 error:%@",error);
    }];

}

- (void)successHandler:(id)result{

    //通知其他页面跟新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaNicknameChangeNotification" object:_nameTextField.text];
    //[self openURL:[NSURL URLWithString:@"olla:///nav-me/me-refactor/setting/edit-profile"] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)checkInputLegal{
    if ([_nameTextField.text length]==0) {
        
        [UIAlertView showWithTitle:@"nickname must not be empty" message:nil cancelButtonTitle:@"Got it" otherButtonTitles:nil tapBlock:nil];
        
        return NO;
    }
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
