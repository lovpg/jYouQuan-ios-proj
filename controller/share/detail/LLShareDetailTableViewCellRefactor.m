//
//  LLShareDetailTableViewCellRefactor.m
//  Olla
//
//  Created by Charles on 15/6/25.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareDetailTableViewCellRefactor.h"
#import "LLThirdCollection.h"

@interface LLShareDetailTableViewCellRefactor () <TTTAttributedLabelDelegate>
{
    LLThirdCollection *collection;
}
@property (weak, nonatomic) IBOutlet UIButton *tagsButton;

@end

@implementation LLShareDetailTableViewCellRefactor

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.shareDetailLabel.delegate = self;
    self.shareDetailLabel.adjustsFontSizeToFitWidth = YES;
    self.shareDetailLabel.numberOfLines = 0;
    self.shareDetailLabel.linkAttributes = @{
                                             (id)kCTForegroundColorAttributeName:[UIColor blueColor],
                                             NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone]
                                            };
    self.shareDetailLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    self.shareLogo.userInteractionEnabled = YES;
    self.shareLabel.userInteractionEnabled = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if(userSerive)return;
    userSerive = [[LLUserService alloc] init];
    self.imagesContainer.delegate = self;
    [self loadFriendUserInfo];
    self.backgroundButton.cornerRadius = 5;
    self.backgroundButton.backgroundColor = [UIColor colorWithRed:0.97 green:0.98 blue:0.98 alpha:1.f];
    self.backgroundButton.borderWidth = 0.5;
    self.backgroundButton.borderColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.f];
    
    self.avatarButton.cornerRadius = self.avatarButton.width / 2.f;
    
    NSString *avator = self.share.user.avatar;

    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avator] placeholderImage:[UIImage imageNamed:@"default_headphoto"]];
    self.avatarImageView.cornerRadius = self.avatarImageView.width / 2.f;
    
    self.nicknameLabel.text = self.share.user.nickname;
    
    // 调整nickname label的宽度
    CGSize nameSize = [self.nicknameLabel sizeThatFits:CGSizeMake(999, 20)];
    CGRect nicknameLabelFrame = self.nicknameLabel.frame;
    nicknameLabelFrame.size.width = MIN(nameSize.width, 95.0f);
    self.nicknameLabel.frame = CGRectMake(73, 22, MIN(nameSize.width, 95.0f), 21);
    
    self.genderImageView.originX = self.nicknameLabel.originX + self.nicknameLabel.width + 5;
    self.countryImageView.originX = self.genderImageView.originX + self.genderImageView.width + 5;
    
    _timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.share.posttime/1000] formatRelativeTime];
    self.tagsButton.text =  [LLAppHelper getNamefromCategory:self.share.tags];
    if ([self.share.user.gender isEqualToString:@"男"]) {
        self.genderImageView.image = [UIImage imageNamed:@"sex_male"];
    } else if ([self.share.user.gender isEqualToString:@"女"]) {
        self.genderImageView.image = [UIImage imageNamed:@"sex_female"];
    } else if ([self.share.user.gender isEqualToString:@"gay"]) {
        self.genderImageView.image = [UIImage imageNamed:@"sex_gay"];
    } else {
        self.genderImageView.image = [UIImage imageNamed:@"sex_secret"];
    }
    
    self.countryImageView.image = [UIImage imageNamed:[NSLocale countryCodeWithName:self.share.user.region]];
    
    // 计算sharedetail的高度
    if ([self.share.content isArabic]) {
        self.shareDetailLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.shareDetailLabel.textAlignment = NSTextAlignmentLeft;
    }
    self.shareDetailLabel.text = self.share.content;
    self.shareDetailLabel.numberOfLines = 0;
    self.shareDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    UIFont *shareContentFont = self.shareDetailLabel.font;
    
    CGSize labelSize = [self.shareDetailLabel.text sizeWithFont:shareContentFont constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByTruncatingTail];
    self.shareDetailLabel.originY = self.avatarButton.originY + self.avatarButton.height + 15;
    self.shareDetailLabel.height = labelSize.height + 15;
    
    // 重新做图片布局
    if (self.share.imageList.count > 0) {
        
        self.imagesContainer.originY = self.shareDetailLabel.originY + self.shareDetailLabel.height + 25.f / 2;
        self.imagesContainer.originX = self.shareDetailLabel.originX;
        if (!layoutManager) {
            layoutManager = [[LLPhotoLayoutManager alloc] init];
        }
        
        if ([self.share.imageList count] == 1) {
            layoutManager.photos = @[[LLAppHelper oneShareThumbImageURLWithString:self.share.imageList.firstObject]];
        }
        else
        {
            NSMutableArray *thumbImages = [NSMutableArray array];
            for (NSString *originImage in self.share.imageList) {
                [thumbImages addObject:[LLAppHelper shareThumbMidImageURLWithString:originImage]];
        }
          //  self.imagesContainer.thumbImages = [thumbImages copy];
            layoutManager.photos = [thumbImages copy];
        }
        //imageGroupView.images = thumbImages;
        //imageGroupView.originY = y;
        
        LLPhotoLayout *layoutView = layoutManager.photoLayout;
        layoutView.originX = 0;
        layoutView.originY = 0;
        
        self.imagesContainer.width = layoutView.width;
        self.imagesContainer.height = [layoutView layoutHeight];
        [self.imagesContainer addSubview:layoutView];
        
    }
    
    // 是否有地址信息
    if (self.share.address.length != 0)
    {  // 带有地址
        
        self.locationContainerView.hidden = NO;
        self.locationContainerView.originX = 11;
        
        // 判断是否带图片,带图片则locationView的位置根据图片位置调整,不带则根据share detail text label的位置来调整
        if (self.share.imageList.count > 0)
        {  // 带图 带地址
            CGRect locationContainerViewFrame = self.locationContainerView.frame;
            locationContainerViewFrame.origin.y = self.imagesContainer.frame.origin.y + self.imagesContainer.frame.size.height + 25.f/2;
            self.locationContainerView.frame = locationContainerViewFrame;
        }
        else
        {  // 不带图 带地址
            CGRect locationContainerViewFrame = self.locationContainerView.frame;
            locationContainerViewFrame.origin.y = self.shareDetailLabel.frame.origin.y + self.shareDetailLabel.frame.size.height + 10;
            self.locationContainerView.frame = locationContainerViewFrame;
        }
        collection = self.share.collection;
        if ( collection )
        {
            self.locationImage.image = [UIImage imageNamed:@"transfer_24"];
            NSString *title = [NSString stringWithFormat:@"[%@] %@", collection.platform,collection.title];
            self.locationLabel.text = title;
        }
        else
        {
            self.locationLabel.text = self.share.address;
        }
        
    }
    else
    {  // 不带地址
        self.locationContainerView.hidden = YES;
    }
    
    // 判断是否带有location,如果有则根据location container view的位置来调整,如果无则判断是否带有图片,根据图片位置来调整,如果无则根据share label detain的位置来调整
    if (self.share.address.length > 0) { // 带图 带location
        self.selectionButtonsContainerView.originY = self.locationContainerView.originY + self.locationContainerView.height + 5;
    } else if (self.share.imageList.count > 0) {  // 带图 不带location
        self.selectionButtonsContainerView.originY = self.imagesContainer.originY + self.imagesContainer.height + 25.f/2;
    } else {  // 不带图 不带location
        self.selectionButtonsContainerView.originY = self.shareDetailLabel.originY + self.shareDetailLabel.height + 5;
    }
    
    self.likeNumberLabel.text = [NSString stringWithFormat:@"%d", self.share.goodCount];
    self.commentNumberLabel.text = [NSString stringWithFormat:@"%d", self.share.commentCount];
    
    self.backgroundButton.height = self.selectionButtonsContainerView.originY + self.selectionButtonsContainerView.height;
    self.enrollCountLabel.text =  [NSString stringWithFormat:@"%d", self.share.enrollCount];
    self.likeLogo.image = [UIImage imageNamed:@"praise_count"];
    
