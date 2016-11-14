//
//  LLDeviceCatagoryViewController.m
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLDeviceCatagoryViewController.h"

@interface LLDeviceCatagoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray  *catagroyDataSource;

@end

@implementation LLDeviceCatagoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *opt = self.params;
    if( [opt isEqualToString:@"equipType"] )
    {
        self.catagroyDataSource = [[NSArray alloc] initWithObjects:@"挖掘机",@"泵车",@"混凝土搅拌车",@"铲车", @"汽车起重吊",@"旋挖钻",@"卡车",@"推土机",@"叉车", @"压路机",@"混凝土搅拌站",@"堆高机",@"越野车", nil
                                   ];
    }
    else if ( [opt isEqualToString:@"tags"] )
    {
        self.catagroyDataSource = [[NSArray alloc] initWithObjects:@"新闻",@"活动",@"作业",@"二手",@"租赁",@"招聘",@"求职",@"维修",@"求救",nil];
    }
    else
    {
        self.catagroyDataSource = [[NSArray alloc] initWithObjects:@"没有参数",nil];
    }
}
- (IBAction)back:(id)sender
{
  [self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)chooseCategroyClicked : (NSString *)categroy
{
    

    [[NSNotificationCenter defaultCenter] postNotificationName:@"LLCatatoryChooseNotification"
                                                        object:nil
                                                      userInfo:@{@"categroy": categroy}
     ];
    
    [self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.catagroyDataSource.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:TableSampleIdentifier];
    }
    else
    {
        while ([cell.contentView.subviews lastObject ]!=nil)
        {
            [(UIView*)[cell.contentView.subviews lastObject]removeFromSuperview];
        }
    }
    //    把数组中的值赋给单元格显示出来
    cell.textLabel.text= self.catagroyDataSource[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *categroy = self.catagroyDataSource[indexPath.row];
    [self chooseCategroyClicked:categroy];
}

@end
