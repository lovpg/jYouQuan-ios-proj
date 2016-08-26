//
//  LLBaseViewController.m
//  Olla
//
//  Created by nonstriater on 14-7-25.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBaseViewController.h"

@interface LLBaseViewController ()

@end

@implementation LLBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.needHeadBackgroundImage = YES;
   
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [AppDelegate storyBoradAutoLay:self.view];
    //navbar bg image
    if (self.needHeadBackgroundImage) {
        UIImageView *navbarBG = [[UIImageView alloc] initWithFrame:_headView.bounds];
        navbarBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //navbarBG.image = [UIImage imageNamed:@"navbar_bg"];
//        navbarBG.backgroundColor = RGB_HEX(0x6594C7);

        // 颜色rgb跟其他界面的一样,但效果却不同
//        navbarBG.backgroundColor = RGB_HEX(0x8caed3);
//        navbarBG.backgroundColor = RGB_HEX(0x8CB4D2);
        navbarBG.backgroundColor = RGB_HEX(0xe21001);
        
        
        [_headView insertSubview:navbarBG atIndex:0];
        
 
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

// 当view.bound 变化时都会触发
- (void)viewWillLayoutSubviews {
    return;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        
        //_headView.height -= 20;//如果这里多次调用，就会出问题
        _headView.height = 44.f;
        
        if ([_headView isKindOfClass:[UINavigationBar class]]) {
            [(UINavigationBar *)_headView setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
            [ (UINavigationBar *)_headView setTitleTextAttributes:  [[NSDictionary alloc] initWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil] ];
        }
        
    }
    
    // 如makefriendsvc等页面是在tabbarcontroller上，view被压缩，在这里设置contentView和headview距离，不然contentview会被压上去几像素
    _contentView.originY = CGRectGetMaxY(_headView.frame);
    _contentView.height = self.view.height-_headView.height;

}

- (void)forceLoadView{
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
