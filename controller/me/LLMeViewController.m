//
//  LLMeViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLMeViewController.h"
#import "LLUserService.h"
#import "LLUser.h"


@interface LLMeViewController ()
{
    LLUserService *userService;
    OllaImagePickerController *imagePickerController;
}

@property(nonatomic, strong) LLUser *user;

@end

@implementation LLMeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
//        UIImage *aimage = [UIImage imageNamed:@"qrcode_scan"];
//        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image
//                                                                      style:UIBarButtonItemStylePlain
//                                                                     target:self
//                                                                     action:@selector(codeScan:)];
//        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    }
    return self;
}

- (IBAction)codeScan:(id)sender
{
    if (!imagePickerController)
    {
        imagePickerController = [[OllaImagePickerController alloc] initWithViewController:self];
        imagePickerController.allowsEditing = YES;
    }
    
    // 选择图片完成时的操作
    __weak typeof(self) weakSelf = self;
    imagePickerController.completeBlock = ^(OllaImagePickerController *controller,UIImage *image)
    {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf updateAvatorWithImage:image];
    };
    
    // 更换封面选项
    [UIActionSheet showFromTabBar:[self tabbar]
                        withTitle:@"更新头像"
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:nil
                otherButtonTitles:@[@"拍照",@"从相册中选择"]
                         tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex)
     {
         
         if (0==tapIndex) {//camera
             //默认 camera
             [imagePickerController setImagePickerType:OllaImagePickerCamera];
             [imagePickerController picker];
             
         }else if(1==tapIndex){// album
             
             [imagePickerController setImagePickerType:OllaImagPickerAlbum];
             [imagePickerController picker];
             
         }
         
     }];
}



// 点击该cell进入编辑界面
- (IBAction)editProfileAction:(id)sender
{
    [self openURLhidesBottomBarWhenPushed:[self.url URLByAppendingPathComponent:@"setting-profile"] params:self.user animated:YES];
    
}

- (IBAction)categroyUpdateAction:(id)sender
{
    [self openURL:[NSURL URLWithString:@"present:///dev-catagory"] params:@"equipType" animated:YES];
}



- (IBAction)updateAvatorAction:(id)sender
{

}

- (void)updateAvatorWithImage:(UIImage *)image
{
    
    //先设置好封面，再上传
    self.avatorButoon.image = image;
    //    [coverImageView setImage:image];
    // ***** 保存封面图片到本地  以供其他地方使用
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData;
    if (UIImagePNGRepresentation(image) == nil)
    {
        imageData = UIImageJPEGRepresentation(image, 100);
    }
    else
    {
        imageData = UIImagePNGRepresentation(image);
    }
    [defaults setObject:imageData forKey:@"avatorImageData"];
    [defaults synchronize];//用synchronize方法把数据持久化到standardUserDefaults数据库
    
    [userService updateAvatar:image success:^(NSDictionary *userInfo)
     {
         
         NSString *remoteURL = userInfo[@"data"];//cover
         [[SDImageCache sharedImageCache] storeImage:image forKey:remoteURL];//这里如果能手工建立头像的url缓存，下次进来就不用闪一下了。
         
     }
                         fail:^(NSError *error)
     {
         [JDStatusBarNotification showWithStatus:@"更新头像失败" dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     }];
    
    
    
    
    
}

- (UITabBar *)tabbar
{
    return self.tabBarController.tabBar;
}


- (void)viewWillAppear:(BOOL)animated
{
    if (!userService)
    {
        userService = [[LLUserService alloc] init];
    }
    self.user  = [userService getMe];
    [userService get:self.user.uid
             success:^(LLUser *user)
     {
         if( ![user.points isEqualToString:self.pointsLabel.text ] )
         {
            self.pointsLabel.text = user.points;
         }
         [userService updateValue:user.points forKey:@"points"];
     }
                fail:^(NSError *error)
     {
         
     }];
    self.nicknameLabel.text = self.user.nickname;
    self.usernameLabel.text = self.user.userName;
    self.pointsLabel.text = self.user.points;
    if( !(self.user.equipType == nil) && ![self.user.equipType isEmpty] )
    {
        self.equipType.text = self.user.equipType;
    }
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSData *imageData =[defaults objectForKey:@"avatorImageData"];
    if(imageData)
    {
        self.avatorButoon.image = [UIImage imageWithData:imageData];
    }
    else
    {
        [self.avatorButoon sd_setImageWithURL:[NSURL URLWithString:self.user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
    }
    
    

}

- (void) viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserNameState:) name:@"OllaNicknameChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(categorySelectedHandler:)
                                                 name:@"LLCatatoryChooseNotification"
                                               object:nil];
    
    self.avatorButoon.thumbSize = CGSizeMake(60, 60);
    
}

- (void)changeUserNameState:(NSNotification*)notification
{
    self.nicknameLabel.text = notification.object;
    
}
- (void)categorySelectedHandler:(NSNotification *)notification
{
    
    NSString *categroy = [notification.userInfo valueForKey:@"categroy"];
    self.equipType.text = categroy;
    __weak typeof(self) weakSelf = self;
    [userService updateEquipType:categroy
                         success:^(NSDictionary *userInfo)
    {
         weakSelf.equipType.text = categroy;
        
    }
                            fail:^(NSError *error)
    {
        DDLogError(@"更新设备类型 error:%@",error);
    }];
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
