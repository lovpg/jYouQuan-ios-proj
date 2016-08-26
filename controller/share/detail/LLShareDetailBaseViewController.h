//
//  LLShareDetailBaseViewController.h
//  Olla
//
//  Created by Charles on 15/7/24.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLBaseViewController.h"
#import "LLLoadingView.h"
#import "LLPostMessageToolBar.h"
#import "LLShareDetailTableViewCellRefactor.h"
//#import "LLCategoryHeadTableViewCell.h"

@interface LLShareDetailBaseViewController : LLBaseViewController <UITableViewDelegate, UITableViewDataSource,LLPostMessageToolBarDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// 三个不同的数据源
@property (nonatomic, strong) NSMutableArray *dataItemDataSource;
@property (nonatomic, strong) NSMutableArray *likeListDataSource;
@property (nonatomic, strong) NSMutableArray *commentListDataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) LLShare *share;
//@property (nonatomic, strong) LLGroupBarPost *post;

// 当前回复评论的人
@property (nonatomic, strong) LLSimpleUser *replyer;

@property (nonatomic, strong) LLShareDetailTableViewCellRefactor *headCell;
//@property (nonatomic, strong) LLCategoryHeadTableViewCell *categoryHeadCell;

// 存储点赞人信息
@property (nonatomic, strong) NSMutableArray *likeUsersInfos;
// 存储报名人信息
@property (nonatomic, strong) NSMutableArray *enrollUsersInfos;

// 发送评论
@property (nonatomic, strong) LLPostMessageToolBar *toolBarView;

// 刷新
@property (nonatomic, strong) UIRefreshControl *refreshControl;
// 加载更多
@property (nonatomic, strong) LLLoadingView *loadingView;

// 刷新方法
- (void)refresh:(id)sender;

// 加载数据
- (void)loadData;

// 加载更多数据
- (void)loadMoreData;

// 重新加载评论
- (void)reloadComments;

// 加载更多评论
- (void)loadMoreComment;

// 分享bar
- (void)shareBar;

// 删除帖子
- (IBAction)deleteButtonClicked:(id)sender;

// 检查是否填写了资料
- (BOOL)check;

// 检查是否被拉黑了
- (BOOL)checkIsBlocked;

#pragma mark - 子类实现
// 子类中需要实现 配置header cell
- (id)configTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForHeaderCell;

// 根据需要在子类中实现
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;


@end
