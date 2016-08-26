//
//  LLShareDetailBaseViewController.m
//  Olla
//
//  Created by Charles on 15/7/24.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareDetailBaseViewController.h"
#import "LLLikeTableViewCell.h"
#import "LLShareCommentCell.h"
#import "LLUpArrowTableViewCell.h"
#import "LLSupplyProfileService.h"
#import "AppDelegate.h"
#import "LLEnrollTableViewCell.h"

@interface LLShareDetailBaseViewController () {

    LLSupplyProfileService *supplyProfileService;
    LLUserService *userService;
//    LLBLockService *blockService;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *upArrowTableViewCell;
@property (weak, nonatomic) IBOutlet UIImageView *upArrowImageView;

@end

@implementation LLShareDetailBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        _likeUsersInfos = [NSMutableArray array];
        _dataItemDataSource = [NSMutableArray array];
        _likeListDataSource = [NSMutableArray array];
        _commentListDataSource = [NSMutableArray array];
        
    }
    return self;
}

#pragma mark - View
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 取出back按钮的文字
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGB_DECIMAL(247, 247, 247);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    supplyProfileService = [[LLSupplyProfileService alloc] init];
    userService = [[LLUserService alloc] init];
//    blockService = [[LLBLockService alloc] init];
//    [AppDelegate storyBoradAutoLay:self.toolBarView];
    [self setupKeyboard];

    
    [self.view addSubview:self.toolBarView];
    [self.toolBarView setupBackgrondControl];
    
    userService = [[LLUserService alloc] init];
}

#pragma mark - Refresh & LoadData & LoadMoreData
// 刷新
- (void)refresh:(id)sender {

    
}

// 加载数据
- (void)loadData {

}

// 加载更多数据
- (void)loadMoreData {

}

// 加载更多评论
- (void)loadMoreComment {

}

