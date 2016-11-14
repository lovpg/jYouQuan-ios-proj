//
//  UserInfoFillContorllerViewController.m
//  iDleChat
//
//  Created by Reco on 16/3/2.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "UserInfoFillContorllerViewController.h"
#import "LLLoginService.h"
#import "LLLoginAuth.h"

@interface UserInfoFillContorllerViewController ()
{
    OllaImagePickerController *imagePickerController;
    LLUserService *userService;
    LLLoginService *loginService;
    LLLoginAuth *userAuth;
}
@property (weak, nonatomic) IBOutlet UIButton *avatorButton;

@end

@implementation UserInfoFillContorllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    userService = [[LLUserService alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)genderValueChanged:(id)sender
{
    if (self.gender.isOn)
    {
        self.genderImageView.image = [UIImage imageNamed:@"olla_filter_female_h"];
    }
    else
    {
        self.genderImageView.image = [UIImage imageNamed:@"olla_filter_male_h"];
    }
}
- (IBAction)avatarButtonClick:(id)sender
{
    [self updateAvator:nil];
}
- (IBAction)fillButtonClick:(id)sender
{
    
    NSString *nickname = self.nickname.text;
    NSString *email = self.email.text;
    NSString *sign = @"木有签名";
    NSString *gender = @"女";
    if (!self.gender.isOn)
    {
        gender = @"男";
    }
    LLUser *user = [userService getMe];
    [user setNickname:nickname];
    [user setEmail:email];
    [user setSign:sign];
    [user setGender:gender];
    [userService set:user];
    
    [userService fillSuccess:^(NSDictionary *userInfo)
    {

        NSLog(@"%@ 更新资料成功",nickname);
        [[[UIApplication sharedApplication] delegate] window].rootViewController = [self.context rootViewControllerWithURLKey:@"login"];
        
    } fail:^(NSError *error)
    {
        NSString *message = [error.userInfo objectForKey:@"message"];
        if(!message)
        {
            message = @"未知错误";
        }
        [UIAlertView showWithTitle:nil message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
    }];
    
    
}
- (UITabBar *)tabbar
{
    return self.tabBarController.tabBar;
}
- (IBAction)leakAction:(id)sender
{
            [[[UIApplication sharedApplication] delegate] window].rootViewController = [self.context rootViewControllerWithURLKey:@"login"];
}
- (void) updateAvator:(id)sender{
    
    if (!imagePickerController)
    {
        imagePickerController = [[OllaImagePickerController alloc] initWithViewController:self];
        imagePickerController.allowsEditing = YES;
    }
    
    // 选择图片完成时的操作
    __weak typeof(self) weakSelf = self;
    imagePickerController.completeBlock = ^(OllaImagePickerController *controller,UIImage *image){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateAvatorWithImage:image];
    };
    
    // 更换封面选项
    [UIActionSheet showFromTabBar:[self tabbar] withTitle:@"更换个人头像" cancelButtonTitle:@"放弃" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从像册中选择"] tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex){
        
        if (0==tapIndex) {//camera
            //默认 camera
            [imagePickerController setImagePickerType:OllaImagePickerCamera];
            [imagePickerController picker];
            
        }else if(1==tapIndex){// album
            
            [imagePickerController setImagePickerType:OllaImagPickerAlbum];
            [imagePickerController picker];
            
        }// cancel 2
        
    }];
    
    //    [imagePickerController pickerImage];
    
}
- (void)updateAvatorWithImage:(UIImage *)image
{
    
    //先设置好封面，再上传
    //[self.headImageView setImage:image];
    [self.avatorButton setImage:image];
    self.avatorButton.cornerRadius = self.avatorButton.height / 2.f;
    
    // ***** 保存封面图片到本地  以供其他地方使用
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData;
    if (UIImagePNGRepresentation(image) == nil) {
        
        imageData = UIImageJPEGRepresentation(image, 100);
        
    } else {
        
        imageData = UIImagePNGRepresentation(image);
        
    }
    [defaults setObject:imageData forKey:@"coverImageData"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
    
    [userService updateAvatar:image success:^(NSDictionary *userInfo)
     {
         NSString *remoteURL = userInfo[@"data"];//cover
         [[SDImageCache sharedImageCache] storeImage:image forKey:remoteURL];//这里如果能手工建立头像的url缓存，下次进来就不用闪一下了。
         
     }
                         fail:^(NSError *error)
     {
         [JDStatusBarNotification showWithStatus:@"封面更新失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }];
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
