//
//  LLWorkSpaceViewController.m
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLWorkSpaceViewController.h"
#import "LLJionWorkCellTableViewCell.h"

@interface LLWorkSpaceViewController ()

@end

@implementation LLWorkSpaceViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        UIImage *aimage = [UIImage imageNamed:@"more_work_func"];
        [aimage drawInRect:CGRectMake(0, 0, 24, 24)];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(codeScan:)];
        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO];
    
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    {
        LLJionWorkCellTableViewCell *jionWorkCell = (LLJionWorkCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLJionWorkCellTableViewCell"];
        if (!jionWorkCell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLJionWorkCellTableViewCell" owner:self options:nil];
            jionWorkCell = (LLJionWorkCellTableViewCell *)[nib objectAtIndex:0];
        }
        cell = jionWorkCell;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat height = 0.0;
//    {
//        LLHomeShareViewCell *shareCell =  [[LLHomeShareViewCell alloc] init];
//        shareCell.displayLocation = YES;
//        height = [shareCell shareCellHeight:self.shareDataSource[indexPath.row]];
//    }
    return 140;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if ((indexPath.row == self.shareDataSource.count - 1) && self.loadingView.hasNext)
//    {
//        [self loadMoreData];
//    }
    
}
@end
