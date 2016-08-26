//
//  LLShareDataController.m
//  Olla
//
//  Created by nonstriater on 14-7-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareDataController.h"
#import "LLHTTPRequestOperationManager.h"
#import "JDStatusBarNotification.h"
#import "LLShare.h"
#import "LLPhotoLayoutManager.h"

@interface LLShareTableViewCell () <TTTAttributedLabelDelegate>{
    LLPhotoLayoutManager *layoutManager;
}

@end

@implementation LLShareTableViewCell

// 自定义cell想要配置初始化变量要重写 initWithStyle:reuseIdentifier:nib: 一定要调用super才性
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier nibName:(NSString *)nibName{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier nibName:nibName];
    return self;
}

-(void)awakeFromNib{
    self.needSelectionBackgroundImage = YES;
    layoutManager = [[LLPhotoLayoutManager alloc] init];
    UIImage *sourceImage = [[UIImage imageNamed:@"group_bar_homepage_post_source_new"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    [groupBarButton setBackgroundImage:sourceImage forState:UIControlStateNormal];
    shareTextLabel.delegate = self;
    shareTextLabel.numberOfLines = 0;
    shareTextLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor blueColor], NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone]};
    shareTextLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)setDataItem:(LLShare *)dataItem{
    
    [super setDataItem:dataItem];
    
    CGFloat topMargin = (25+21+22)/2+45;// 20是卡片的间距
    CGFloat spacing1 = 11.f;
    CGFloat spacing2 = 25.f/2;
    //CGFloat spacing3 = 25.f/2;
   // CGFloat bottomMargin = 20.f;
    
    CGFloat y = topMargin;
    
    // 相对布局好
    NSString *textContent = dataItem.content;
    if ([textContent length]) {
        CGSize size = [textContent sizeWithFont:App_Text_Font(15) constrainedSize:CGSizeMake(288, self.showAllContent ? MAXFLOAT : 80)];
        shareTextLabel.height = size.height;
        
        shareTextLabel.originY = y;
        
        y = y+size.height+spacing1;
    }
    
    if ([dataItem.imageList count]>0) {
        // 原图==》缩略图
        if ([dataItem.imageList count] == 1) {
            layoutManager.photos = @[[LLAppHelper oneShareThumbImageURLWithString:dataItem.imageList.firstObject]];
        } else {
            NSMutableArray *thumbImages = [NSMutableArray array];
            for (NSString *originImage in dataItem.imageList) {
                [thumbImages addObject:[LLAppHelper shareThumbImageURLWithString:originImage]];
            }
            layoutManager.photos = thumbImages;
        }
        
        LLPhotoLayout *layoutView = layoutManager.photoLayout;
        layoutView.originX = shareTextLabel.left;
        layoutView.originY = y;
        [self addSubview:layoutView];
        
        y += ([layoutView layoutHeight] + spacing2);
        
    }else{
        //imageGroupView.height = 0.f;
        [imageGroupView removeFromSuperview];//TODO: 这样会不会在复用这个cell时有问题
    }
    
    //interactiveView.originY = imageGroupView.originY+imageGroupView.height+10.f;// 加了这句，位置反而不正常了！!
    
    if (_displayLocation && [dataItem.address length]) {
        locationLabel.text = dataItem.address;
        locationView.originY = y;
        locationView.hidden = NO;
    }else{
        locationView.hidden = YES;
    }
    
    likeButton.actionName = dataItem.good ? @"unlike" : @"like";
    
//    if (dataItem.bar) {
//        [groupBarButton setTitle:dataItem.bar.nickname forState:UIControlStateNormal];
//        
//        CGSize size = [groupBarButton.titleLabel sizeThatFits:CGSizeMake(999, 24)];
//        float width = MIN(size.width + 20, self.width / 2);
//        groupBarButton.frame = CGRectMake(self.width - width - 15, 20, width, 24);
//        groupBarButton.hidden = NO;
//        timeLabel.top = 42;
//    } else {
//        [groupBarButton setTitle:nil forState:UIControlStateNormal];
//        groupBarButton.hidden = YES;
//        timeLabel.top = 26;
//    }
    
    [self setUserInfoPositionProperty:dataItem];
    //[self addConstraintsToUserView];
}

- (void)setUserInfoPositionProperty:(LLShare *)dataItem{
    
    nicknameLabel.width = [dataItem.user.nickname sizeWithFont:[UIFont systemFontOfSize:16.f] constrainedSize:CGSizeMake(320, 21)].width + 5.f ;
    if (nicknameLabel.width>95.f) {
        nicknameLabel.width = 95.f;
    }
    
    genderImageView.originX = nicknameLabel.width+nicknameLabel.originX;
    countryImageView.originX = genderImageView.width+genderImageView.originX+2.f;

}

//相对布局，这里打住
- (void)addConstraintsToUserView{
    
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nicknameLabel]-[genderImageView]-[countryImageView]-|" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:NSDictionaryOfVariableBindings(nicknameLabel,genderImageView,countryImageView)];
    [self addConstraints:constraints];
    
}