//    self.favoriteLogo.image = self.share.favorite ? [UIImage imageNamed:@"favorite_state_true"] : [UIImage imageNamed:@"favorite_state_false"];

    


}

- (float)shareDetaileCellHeight {
    
    float height;
    float padding = 25.f / 2;
    
    // 以头像的y坐标为基准
    height = self.avatarButton.originY + self.avatarButton.height;
    height += padding;
    
    // 计算sharedetail的高度
    self.shareDetailLabel.text = self.share.content;
    self.shareDetailLabel.textAlignment = NSTextAlignmentLeft;
    // 判断是否阿拉伯语,如果是,改为右对齐
    if ([self.share.content isArabic]) {
        self.shareDetailLabel.textAlignment = NSTextAlignmentRight;
    }
    
    self.shareDetailLabel.numberOfLines = 0;
    self.shareDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    UIFont *shareContentFont = self.shareDetailLabel.font;
    
    CGSize labelSize = [self.shareDetailLabel.text sizeWithFont:shareContentFont constrainedToSize:CGSizeMake(280, 999) lineBreakMode:NSLineBreakByTruncatingTail];
    self.shareDetailLabel.originY = height;
    self.shareDetailLabel.height = labelSize.height;
    
    height += (self.shareDetailLabel.height + padding);
    
    // 重新做图片布局
    if (self.share.imageList.count > 0) {
        
        self.imagesContainer.originY = self.shareDetailLabel.originY + self.shareDetailLabel.height + padding;
        self.imagesContainer.originX = self.shareDetailLabel.originX;
        
        NSLog(@"imagesContainer.originX=%f,imagesContainer.originY=%f,shareDetailLabel.originY=%f,shareDetailLabel.originX=%f",self.imagesContainer.originX ,self.imagesContainer.originY,self.shareDetailLabel.originX,self.shareDetailLabel.originY);
        
        if (!layoutManager) {
            layoutManager = [[LLPhotoLayoutManager alloc] init];
        }
        
        if ([self.share.imageList count] == 1) {
            layoutManager.photos = @[[LLAppHelper oneShareThumbImageURLWithString:self.share.imageList.firstObject]];
        } else {
            NSMutableArray *thumbImages = [NSMutableArray array];
            for (NSString *originImage in self.share.imageList) {
                [thumbImages addObject:[LLAppHelper shareThumbMidImageURLWithString:originImage]];
            }
            layoutManager.photos = thumbImages;
        }
        
        LLPhotoLayout *layoutView = layoutManager.photoLayout;
        layoutView.originX = 0;
        layoutView.originY = 0;
        
        self.imagesContainer.width = layoutView.width;
        self.imagesContainer.height = [layoutView layoutHeight];
        [self.imagesContainer addSubview:layoutView];
        
        height += (self.imagesContainer.height + padding);
    }
    
    // 是否有地址信息
    if (self.share.address.length != 0) {  // 带有地址
        
        self.locationContainerView.hidden = NO;
        
        self.locationContainerView.originY = height;
        
        height += (self.locationContainerView.height + padding);
        
    } else {  // 不带地址
        self.locationContainerView.hidden = YES;
    }
    
    self.selectionButtonsContainerView.originY = height;
    
    self.backgroundButton.height = self.selectionButtonsContainerView.originY + self.selectionButtonsContainerView.height;
    
    height += self.selectionButtonsContainerView.height;
    
    // 矫正高度
    if (self.share.imageList.count > 0) {  // 带有图片
        height += 10;
    } else if (self.share.address.length > 0) {  // 不带图片,带地址
        height += 5;
    } else {  // no 图, no 地址
        height += 3;
    }
    
    if (self.share.imageList.count > 0 && self.share.address.length > 0) {
        height -= 8;
    }
    
    return height + 16;
}
- (void) loadFriendUserInfo
{
    LLSimpleUser *simpleUser = self.share.user;
    [userSerive get:simpleUser.uid
            success:^(LLUser *user)
    {
         currentUser = user;
        if ( ![[[userSerive getMe] uid] isEqualToString:self.share.user.uid] )
        {
            self.followButton.text = currentUser.follow ? @"取消关注" : @"+ 关注";
        }
        else
        {
            self.followButton.hidden = YES;
        }
    }
    fail:^(NSError *error)
    {
        NSLog(@"%@",error);
    }];
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self routerEventWithName:LLShareTextURLClickEvent userInfo:@{@"url":url}];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    [self routerEventWithName:LLShareTextPhoneNumberClickEvent userInfo:@{@"phoneNumber":phoneNumber}];
}