#pragma mark - Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataItemDataSource.count)
    {
        return 3;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        if (self.likeListDataSource.count)
        {
            return 1;
        } else {
            return 0;
        }
    }
    else
    {
        if (self.commentListDataSource.count) {
            return self.commentListDataSource.count;
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0)
    {
        // 自定义配置
        if (indexPath.row == 0)
        {
            cell = [self configTableView:tableView cellForRowAtIndexPath:indexPath];
        }
        else if (indexPath.row == 1)
        {
            if( [ self.share.tags isEqualToString:@"activity" ] )
            {
                cell = (LLEnrollTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLEnrollTableViewCell"];
                if (!cell)
                {
                    cell = (LLEnrollTableViewCell *)[[LLEnrollTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LLEnrollTableViewCell"];
                }

            }
            else
            {
                cell = (LLUpArrowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLUpArrowTableViewCell"];
                if (!cell)
                {
                    cell = (LLUpArrowTableViewCell *)[[LLUpArrowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LLUpArrowTableViewCell"];
                }
                if (self.likeListDataSource.count == 0 && self.commentListDataSource.count == 0)
                {
                    ((LLUpArrowTableViewCell *)cell).arrowImageView.hidden = YES;
                }
                else
                {
                    ((LLUpArrowTableViewCell *)cell).arrowImageView.hidden = NO;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
    else if (indexPath.section == 1)
    {
        // Like table view cell
        LLLikeTableViewCell *likeListCell = (LLLikeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LLLikeListCell"];
        if (!likeListCell) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLLikeTableViewCell" owner:self options:nil];
            likeListCell = (LLLikeTableViewCell *)[nib objectAtIndex:0];
        }
        
        NSMutableArray *likeList = [self.likeListDataSource mutableCopy];
        
        likeListCell.likeArr = [likeList mutableCopy];
        cell = likeListCell;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        // Comment table view cell
        LLShareCommentCell *commentCell = (LLShareCommentCell *)[tableView dequeueReusableCellWithIdentifier:@"LLShareComment"];
        if (!commentCell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LLShareCommentCell" owner:self options:nil];
            commentCell = (LLShareCommentCell *)[nib objectAtIndex:0];
        }
        
        commentCell.delegate = self;
        
        LLComment *comment = self.commentListDataSource[indexPath.row];
        commentCell.dataItem = comment;
        
        cell = commentCell;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    float height = 0.f;
    
    if (indexPath.section == 0)
    {  // share detail
        if (indexPath.row == 0)
        {
            height = [self heightForHeaderCell];
        }
        else if([ self.share.tags isEqualToString:@"activity" ] )
        {
            height = 60.0;
        }
        else
        {
            height = 20.0;
        }
    }
    else if (indexPath.section == 1)
    {  // like list
        height = 59.0;
    }
    else
    {
        LLComment *comment = self.commentListDataSource[indexPath.row];
        
        NSString *textContent = comment.content;
        CGSize size = [textContent sizeWithFont:App_Text_Font(15) constrainedSize:CGSizeMake(210, 99999)];
        CGFloat textHeight = textContent.trim.length > 0 ? size.height : 0;
        
        CGFloat start = 38.f;
        CGFloat bottomPadding = 12.f;
        height = textHeight+start+bottomPadding;
        if (comment.imageList.count > 0) {
            height += 60;
        } else if (comment.voice.length ) {
            height += 30;
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.share.goodCount > 0) {
            // 跳转至点赞列表页面
            NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"goodlist"]];
            NSString *shareId = nil;
            shareId = self.share.shareId;
            NSDictionary *params = @{@"shareId": shareId , @"type":  @"share"};
            [self openURL:url params:params animated:YES];
        }
    }

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.share.goodCount > 0) {
            // 跳转至点赞列表页面
            NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"goodlist"]];
            NSDictionary *params = @{@"shareId":self.share.shareId, @"type":@"share"};
            [self openURL:url params:params animated:YES];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row == self.commentListDataSource.count - 1) && self.loadingView.hasNext) {
        [self loadMoreComment];
    }
}

#pragma mark - Button Click Event
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:LLShareCommentAvatorClickEvent])
    {  // to the profile of someone who commented
        LLSimpleUser *user = [userInfo objectForKey:@"user"];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [dict setValue:@1 forKey:@"flag"];
        [self openURL:[NSURL URLWithString:@"present:///root/plaza/chats/im" queryValue:dict] animated:YES];
        
//        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
//        [query setValue:@(1) forKey:@"flag"];
//        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
    }
    else if ([eventName isEqualToString:LLEnrollDetailButtonClick])
    {
        
        if (self.share.enrollCount > 0) {
            // 跳转至报名列表页面
            NSString *urlp = [self.url urlPath];
            NSURL *url = [NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"enrolllist"]];
            NSDictionary *params = @{@"shareId":self.share.shareId, @"type":@"share"};
            [self openURL:url params:params animated:YES];
        }
    }
    else if ([eventName isEqualToString:LLShareCommentBackgroundClickEvent])
    {
        
        LLSimpleUser *user = userInfo[@"user"];
        self.replyer = user;
        self.toolBarView.inputTextView.placeHolder = [NSString stringWithFormat:@"回复 %@ ",user.nickname];
        [self.toolBarView.inputTextView becomeFirstResponder];
    }
    else if ([eventName isEqualToString:LLLikeAvatarButtonClickEvent1])
    {
        LLSimpleUser *user = [userInfo objectForKey:@"avatar1"];
        
        if (!user) {
            return;
        }
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [query setValue:@(1) forKey:@"flag"];
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
    }
    else if ([eventName isEqualToString:LLLikeAvatarButtonClickEvent2])
    {
        LLSimpleUser *user = [userInfo objectForKey:@"avatar2"];
        
        if (!user) {
            return;
        }
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [query setValue:@(1) forKey:@"flag"];
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
    }  else if ([eventName isEqualToString:LLLikeAvatarButtonClickEvent3]) {
        LLSimpleUser *user = [userInfo objectForKey:@"avatar3"];
        
        if (!user) {
            return;
        }
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [query setValue:@(1) forKey:@"flag"];
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
    }
    else if ([eventName isEqualToString:LLLikeAvatarButtonClickEvent4])
    {
        __weak __block typeof(self) weakSelf = self;
        
        PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:@"你确定举报该内容吗？" message:nil preferredStyle:PSTAlertControllerStyleAlert];
        
        [alertVC addAction:[PSTAlertAction actionWithTitle:@"Sure" handler:^(PSTAlertAction *action) {
            
            [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_report
                                                          parameters:@{@"shareId":self.share.shareId}
                                                             success:^(id datas, BOOL hasNext)
            {
                [weakSelf showHint:@"已举报，等待管理员审核"];
            }
                                                             failure:^(NSError *error)
            {
                NSString *errorMsg = [error.userInfo stringForKey:@"message"];
                if (errorMsg.length == 0) {
                    errorMsg = error.localizedDescription;
                }
                
                [PSTAlertController showMessage:errorMsg];
            }];
            
        }]];
        
        [alertVC addCancelActionWithHandler:^(PSTAlertAction *action) {
            
        }];
        
        [alertVC showWithSender:nil controller:nil animated:YES completion:NULL];
    }  else if ([eventName isEqualToString:LLLikeAvatarButtonClickEvent5]) {
        LLSimpleUser *user = [userInfo objectForKey:@"avatar5"];
        
        if (!user) {
            return;
        }
        
        NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:[user dictionaryRepresentation]];
        [query setValue:@(1) forKey:@"flag"];
        [self openURL:[NSURL URLWithString:[[self.url urlPath] stringByAppendingPathComponent:@"user-center"] queryValue:query] animated:YES];
    }
    else
    {
    
    }
}

