//
//  LLMeViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLMeViewController.h"

@interface LLMeViewController ()

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
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
