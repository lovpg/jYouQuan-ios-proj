//
//  UserProtocolViewController.m
//  iDleChat
//
//  Created by Reco on 16/3/21.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "UserProtocolViewController.h"

@interface UserProtocolViewController ()


@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UserProtocolViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    self.webView.detectsPhoneNumbers = YES;//自动检测网页上的电话号码，单击可以拨打
    NSURL* url = [NSURL URLWithString:@"http://app.lbslm.com/agreement.html"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [self.webView loadRequest:request];
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
- (IBAction)back:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
}

@end
