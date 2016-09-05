//
//  LLWebBrowserViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLWebBrowserViewController.h"
#import "LLThirdCollection.h"

@interface LLWebBrowserViewController ()

@end

@implementation LLWebBrowserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕电话号码，单击可以拨打
    LLThirdCollection *collection = self.params;
    NSURL *url = [NSURL URLWithString:@"http://app.lbslm.com/protocol.html"];//创建URL
    if(collection)
    {
        url = [NSURL URLWithString:collection.url];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)back:(id)sender
{
    if([[self.url relativeString] hasPrefix:@"present:"])
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