- (IBAction)avatarButtonClick:(id)sender
{
    [self routerEventWithName:LLShareDetailAvatarButtonClick userInfo:@{@"avatorClick":self.share.user}];
}
- (IBAction)toThirdPlatform:(id)sender
{
    if(self.share.collection)
    {
        [self routerEventWithName:LLMyCenterShareThirdPlatfomButtonClickEvent userInfo:@{
                                                                @"dataItem":self.share}];
    }
}

- (IBAction)followButtonClick:(id)sender
{
     // 判断是否follow
    currentUser.follow?[self unfollow:self.share.user]:[self follow:self.share.user];
}

- (IBAction)likeButtonClick:(id)sender {
    
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    springAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.1, 1.1f)];
    [self.likeLogo pop_addAnimation:springAnimation forKey:@"com.olla.animation.like"];
    
    self.share.good = !self.share.good;
   // self.likeLogo.image = self.share.good ? [UIImage imageNamed:@"share_like_new_state_true"] : [UIImage imageNamed:@"share_like_new_state_false"];
    
    [self routerEventWithName:LLShareDetailLikeButtonClickEvent userInfo:@{
                                                                              @"like":@""}];
}

- (IBAction)commentButtonClick:(id)sender {
//    self.commentLogo.image = [UIImage imageNamed:@"comment_state_false"];
    [self routerEventWithName:LLShareDetailCommentButtonClickEvent userInfo:@{
                                                                              @"comment":@""}];
}

//- (IBAction)reportButtonClick:(id)sender {
//    self.shareLogo.image = [UIImage imageNamed:@"share_state_false"];
//    [self routerEventWithName:LLShareDetailReportButtonClick userInfo:@{
//                                                                              @"report":@""}];
//}

