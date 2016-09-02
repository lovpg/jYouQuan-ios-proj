//
//  LLImagePickerViewController.m
//  jYouQuan
//
//  Created by Corporal on 16/9/2.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLImagePickerViewController.h"

@interface LLImagePickerViewController ()

@property (nonatomic, strong) UIImagePickerController *imagePickerVC;

@end

@implementation LLImagePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imagePickerVC = [[UIImagePickerController alloc]init];
    self.view = self.imagePickerVC.view;
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
