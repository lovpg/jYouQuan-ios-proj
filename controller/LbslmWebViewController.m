//
//  LbslmWebViewController.m
//  iDleChat
//
//  Created by Reco on 16/3/25.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LbslmWebViewController.h"

@interface LbslmWebViewController ()
{
   
}

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation LbslmWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    NSURL *_url = [NSURL URLWithString:self.urlString];
    self.webview.scalesPageToFit = YES;
    NSURLRequest* request = [NSURLRequest requestWithURL:_url];
    [self.webview loadRequest:request];
}
- (IBAction)back:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
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