#pragma mark - Share Button Click
- (IBAction)shareButtonClick:(UIButton *)sender {
    
    [self routerEventWithName:LLShareDetailShareButtonClick userInfo:@{
                                                                       @"dataItem":self.share}];
}

- (void)increaseCommentNum {
    
    self.commentNumberLabel.text = [NSString stringWithFormat:@"%d", self.commentNumberLabel.text.intValue + 1];
}

- (void)decreaseCommentNum {
    
    self.commentNumberLabel.text = [NSString stringWithFormat:@"%d", self.commentNumberLabel.text.intValue - 1];
}

// if like is yes, then increase the likeNum, or decrease it.
- (void)changeLikeNum:(BOOL)like {
    
    if (like) {  // increase likeNum
        self.likeNumberLabel.text = [NSString stringWithFormat:@"%d", self.likeNumberLabel.text.intValue + 1];
    } else {  // decrease likeNum
        self.likeNumberLabel.text = [NSString stringWithFormat:@"%d", self.likeNumberLabel.text.intValue - 1];
    }
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
    [[UIPasteboard generalPasteboard] setString:self.share.content];
    [[UIApplication sharedApplication].keyWindow.rootViewController showHint:@"Copy to pasteboard"];
    [UIMenuController sharedMenuController].menuItems = nil;
}

- (void)translate {
//    [self routerEventWithName:LLGroupBarPostTranslateClickEvent
//                     userInfo:@{@"post":self.share}];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

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

- (void)unfollow:(LLSimpleUser *)user {
    
    //    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    //    hud.labelText = @"Please wait...";
    //    [self.view addSubview:hud];
    //    [hud show:YES];
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Unfollow
     parameters:@{@"uid":user.uid} success:^(id datas,BOOL hasNext){
         
         __strong typeof (self)strongSelf = weakSelf;
         self.followButton.text = @"+ 关注";
         //         [strongSelf.url.queryValue setValue:@0 forKey:@"follow"];
         //
         //         [hud removeFromSuperview];
         
         //TODO: follow 后就要在 myfriends列表消失
         //         LLSimpleUser *user = [[self.url queryValue] modelFromDictionaryWithClassName:[LLSimpleUser class]];
         //         [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaUnfollowSomeOneNotification" object:user userInfo:[self.url queryValue]];
         
         NSString *message = @"已取消关注.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
         
     } failure:^(NSError *error){
         //         [hud removeFromSuperview];
         //         //TODO: 添加关注失败
         //         NSString *message = @"Unfollow failed.";
         //         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         //         self.fansCell.followStateLabel.text = @"Followed";
     }];
}

- (void)follow:(LLSimpleUser *)user {
    
    //   MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    //    hud.labelText = @"Please wait...";
    //    [self.view addSubview:hud];
    //     [hud show:YES];
    
    __weak typeof(self) weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Follow
     parameters:@{@"uid":user.uid} // @"url.queryValue.uid"
     success:^(id datas,BOOL hasNext){
         
         __strong typeof(self)strongSelf = weakSelf;
         self.followButton.text = @"取消关注";
         //
         //         [strongSelf.url.queryValue setValue:@1 forKey:@"follow"];
         //
         //         [hud removeFromSuperview];
         
         //TODO: follow 后就要在 myfriends列表出现了
         //         LLSimpleUser *user = [[strongSelf.url queryValue] modelFromDictionaryWithClassName:[LLSimpleUser class]];
         //         [[NSNotificationCenter defaultCenter] postNotificationName:@"OllaFollowSomeOneNotification" object:user userInfo:[strongSelf.url queryValue]];
         
         NSString *message = @"关注成功.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     } failure:^(NSError *error){
         DDLogError(@"添加关注失败：%@",error);
         //[hud removeFromSuperview];
         
         //         NSString *message = @"Follow failed.";
         //         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         //         self.fansCell.followStateLabel.text = @"+ Follow";
     }];
}
// 收藏
- (IBAction)doFavorite:(id)sender {
    
//    [self routerEventWithName:LLShareDetailFavoriteButtonClick userInfo:@{@"share":self.share}];
    
    [self routerEventWithName:LLShareDetailEnrollButtonClick userInfo:@{@"share":self.share}];
}

- (IBAction)commentButtonTouchDownEvent:(UIButton *)sender {
    
    self.commentLogo.image = [UIImage imageNamed:@"comment_state_true"];
}

- (IBAction)commentButtonCancelClick:(UIButton *)sender {
    
//    self.commentLogo.image = [UIImage imageNamed:@"comment_state_false"];
}

- (IBAction)shareButtonTouchDownEvent:(UIButton *)sender {
    
    self.shareLogo.image = [UIImage imageNamed:@"share_state_true"];
}

- (IBAction)shareButtonCancelEvent:(UIButton *)sender {
    
//    self.shareLogo.image = [UIImage imageNamed:@"share_state_false"];
}

@end