#pragma mark - 点赞相关
// 取消点赞
- (void)decreaseLikeNum{
    
    NSInteger count = [likeNumLabel.text integerValue] - 1 ;
    if (count < 0) {
        count = 0;
    }
    [self.dataItem setValue:@(count) forKey:@"goodCount"];
    likeNumLabel.text = [NSString stringWithFormat:@"%ld",count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListDecreased" object:nil];
    
}

// 点赞
- (void)increaseLikeNum{
    
    int count = [likeNumLabel.text intValue]+1;
    
    [self.dataItem setValue:@(count) forKey:@"goodCount"];//使用model好
    likeNumLabel.text = [NSString stringWithFormat:@"%d",count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListIncreased" object:nil];
}



- (void)increaseCommentNum{
    
    int count = [commentLabel.text intValue]+1;
    [(LLShare *)self.dataItem setCommentCount:count];
    commentLabel.text = [NSString stringWithFormat:@"%d",[commentLabel.text intValue]+1];

}

- (IBAction)groupBarButtonClick:(id)sender {
    [self routerEventWithName:@"LLGroupBarDetail" userInfo:@{@"share":self.dataItem}];
}

- (void)doAction:(id)sender{

//    if ([sender conformsToProtocol:@protocol(IOllaAction) ]) {
//        if ([[(id<IOllaAction>)sender actionName] isEqualToString:@"like"]) {
//           
//            POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
//            springAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
//            springAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.1, 1.1f)];
//            [likeImageView pop_addAnimation:springAnimation forKey:@"com.olla.animation.like"];
//            
//        }
//    }

    [super doAction:sender];

}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [self routerEventWithName:LLShareTextURLClickEvent userInfo:@{@"url":url}];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [self routerEventWithName:LLShareTextPhoneNumberClickEvent userInfo:@{@"phoneNumber":phoneNumber}];
}

- (IBAction)longPressPostHandler:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyText)];
        UIMenuItem *translateItem = [[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(translate)];
        menuController.menuItems = @[copyItem, translateItem];
        [self becomeFirstResponder];
        [menuController setTargetRect:sender.view.frame inView:sender.view.superview];
        [menuController setMenuVisible:YES animated:YES];
    }
    
}

- (void)copyText {
    LLShare *share = self.dataItem;
    [[UIPasteboard generalPasteboard] setString:share.content];
    [[UIApplication sharedApplication].keyWindow.rootViewController showHint:@"Copy to pasteboard"];
    [UIMenuController sharedMenuController].menuItems = nil;
}

//- (void)translate {
//    [self routerEventWithName:LLGroupBarPostTranslateClickEvent
//                     userInfo:@{@"post":self.dataItem}];
//}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    
    BOOL retValue = NO;
    if(action==@selector(copyText)){
        return YES;
    } else if(action==@selector(translate)){
        return YES;
    } else{
        retValue = [super canPerformAction:action withSender:sender];
    }
    return retValue;
}

@end


// /////////////////////////////////////////////////////////


@interface LLShareDataController (){
    LLPhotoLayoutManager *layoutManager;
}

@end

@implementation LLShareDataController

- (void)viewLoaded{
    
    [(OllaRefreshView *)self.topRefreshView setTintColor:[UIColor whiteColor]];
    
    layoutManager = [[LLPhotoLayoutManager alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentSuccessHandler:) name:@"OllaCommentSuccessNotification" object:nil];//share评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeSuccessHandler:) name:@"OllaLikeSuccessNotification" object:nil];
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)commentSuccessHandler:(NSNotification *)notification{
    
    NSString *shareId = notification.userInfo[@"shareId"];
    
    // shareId 找到自定义cell的逻辑，这个可能多个地方用到，如何服用？
    LLShareTableViewCell *cell = [self cellWithShareId:shareId];
    [cell increaseCommentNum];
    
}


- (void)LikeSuccessHandler:(NSNotification *)notification{
    
    NSString *shareId = notification.userInfo[@"shareId"];
    
    LLShareTableViewCell *cell = [self cellWithShareId:shareId];
    [cell increaseLikeNum];
    
}


- (LLShareTableViewCell *)cellWithShareId:(NSString *)shareId{
    
    LLShareTableViewCell *cell = nil;
    for (LLShare *dataItem in [self.dataSource dataObjects]) {
        if ([dataItem.shareId isEqualToString:shareId]) {
            NSInteger index = [[self.dataSource dataObjects] indexOfObject:dataItem];
            cell = (LLShareTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index+([self.headerCells count]) inSection:0]];
        }
    }
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 在super 中 有header 高度设置//
    if (indexPath.row<[self.headerCells count]) {
        return [[self.headerCells objectAtIndex:indexPath.row] frame].size.height;
    }
    if (indexPath.row == [self.headerCells count]+ [self.dataSource count] ) {// loadingMore
        return self.bottomLoadingView.frame.size.height;
    }
    
    // 获取数据源，也要去掉header cells的index
    NSDictionary *dataItem = [self dataAtIndexRow:indexPath.row];
    return [self cellHeightForDataItem:dataItem];
}


