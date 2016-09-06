//
//  LLProfileEditViewController.m
//  jYouQuan
//
//  Created by Corporal on 16/9/5.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLProfileEditViewController.h"
#import "LLPasswordTableViewCell.h"
#import "LLAvatorTableViewCell.h"
#import "LLNickNameTableViewCell.h"
#import "LLUser.h"




@interface LLProfileEditViewController () <UITableViewDelegate, UITableViewDataSource>
{
    
    LLUserService *userService;
    OllaImagePickerController *imagePickerController;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LLUser *user;
@property (nonatomic, strong) UIImage *avatorImage;

@end

@implementation LLProfileEditViewController

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserNameState:) name:@"OllaNicknameChangeNotification" object:nil];
    [super viewDidLoad];
    self.user = self.params;
    userService = [[LLUserService alloc] init];
    // Do any additional setup after loading the view from its nib.
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStyleGrouped];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LLAvatorTableViewCell" bundle:nil] forCellReuseIdentifier:@"avatorEdit"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LLNickNameTableViewCell" bundle:nil] forCellReuseIdentifier:@"nicknameEdit"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LLPasswordTableViewCell" bundle:nil] forCellReuseIdentifier:@"passwordEdit"];
   

    
}

- (void)changeUserNameState:(NSNotification*)notification
{
    self.user.nickname = notification.object;
    [self.tableView reloadData];
    //上传网络
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        LLAvatorTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"avatorEdit" forIndexPath:indexPath]; // 这句话要放在括号里面, 不然会重复覆盖多层
        [cell1.avatorImage sd_setImageWithURL:[NSURL URLWithString:self.user.avatar]];
        cell1.nickNameLb.text = self.user.nickname;
        

        return cell1;
    }
    else if (indexPath.section == 1)
    {
        LLNickNameTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"nicknameEdit" forIndexPath:indexPath];
        cell2.nicknameLB.text = self.user.nickname;
        cell2.nicknameLB.textAlignment = NSTextAlignmentRight;
        return cell2;
    }
    else
    {
        LLPasswordTableViewCell *cell3 = [tableView dequeueReusableCellWithIdentifier:@"passwordEdit" forIndexPath:indexPath];
        return cell3;
    }
    
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return 100;
    }
    else
    {
        return 44;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 0:
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
            break;
        
        case 1:
        {
            // edit-name
            [self openURL:[self.url URLByAppendingPathComponent:@"edit-name"] animated:YES];
            
            
            
        }
            break;
            case 2:
        {
            // edit-password
            [self openURL:[self.url URLByAppendingPathComponent:@"edit-password"] animated:YES];
//            LLTextXIBViewController *VC = [[LLTextXIBViewController alloc]init];
//            [self presentViewController:VC animated:YES completion:NULL];
            
            
        }
            break;
        default:
            break;
    }
    
    
    
    
}


- (void)updateAvatorWithImage:(UIImage *)image
{
    
    
    //先设置好封面，再上传
//    self.avatorButoon.image = image;
    //    [coverImageView setImage:image];
    // ***** 保存封面图片到本地  以供其他地方使用
    UIImageView *imageView = [self.view viewWithTag:10];
    imageView.image = image;
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


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
