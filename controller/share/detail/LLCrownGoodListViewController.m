//
//  LLCrownGoodListViewController.m
//  Olla
//
//  Created by Pat on 15/4/29.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLCrownGoodListViewController.h"
#import "LLLike.h"
#import "LLLoadingView.h"

@interface LLCrownGoodListViewController () {
    
    LLUserService *userService;
}

@property (nonatomic, strong) NSMutableArray *fullLikeList;

@property (nonatomic, strong) LLLoadingView *loadingView;

@end

@implementation LLCrownGoodListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        userService = [[LLUserService alloc] init];
        
        _fullLikeList = [NSMutableArray array];
        _goodList = [NSMutableArray array];
    }
    return self;
}

- (void)requestAndShowLikeUsers:(UIScrollView *)scrollView andURL:(NSString *)url andParams:(NSDictionary *)params {
    [self showHudInView:self.view hint:nil];
    
    __weak __block typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:url parameters:params success:^(id datas, BOOL hasNext) {
        
        [self hideHud];
        
        NSMutableArray *likeArr = [NSMutableArray array];
        for (NSDictionary *dic in datas) {
            LLLike *like = [[LLLike alloc] init];
            
            like.uid = [dic objectForKey:@"uid"];
            like.avatar = [dic objectForKey:@"avatar"];
            like.sign = [dic objectForKey:@"sign"];
            like.voice = [dic objectForKey:@"voice"];
            like.distanceText = [dic objectForKey:@"distanceText"];
            like.gender = [dic objectForKey:@"gender"];
            like.goodCount = [dic objectForKey:@"goodCount"];
            like.location = [dic objectForKey:@"location"];
            like.nickname = [dic objectForKey:@"nickname"];
            
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
                like.user = su;

                
            } fail:^(NSError *error) {
                
            }];
            
            [likeArr addObject:like];
        }
        
        //            weakSelf.fullLikeList = [likeArr mutableCopy];
        weakSelf.goodList = [likeArr mutableCopy];
        
        // *****
        NSInteger count = weakSelf.goodList.count;
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
            
            LLSimpleUser *goodUser = self.goodList[i];
            
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
            [button sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
            label.text = goodUser.nickname;
        }
        
        [scrollView addSubview:listView];
        scrollView.contentSize = CGSizeMake(self.view.width, listView.bottom);
        // *****
        
    } failure:^(NSError *error) {
        
        [self hideHud];
        NSLog(@"获取完整点赞列表失败");
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.goodList = [NSMutableArray array];
    
    self.loadingView = [[LLLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    
    self.title = @"Like list";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    
    [self.view addSubview:scrollView];
    
    [scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(68, 0, 0, 0)];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    //    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, self.view.width - 10, 95)];
    //    userView.backgroundColor = [UIColor whiteColor];
    //    userView.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
    //    userView.layer.borderWidth = 0.5;
    //    userView.layer.masksToBounds = YES;
    //    userView.layer.cornerRadius = 5;
    //
    //    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 75, 75)];
    //    coverView.layer.masksToBounds = YES;
    //    coverView.layer.cornerRadius = coverView.width / 2;
    //    NSURL *url = [NSURL URLWithString:self.user.avatar];
    //    [coverView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
    //    [userView addSubview:coverView];
    //
    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(coverView.right + 15, 32.5, 240, 30)];
    //    label.font = [UIFont systemFontOfSize:19];
    //    label.textColor = RGB_HEX(0x333333);
    //    label.text = self.user.nickname;
    //    [userView addSubview:label];
    //    [scrollView addSubview:userView];
    
    // *****
    //    self.goodList = self.params; // 传入参数改为字典,需根据type来发送请求
    
    // *****
    NSDictionary *paramsDic = self.params;
    
    NSString *url = nil;
    // 判断@"share"  @"groupBarPost"
    if ([[paramsDic objectForKey:@"type"] isEqualToString:@"share"]) {
        
        url = Olla_API_Share_GoodList;
        NSDictionary *param = @{@"shareId":[self.params objectForKey:@"shareId"], @"pageId":@(1), @"size":@(1000)};
        [self requestAndShowLikeUsers:scrollView andURL:url andParams:param];
        
    } else if ([[paramsDic objectForKey:@"type"] isEqualToString:@"groupBarPost"]) {
        
        url = Olla_API_Groupbar_Post_GoodList;
        //        url = Olla_API_Share_GoodList;
        NSDictionary *param = @{@"postId":[self.params objectForKey:@"shareId"], @"pageId":@(1), @"size":@(1000)};
        [self requestAndShowLikeUsers:scrollView andURL:url andParams:param];
        
    } else if ([[paramsDic objectForKey:@"type"] isEqualToString:@"crown"]) {
        
        self.goodList = [paramsDic objectForKey:@"goodList"];
        
        NSInteger count = self.goodList.count;
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
            
            LLSimpleUser *goodUser = self.goodList[i];
            
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

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.title = @"Like list";
//    self.view.backgroundColor = [UIColor whiteColor];
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    scrollView.backgroundColor = RGB_DECIMAL(247, 247, 247);
//    
//    [self.view addSubview:scrollView];
//    
//    [scrollView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
//    
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }
//    
////    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake(5, 10, self.view.width - 10, 95)];
////    userView.backgroundColor = [UIColor whiteColor];
////    userView.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
////    userView.layer.borderWidth = 0.5;
////    userView.layer.masksToBounds = YES;
////    userView.layer.cornerRadius = 5;
////    
////    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 10, 75, 75)];
////    coverView.layer.masksToBounds = YES;
////    coverView.layer.cornerRadius = coverView.width / 2;
////    NSURL *url = [NSURL URLWithString:self.user.avatar];
////    [coverView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
////    [userView addSubview:coverView];
////    
////    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(coverView.right + 15, 32.5, 240, 30)];
////    label.font = [UIFont systemFontOfSize:19];
////    label.textColor = RGB_HEX(0x333333);
////    label.text = self.user.nickname;
////    [userView addSubview:label];
////    [scrollView addSubview:userView];
//    
//    self.goodList = self.params;
//    
//    NSInteger count = self.goodList.count;
//    if (count == 0) {
//        return;
//    }
//    
//    float height = ceilf((float)count / 4) * 105;
//    
//    UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(5, 15, self.view.width - 10, height)];
//    listView.backgroundColor = [UIColor whiteColor];
//    listView.layer.borderColor = RGB_DECIMAL(211, 212, 213).CGColor;
//    listView.layer.borderWidth = 0.5;
//    listView.layer.masksToBounds = YES;
//    listView.layer.cornerRadius = 5;
//    
//    float gap = (listView.width - 250) / 3;
//    for (int i=0; i<count; i++) {
//        int row = (floorf((float)i / 4));
//        int col = i;
//        if (i>=4) {
//            col = i % 4;
//        }
//
//        LLSimpleUser *goodUser = self.goodList[i];
//        
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        
//        button.frame = CGRectMake(5 + col * (60 + gap), 15 + row * 90, 60, 60);
//        button.layer.masksToBounds = YES;
//        button.layer.cornerRadius = button.width / 2;
//        button.tag = i;
//        [button addTarget:self action:@selector(avatarClick:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UILabel *label = [[UILabel alloc] init];
//        label.backgroundColor = [UIColor clearColor];
//        label.font = [UIFont systemFontOfSize:12];
//        label.textColor = RGB_HEX(0xa8a8a8);
//        label.textAlignment = NSTextAlignmentCenter;
//        label.frame = CGRectMake(button.left, button.bottom+5, button.width, 15);
//        
//        [listView addSubview:button];
//        [listView addSubview:label];
//        
//        NSURL *url = [NSURL URLWithString:goodUser.avatar];
//        [button sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
//        label.text = goodUser.nickname;
//    }
//    
//    [scrollView addSubview:listView];
//    scrollView.contentSize = CGSizeMake(self.view.width, listView.bottom);
//    
//}

- (void)avatarClick:(UIButton *)button {
    LLSimpleUser *user = [self.goodList objectAtIndex:button.tag];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
    [dict setValue:@1 forKey:@"flag"];
    
    NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"im"] queryValue:dict];
    [self openURL:url animated:YES];
}
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
