//
//  LLPasswordEditViewController.m
//  jYouQuan
//
//  Created by Corporal on 16/9/6.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLPasswordEditViewController.h"

@interface LLPasswordEditViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;


@property (weak, nonatomic) IBOutlet UIImageView *backGroundImage;


@end

@implementation LLPasswordEditViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // _passwordTextField.secureTextEntry = YES;// 密码模式,加密
    self.passwordTextField.secureTextEntry = YES;
    self.confirmPasswordTextField.secureTextEntry = YES;
    
    
    // 更换返回按钮图标
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"backer"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"finish"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(finish:)];
   
    // 这里要设置成UITapGestureRecognizer, 不要设置成UTGestureRecognizer, 不然没有点击效果
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToHideKeyboard:)];
    self.backGroundImage.userInteractionEnabled = YES;
    [self.backGroundImage addGestureRecognizer:tap];
    self.backGroundImage.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.9];

}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)finish:(id)sender {
    
    NSString *password = self.passwordTextField.text;
    NSString *confirmPassword = self.confirmPasswordTextField.text;
    
    if (!password.length || !confirmPassword.length) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"密码不能为空." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
        return;
    }
    
    if (![password isEqualToString:confirmPassword]) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"两次输入的密码不一致." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self showHudInView:self.view hint:nil];
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:TM_API_Edit_Password parameters:@{@"password":password} success:^(id datas, BOOL hasNext) {
        
        [weakSelf hideHud];
//                [(LLAppDelegate *)[UIApplication sharedApplication].delegate logout]; // 这里不用这句
         [(AppDelegate *)self.context logout];
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [weakSelf hideHud];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:@"更改密码失败, 请重试." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertview show];
    }];
}

- (void)tapToHideKeyboard:(UITapGestureRecognizer *)tap
{
    [self.passwordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
