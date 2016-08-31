//
//  LLMediaRecordController.m
//  jYouQuan
//
//  Created by Corporal on 16/8/29.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLMediaRecordController.h"
#import "KZVideoViewController.h"

@interface LLMediaRecordController () <KZVideoViewControllerDelegate> 

@end

@implementation LLMediaRecordController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    KZVideoViewController *videoVC = [[KZVideoViewController alloc] init];
    videoVC.delegate = self;
    [videoVC startAnimationWithType:KZVideoViewShowTypeSingle];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)videoViewControllerDidCancel:(KZVideoViewController *)videoController {
    NSLog(@"没有录到视频");
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
