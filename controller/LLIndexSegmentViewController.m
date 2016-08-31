//
//  LLIndexSegmentViewController.m
//  Olla
//
//  Created by Reco on 16/5/23.
//  Copyright © 2016年 xiaoran. All rights reserved.
//

#import "LLIndexSegmentViewController.h"
#import "LLHomeViewController.h"
#import "LLWorkSpaceViewController.h"
#import "LLMessageViewController.h"
#import "LLMyCenterViewControllerRefactor.h"
#import "LLHotShareViewController.h"

#import "LLMediaRecordController.h"
#import "KZVideoViewController.h"
#import "KZVideoPlayer.h"



@interface LLIndexSegmentViewController ()
{
    NSMutableDictionary *shareDic;
    
}


@end

@implementation LLIndexSegmentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     shareDic =   [NSMutableDictionary dictionaryWithCapacity:4];
     LLHomeViewController *plazaVC = [self.context getViewController:[NSURL URLWithString: [ [self.url urlPath]  stringByAppendingPathComponent:@"plaza"]] basePath:@"/"];
    
    [plazaVC setTitle:@"精华"];

    LLHotShareViewController *hotsVC = [self.context getViewController:[NSURL URLWithString: [ [self.url urlPath]  stringByAppendingPathComponent:@"index-focus"]] basePath:@"/"];
    [hotsVC setTitle:@"新贴"];
    
    LLMyCenterViewControllerRefactor *barsVC = [self.context getViewController:[NSURL URLWithString: [ [self.url urlPath]  stringByAppendingPathComponent:@"focus"]] basePath:@"/"];
    [barsVC setTitle:@"关注"];
    
    // ContainerView
    float statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height + 6;
    
    TMSegmentViewController *containerVC = [[TMSegmentViewController alloc]
                                            initWithControllers:@[plazaVC,hotsVC, barsVC]
                                            topBarHeight:statusHeight

                                            btnImages:@[@"take_photo",@"take_photo",@"take_photo"]
                                            parentViewController:self];
    containerVC.delegate = self;
    containerVC.menuBackGroudColor = RGB_HEX(0xe21001);
//    containerVC.menuItemFont = [UIFont fontWithName:@"Futura-Medium" size:16];
    
    [self.view addSubview:containerVC.view];
}



- (void) newPost
{
    [UIActionSheet showInView:[self.presentedViewController view]
                    withTitle:nil
            cancelButtonTitle:@"取消"
       destructiveButtonTitle:nil
            otherButtonTitles:@[
                                @"小视频",
                                @"拍照",
                                @"从手机相册中选择"]
                     tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex)
     {

         if (0==tapIndex)
         {//camera
             /*
             [shareDic setValue:@"life" forKey:@"tags"];
//             [self openURL:[self.url URLByAppendingPathComponent:@"share"] params:shareDic animated:YES];
             [self openURL:[NSURL URLWithString:@"present:///root/share" queryValue:nil]  animated:YES];
              */
             
             KZVideoViewController *videoVC = [[KZVideoViewController alloc] init];
//             videoVC.delegate = self;
             videoVC.Typeshowing = KZVideoViewShowTypeSingle;
//             UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:videoVC];
             videoVC.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:videoVC animated:YES];
             
//             [videoVC startAnimationWithType:KZVideoViewShowTypeSingle];
             
         }
         else if(1==tapIndex)
         {// album
             
             [shareDic setValue:@"humor" forKey:@"tags"];
             [self openURL:[NSURL URLWithString:@"present:///root/share" queryValue:nil]  animated:YES];
         }
         else if(2==tapIndex)
         {// album
             
             [shareDic setValue:@"activity" forKey:@"tags"];
             [self openURL:[NSURL URLWithString:@"present:///root/share" queryValue:nil]  animated:YES];
         }

         
     }];
}


#pragma mark -- YSLContainerViewControllerDelegate
- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller
{
    [controller viewWillAppear:YES];
}
#pragma 响应菜右边事件
- (void)btnResponse:(NSInteger)index
{
    NSString *path = [self.url urlPath];
    NSLog(@"current Index : %ld, %@",(long)index, path);
    switch (index)
    {
        case 0:
            [self newPost];
            break;
        case 1:
           [self newPost];
            break;
        case 2:
            [self newPost];
            break;
        default:
            break;
    }
}





@end
