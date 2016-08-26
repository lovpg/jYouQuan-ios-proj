//
//  LLMessageViewController.m
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLMessageViewController.h"

@interface LLMessageViewController ()

@end

@implementation LLMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
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
