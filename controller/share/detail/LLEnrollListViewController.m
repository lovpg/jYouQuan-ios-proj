//
//  LLEnrollListViewController.m
//  iDleChat
//
//  Created by Reco on 16/3/4.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LLEnrollListViewController.h"
#import "LLEnroll.h"
#import "LLLoadingView.h"

@interface LLEnrollListViewController ()
{
    LLUserService *userService;
}

@property (nonatomic, strong) NSMutableArray *fullLikeList;

@property (nonatomic, strong) LLLoadingView *loadingView;

@end

@implementation LLEnrollListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        userService = [[LLUserService alloc] init];
        
        _fullLikeList = [NSMutableArray array];
        _enrollList = [NSMutableArray array];
    }
    return self;
}

- (void)requestAndShowLikeUsers:(UIScrollView *)scrollView andURL:(NSString *)url andParams:(NSDictionary *)params {
    [self showHudInView:self.view hint:nil];
    
    __weak __block typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:url parameters:params success:^(id datas, BOOL hasNext) {
        
        [self hideHud];
        
        NSMutableArray *enrollArr = [NSMutableArray array];
        for (NSDictionary *dic in datas)
        {
            LLEnroll *enroll = [[LLEnroll alloc] init];
            
            enroll.uid = [dic objectForKey:@"uid"];
            enroll.avatar = [dic objectForKey:@"avatar"];
            enroll.sign = [dic objectForKey:@"sign"];
            enroll.voice = [dic objectForKey:@"voice"];
            enroll.distanceText = [dic objectForKey:@"distanceText"];
            enroll.gender = [dic objectForKey:@"gender"];
            enroll.goodCount = [dic objectForKey:@"goodCount"];
            enroll.location = [dic objectForKey:@"location"];
            enroll.nickname = [dic objectForKey:@"nickname"];
            enroll.username = [dic objectForKey:@"username"];
            [userService get:[dic objectForKey:@"uid"]
            success:^(LLUser *user)
            {
                LLSimpleUser *su = [[LLSimpleUser alloc] init];
                su.uid = user.uid;
                su.userName = user.userName;
                su.avatar = user.avatar;
                su.nickname = user.nickname;
                su.gender = user.gender;
                su.region = user.region;
                enroll.user = user;
                enroll.user.userName = enroll.username;
            }
            fail:^(NSError *error)
             {
                
             }];
            
            [enrollArr addObject:enroll];
        }
        
        //            weakSelf.fullLikeList = [likeArr mutableCopy];
        weakSelf.enrollList = [enrollArr mutableCopy];
        
        // *****
        NSInteger count = weakSelf.enrollList.count;
        if (count == 0)
        {
            return;
        }
        
        float height = count * 100;
        
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 15, self.view.width - 10, height)];
        listView.backgroundColor = [UIColor whiteColor];
        listView.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
        listView.layer.borderWidth = 0.5;
        listView.layer.masksToBounds = YES;
        listView.layer.cornerRadius = 5;
        for (int i=0; i<count; i++)
        {
            UIView *enrollCell = [[UIView alloc] initWithFrame:CGRectMake(5, 15 + i * 100, self.view.width - 10, 100)];
            enrollCell.backgroundColor = [UIColor whiteColor];
            enrollCell.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
            enrollCell.layer.borderWidth = 0;
            enrollCell.layer.masksToBounds = YES;
            LLEnroll *enroll = self.enrollList[i];
            LLSimpleUser *goodUser = self.enrollList[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake( 5, 5, 60, 60);
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = button.width / 2;
            button.tag = i;
            [button addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textColor = RGB_HEX(0xa8a8a8);
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(button.right + 10, button.top, button.width, 15);
            
            
            UIImageView *genderImageView = [[UIImageView alloc] init];
            genderImageView.frame = CGRectMake(label.right + 10, label.top, 16, 16);
            if ([goodUser.gender isEqualToString:@"男"]) {
                genderImageView.image = [UIImage imageNamed:@"sex_male"];
            } else if ([goodUser.gender isEqualToString:@"女"]) {
                genderImageView.image = [UIImage imageNamed:@"sex_female"];
            } else if ([goodUser.gender isEqualToString:@"gay"]) {
                genderImageView.image = [UIImage imageNamed:@"sex_gay"];
            } else {
                genderImageView.image = [UIImage imageNamed:@"sex_secret"];
            }
            
            UILabel *enrollContent = [[UILabel alloc] init];
            enrollContent.backgroundColor = [UIColor clearColor];
            enrollContent.font = [UIFont systemFontOfSize:14];
            enrollContent.textColor = RGB_HEX(0x000000);
            enrollContent.textAlignment = NSTextAlignmentLeft;
            enrollContent.frame = CGRectMake(button.right + 16, button.top + 40, self.view.width - button.width - 20, 15);
            
            [enrollCell addSubview:button];
            [enrollCell addSubview:label];
            [enrollCell addSubview:genderImageView];
            [enrollCell addSubview:enrollContent];
            
            [listView addSubview:enrollCell];
            
            NSURL *url = [NSURL URLWithString:goodUser.avatar];
            [button sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
            label.text = goodUser.nickname;
            NSString *enrollInfo = [enroll.username stringByAppendingString: @"   [已报名]" ];
            enrollContent.text = enrollInfo;
        }
        
        [scrollView addSubview:listView];
        scrollView.contentSize = CGSizeMake(self.view.width, listView.bottom);
        // *****
        
    } failure:^(NSError *error) {
        
        [self hideHud];
        NSLog(@"获取完整点赞列表失败");
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.enrollList = [NSMutableArray array];
    self.loadingView = [[LLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    
    [self.view addSubview:scrollView];
    
    [scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(68, 0, 0, 0)];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    NSDictionary *paramsDic = self.params;
    
    NSString *url = nil;
    // 判断@"share"  @"groupBarPost"
    if ([[paramsDic objectForKey:@"type"] isEqualToString:@"share"]) {
        
//        url = Olla_API_Share_EnrollList;
//        NSDictionary *param = @{@"shareId":[self.params objectForKey:@"shareId"], @"pageId":@(1), @"size":@(1000)};
//        [self requestAndShowLikeUsers:scrollView andURL:url andParams:param];
        
    } else if ([[paramsDic objectForKey:@"type"] isEqualToString:@"groupBarPost"]) {
        
        url = Olla_API_Groupbar_Post_GoodList;
        //        url = Olla_API_Share_GoodList;
        NSDictionary *param = @{@"postId":[self.params objectForKey:@"shareId"], @"pageId":@(1), @"size":@(1000)};
        [self requestAndShowLikeUsers:scrollView andURL:url andParams:param];
        
    } else if ([[paramsDic objectForKey:@"type"] isEqualToString:@"crown"]) {
        
        self.enrollList = [paramsDic objectForKey:@"enrollList"];
        
        NSInteger count = self.enrollList.count;
        if (count == 0) {
            return;
        }
        
        float height = ceilf((float)count / 4) * 105;
        
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 15, self.view.width - 10, height)];
        listView.backgroundColor = [UIColor whiteColor];
        listView.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
        listView.layer.borderWidth = 0.5;
        listView.layer.masksToBounds = YES;
        listView.layer.cornerRadius = 5;
        
        float gap = (listView.width - 250) / 3;
        for (int i=0; i<count; i++) {
            int row = (floorf((float)i / 4));
            int col = i;
            if (i>=4) {
                col = i % 4;
            }
            
            LLSimpleUser *goodUser = self.enrollList[i];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            button.frame = CGRectMake(5 + col * (60 + gap), 15 + row * 90, 60, 60);
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = button.width / 2;
            button.tag = i;
            [button addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = RGB_HEX(0xa8a8a8);
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectMake(button.left, button.bottom+5, button.width, 15);
            
            [listView addSubview:button];
            [listView addSubview:label];
            
            NSURL *url = [NSURL URLWithString:goodUser.avatar];
            [button sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
            label.text = goodUser.nickname;
        }
        
        [scrollView addSubview:listView];
        scrollView.contentSize = CGSizeMake(self.view.width, listView.bottom);
    }
    
    // *****
    
    
}


- (void)avatarClick:(UIButton *)button
{
    LLSimpleUser *user = [self.enrollList objectAtIndex:button.tag];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
    [dict setValue:@1 forKey:@"flag"];
    
    NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"im"] queryValue:dict];
    [self openURL:url animated:YES];
}
- (IBAction)back:(id)sender
{
    NSLog("@%@", [self.url urlPath]);
    NSString *urlCheck = [self.url urlPath];
    if([urlCheck.trim isEqualToString:@"present:/root/plaza/me/share-detail/enrolllist"])
    {
       [self openURL:[self.url URLByAppendingPathComponent:@"me"] params:nil animated:YES];
    }
    else if ([urlCheck.trim isEqualToString:@"present:/root/plaza/chats/share-detail/enrolllist"])
    {
        [self openURL:[self.url URLByAppendingPathComponent:@"chats"] params:nil animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