- (CGFloat)cellHeightForDataItem:(LLShare *)dataItem{

    //固定的头像信息
    CGFloat topMargin = (25+21+22)/2+45;
    CGFloat spacing1 = 11.f;
    CGFloat spacing2 = 25.f/2;
    CGFloat spacing3 = 25.f/2;
    CGFloat bottomMargin = 76/2.f;
    
    CGFloat height = topMargin;
    
    NSString *textContent = dataItem.content;
    if ([textContent length]) {
        CGSize size = [textContent sizeWithFont:App_Text_Font(15) constrainedSize:CGSizeMake(288, self.showAllContent ? MAXFLOAT : 80)];
        height += (size.height+spacing1);
    }
 
    CGFloat imageGroupViewHeight = 0.f;
    if ([dataItem.imageList count]>0) {
        
        //imageGroupViewHeight=[OllaImageLimitGridView heightWhenImagesCount:[dataItem.imageList count] imageSize:CGSizeMake(80, 80)];
        if(!layoutManager){
            layoutManager = [[LLPhotoLayoutManager alloc] init];
        }
        layoutManager.photos = dataItem.imageList;
        imageGroupViewHeight = [layoutManager.photoLayout layoutHeight];
        
        height += (imageGroupViewHeight+spacing2);
    }
    
    if (self.displayLocation && [dataItem.address length]) {
        height += (25.f+spacing3);
    }
    
    return height + bottomMargin;
    
}


// 一个controller 可以有适配多个controller，所以应该尽量把不需要路由的功能放到 controller进行，而不是vc，这样多个业务逻辑页面公用一个controller，可以复用这段逻辑
- (void)tableViewCell:(OllaTableViewCell *)cell doAction:(id<IOllaAction>)sender event:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(shouldHandleTableDataController:cell:doAction:event:)]) {
        if (![self.delegate shouldHandleTableDataController:self cell:cell doAction:sender event:event]) {
            return;
        }
    }
//    
//    LLShare *share = cell.dataItem;
//
//    if ([[sender actionName] isEqualToString:@"like"]) {
//
//        // like or unlike
//        
//        __weak typeof(self) weakSelf = self;
//        [[LLHTTPRequestOperationManager shareManager]
//         GETWithURL:Olla_API_Share_Like
//         parameters:@{@"shareId":share.shareId}
//         success:^(id datas , BOOL hasNext){
//            
//            __strong typeof(self) strongSelf = weakSelf;
//            // TODO: like成功
//            [(LLShareTableViewCell *)cell increaseLikeNum];
//             [sender setActionName:@"unlike"];
//             [strongSelf successHandler:datas];
//             
//        } failure:^(NSError *error){
//            
//            DDLogError(@"like error:%@",error);
//            //[JDStatusBarNotification showWithStatus:@"like failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
//            
//            
//        }];
//        
//    }else if([[sender actionName] isEqualToString:@"unlike"]){
//    
//        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Unlike parameters:@{@"shareId":share.shareId} success:^(id datas , BOOL hasNext){
//         
//            DDLogInfo(@"API Log:%@",datas);
//            [(LLShareTableViewCell *)cell decreaseLikeNum];
//            [sender setActionName:@"like"];
//            
//            if (![datas boolValue]) {
//                [JDStatusBarNotification showWithStatus:@"unlike failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
//            }
//
//            
//        }
//     failure:^(NSError *error){
//            DDLogError(@"取消点赞失败：%@",error);
//            //[JDStatusBarNotification showWithStatus:@"unlike failed" dismissAfter:1.f styleName:JDStatusBarStyleDark];
//        }];
//
//    }else if([[sender actionName] isEqualToString:@"report"]){
//    
//        
//        [UIAlertView showWithTitle:nil message:@"Are you sure to report to administrator to block it？" cancelButtonTitle:@"cancel" otherButtonTitles:@[@"sure"] tapBlock:^(UIAlertView *alertView,NSInteger index){
//            
//            if (index==1) {
//                
//                __weak typeof(self) weakSelf = self;
//                [[LLHTTPRequestOperationManager shareManager]
//                 GETWithURL:Olla_API_report
//                 parameters:@{@"shareId":share.shareId}
//                 success:^(id datas , BOOL hasNext){
//
//                     NSString *message = @"report success";
//                     [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
//                     
//                     __strong typeof(self) strongSelf = weakSelf;
//                     [strongSelf successHandler:datas];
//                     
//                     // TODO: 举报成功
//                     
//                     
//                 } failure:^(NSError *error){
//                     DDLogError(@"report error:%@",error);
//                     //[JDStatusBarNotification showWithStatus:@"report fail" dismissAfter:1.f styleName:JDStatusBarStyleDark];
//                 }];
//            }
//        
//        }];
//  
//    }
    
    [super tableViewCell:cell doAction:sender event:event];
}


- (void)successHandler:(id)result{

}



@end