#pragma mark - Set up keyboard
// 放viewDidLoad页面错位！！
// IM页面viewDidLayoutSubviews都没有多次调用！！
//在iOS6下测试下看有没有问题，不行放到layoutSubView里去
- (void)viewDidLayoutSubviews{
    
    [self setupKeyboard];
}

- (void)setupKeyboard
{
    if (!self.toolBarView)
    {// 不加这个判断，评论时这个方法多次执行崩溃
        CGRect frame = [AppDelegate getFrame:CGRectMake(0, self.view.frame.size.height - [LLPostMessageToolBar defaultHeight], self.view.bounds.size.width, [LLPostMessageToolBar defaultHeight])];
       //[self.toolBarView setFrame:frame];
        NSLog(@"%f,,,%f",self.view.bounds.size.width, frame.size.width);
        self.toolBarView = [[LLPostMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [LLPostMessageToolBar defaultHeight], frame.size.width, [LLPostMessageToolBar defaultHeight])];
        self.toolBarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        self.toolBarView.delegate = self;
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Check
- (BOOL)check {
//    if (supplyProfileService.needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                //[self openURL:[NSURL URLWithString:@"present:///profile-flow/speaking-flow" queryValue:@{@"lang":@"Native"}] animated:YES];
//                [self openURL:[NSURL URLWithString:@"present:///profile-flow/data-perfect"] animated:YES];
//            }
//            
//        }];
//        return NO;
//    }
    return YES;
}

- (BOOL)checkIsBlocked{
    
   // return [blockService isBlocked];
    return TRUE;
}

#pragma mark - Comment
- (void)didSendText:(NSString *)text {
    
    if (![self check]) {
        return;
    }
    
    // send comment
    if (!self.toolBarView.selectedPhoto && [text length]==0) {
        return ;
    }
    
    // 发送valueDidChange通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LLShareOrPostDetailValueDidChange" object:nil];
    
    [self.toolBarView.inputTextView resignFirstResponder];
    
    // send comment request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.share.shareId forKey:@"shareId"];
    
    NSString *replyHeaderString = [NSString stringWithFormat:@"@%@", self.replyer.nickname];
    if ( self.replyer )
    {
        text = [text stringByReplacingOccurrencesOfString:replyHeaderString withString:@""];
        if ([text hasPrefix:@" "])
        {
            text = [text substringFromIndex:1];
        }
        if (text.length > 1000) {
            text = [text substringToIndex:1000];
        }
        [parameters setObject:self.replyer.uid forKey:@"ouid"];
    }
    [parameters setObject:text forKey:@"content"];
    __weak typeof(self) weakSelf = self;
    NSArray *images = nil;
    if (self.toolBarView.selectedPhoto)
    {
        images = @[self.toolBarView.selectedPhoto];
    }
    [self showHudInView:self.view hint:nil];
    NSString *url = url = Olla_API_Share_Comment;
    [[LLHTTPWriteOperationManager shareWriteManager] POSTWithURL:url
                                                      parameters:parameters
                                                          images:images
                                                         success:^(NSDictionary *responseObject)
    {
        
        if (![responseObject isDictionary] || ![responseObject[@"status"] isEqualToString:@"200"]) {
            DDLogError(@"发表评论出错：%@",responseObject);
            [weakSelf failCommentHandler:nil];
            return ;
        }
        
        DDLogInfo(@"评论成功：%@",responseObject);
        
        NSDictionary *para =  @{@"shareId":self.share.shareId} ;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaCommentSuccessNotification" object:nil userInfo:para];
        
        [_toolBarView.inputTextView resignFirstResponder];
        
//        if (self.headCell) {
            self.headCell.share.commentCount += 1;
//        } else {
//            self.categoryHeadCell.post.commentCount += 1;
//        }
        
        [weakSelf successCommentHandler:parameters];
        
    } failure:^(NSError *error){
        [weakSelf failCommentHandler:error];
        DDLogError(@"comment error :%@",error);
    }];
    
}

// 评论成功,将我的评论插入列表中去
- (void)successCommentHandler:(id)data{
    self.toolBarView.selectedPhoto = nil;
    [self.toolBarView.inputTextView resignFirstResponder];
    
    if (self.headCell) {
        [self.headCell increaseCommentNum];
    } else {
#warning "留给category post head cell"
        
    }
    
    
    [self reloadComments];
}

// 评论失败
- (void)failCommentHandler:(NSError *)error{
    
    [self hideHud];
    NSString *message = [error.userInfo objectForKey:@"message" ];
    [UIAlertView showWithTitle:nil message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
    
}

#pragma mark - Delete Comment
- (void)deleteComment:(NSString *)commentId {
    
    if (!commentId) {
        return;
    }
    
    [self showHudInView:self.view hint:nil];
    
    // 发送删除评论请求
    // /comment/delete.do
    [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Post_Comment_Delete parameters:@{@"commentId":commentId} success:^(id datas, BOOL hasNext) {
        
        DDLogInfo(@"delete comment success");
        
        // 评论数字减1
        LLShare *share = self.dataItemDataSource[0];
        share.commentCount -= 1;
        
        if (self.headCell) {
            [self.headCell decreaseCommentNum];
        } else {
#warning "留给category post head cell"
//            [self.categoryHeadCell decreaseCommentNum];
        }
        
        for (int index = 0; index < self.commentListDataSource.count; index++) {
            LLComment *comment = self.commentListDataSource[index];
            if ([commentId isEqualToString:comment.commentId]) {
                [self.commentListDataSource removeObject:comment];
                break;
            }
        }
        [self hideHud];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHud];
        DDLogError(@"delete comment error : %@", error);
    }];
}

- (void)reloadComments {
    
    __weak __block typeof(self) weakSelf = self;
    int size = self.loadingView.size;
    
    weakSelf.loadingView.page = 1;
    NSDictionary *parameters =  @{@"shareId":weakSelf.share.shareId, @"pageId":@(weakSelf.loadingView.page), @"size":@(size)};
    
    [[LLHTTPRequestOperationManager shareManager] GETListWithURL:Olla_API_Share_CommentList parameters:parameters modelType:[LLComment class] success:^(NSArray *datas, BOOL hasNext) {
        
        [weakSelf hideHud];
        
        weakSelf.loadingView.hasNext = hasNext;
        
        if (hasNext) {
            weakSelf.loadingView.page += 1;
            weakSelf.loadingView.statusLabel.hidden = YES;
        } else {
            weakSelf.loadingView.statusLabel.hidden = NO;
        }
        
        for (LLComment *comment in datas) {
            if (comment.objUsername.length > 0) {
                comment.content = [NSString stringWithFormat:@"@%@ %@", comment.objUsername, comment.content];
            }
        }
        
        // 先清空所有数据
        [self.commentListDataSource removeAllObjects];
        
        [weakSelf.commentListDataSource addObjectsFromArray:datas];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        [weakSelf hideHud];
    }];
}

#pragma mark - photo button click
- (void)photoButtonClick {
    __weak __block typeof(self) weakSelf = self;
    PSTAlertController *alertVC = [PSTAlertController alertControllerWithTitle:nil message:nil preferredStyle:PSTAlertControllerStyleActionSheet];
    
    [alertVC addAction:[PSTAlertAction actionWithTitle:@"拍照" handler:^(PSTAlertAction *action) {
        [weakSelf showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
    }]];
    
    [alertVC addAction:[PSTAlertAction actionWithTitle:@"从相册中选择" handler:^(PSTAlertAction *action) {
        [weakSelf showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    
    [alertVC addAction:[PSTAlertAction actionWithTitle:@"放弃" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
        
    }]];
    
    [alertVC showWithSender:nil controller:self animated:YES completion:NULL];
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    _toolBarView.selectedPhoto = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
