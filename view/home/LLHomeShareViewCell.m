//
//  TmcCenterShareViewCell.m
//  iDleChat
//
//  Created by Reco on 16/3/15.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LLHomeShareViewCell.h"
#import "LLPhotoLayoutManager.h"
#import "LLSupplyProfileService.h"
#import "LLThirdCollection.h"
#import "LLHomeHeadCell.h"
#import "LLUserService.h"

@implementation LLHomeShareViewCell
{
    LLPhotoLayoutManager *layoutManager;
    LLThirdCollection *collection;
    LLUserService *userService;
    LLUser *currentUser;
}

-(void)awakeFromNib
{
    self.needSelectionBackgroundImage = YES;
    layoutManager = [[LLPhotoLayoutManager alloc] init];
    UIImage *sourceImage = [[UIImage imageNamed:@"group_bar_homepage_post_source_new"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    [groupBarButton setBackgroundImage:sourceImage forState:UIControlStateNormal];
    shareTextLabel.delegate = self;
    shareTextLabel.numberOfLines = 0;
    shareTextLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor blueColor], NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone]};
    shareTextLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    userService = [[LLUserService alloc]init];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
     timeLabel.hidden = YES;
    shareBgImageView.cornerRadius = 0.f;
    shareBgImageView.borderWidth = 1.f;
    shareBgImageView.borderColor = [UIColor colorWithRed:220 / 255.f green:220 / 255.f blue:220 / 255.f alpha:1.f];
    
    [avatarButton sd_setImageWithURL:[NSURL URLWithString:self.dataItem.user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
    avatarButton.cornerRadius = avatarButton.height / 2.f;
    
    nicknameLabel.text = self.dataItem.user.nickname;
    nicknameLabel.width = [self.dataItem.user.nickname sizeWithFont:[UIFont systemFontOfSize:16.f] constrainedSize:CGSizeMake(320, 21)].width + 15.f ;
    if (nicknameLabel.width > 115.f)
    {
        nicknameLabel.width = 115.f;
    }
    
    genderImageView.gender = self.dataItem.user.gender;
    genderImageView.originX = nicknameLabel.width+nicknameLabel.originX;
    
    
    CGFloat topMargin = (25+21+22)/2+45;// 20是卡片的间距
    CGFloat spacing1 = 11.f;
    CGFloat spacing2 = 25.f/2;
    //CGFloat spacing3 = 25.f/2;
    // CGFloat bottomMargin = 20.f;
    
    CGFloat y = topMargin;
    
    // 相对布局好
    NSString *textContent = self.dataItem.content;
    if ([textContent length])
    {
        shareTextLabel.text = textContent;
        CGSize size = [textContent sizeWithFont:App_Text_Font(15) constrainedSize:CGSizeMake(288, self.showAllContent ? MAXFLOAT : 80)];
        shareTextLabel.height = size.height;
        
        shareTextLabel.originY = y;
        
        y = y+size.height+spacing1;
    }
    
    if ([self.dataItem.imageList count]>0)
    {
        // 原图==》缩略图
        if ([self.dataItem.imageList count] == 1)
        {
            if (self.dataItem.vedioUrl.length > 0)
            {
                NSString *imageUrl = self.dataItem.imageList.firstObject;
                NSArray *imageArr = [NSArray arrayWithObject:imageUrl];
                layoutManager.photos = imageArr;
            }
            else
            {
                layoutManager.photos = @[[LLAppHelper oneShareThumbImageURLWithString:self.dataItem.imageList.firstObject]];
            }
        }
        else
        {
            NSMutableArray *thumbImages = [NSMutableArray array];
            for (NSString *originImage in self.dataItem.imageList)
            {
                [thumbImages addObject:[LLAppHelper shareThumbImageURLWithString:originImage]];
            }
            layoutManager.photos = thumbImages;
        }
        
        
        
        
        LLPhotoLayout *layoutView = layoutManager.photoLayout;
        if (self.dataItem.vedioUrl.length > 0)
        {
            layoutView.isMovie = YES;
            layoutView.videoUrl = self.dataItem.vedioUrl;
        }
        
        layoutView.originX = 0;
        layoutView.originY = y;
        [self addSubview:layoutView];
        
        y += ([layoutView layoutHeight] + spacing2);
        
    }
    else
    {
        //imageGroupView.height = 0.f;
        [imageGroupView removeFromSuperview];//TODO: 这样会不会在复用这个cell时有问题
    }
    
    //interactiveView.originY = imageGroupView.originY+imageGroupView.height+10.f;// 加了这句，位置反而不正常了！!
    collection = self.dataItem.collection;
    if (_displayLocation && collection )
    {
        locationImage.image = [UIImage imageNamed:@"transfer_24"];
        NSString *title = [NSString stringWithFormat:@"[%@] %@", collection.platform,collection.title];
        locationLabel.text = title;
        locationView.originY = y;
        locationView.hidden = NO;
    }
    else if (_displayLocation && [self.dataItem.address length])
    {
        locationLabel.text = self.dataItem.address;
        locationView.originY = y;
        locationView.hidden = NO;
    }
    else
    {
        locationView.hidden = YES;
    }
    tagsButton.text =  [LLAppHelper getNamefromCategory:self.dataItem.tags];
    
    //    likeButton.actionName = self.dataItem.good ? @"unlike" : @"like";
    likeNumLabel.text = [NSString stringWithFormat:@"%d", self.dataItem.goodCount];
    commentLabel.text = [NSString stringWithFormat:@"%d", self.dataItem.commentCount];
    enrollCount.text = [NSString stringWithFormat:@"%d", self.dataItem.enrollCount];
    //    coinsNum.text = [NSString stringWithFormat:@"%d", self.dataItem.donationCount];
    
    //    if (self.dataItem.donationCount > 0) {
    //        coinsLogo.image = [UIImage imageNamed:@"donate_state_true"];
    //    } else {
    //        coinsLogo.image = [UIImage imageNamed:@"donate_state_false"];
    //    }
    
    // self.likeLogo.image = self.share.good ? [UIImage imageNamed:@"share_like_new_state_true"] : [UIImage imageNamed:@"share_like_new_state_false"];
//    if (self.dataItem.good)
//    {
//        likeImageView.image = [UIImage imageNamed:@"praise_count"];
//    }
//    else
//    {
//        likeImageView.image = [UIImage imageNamed:@"praise_count"];
//    }
    
//    if(![self.dataItem.user.uid isEqualToString:@"4463704"])
//    {
//        self.followButton.text = @"置顶";
//    }
    
//    timeLabel.text = [NSString stringWithFormat:@"%f", self.dataItem.posttime];
//    timeLabel.text = [self.dataItem timeString];
    
     LLUser *user = [userService getMe];
    if(![user.uid isEqualToString:@"10000"])
    {
        self.optButton.hidden = YES;
    }
    if(!self.dataItem.top)
    {
        topImageView.hidden = YES;
    }
    [self loadFriendUserInfo];

}




- (float)shareCellHeight:(LLShare *)dataItem {
    
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

- (void) loadFriendUserInfo
{
    LLSimpleUser *simpleUser = self.dataItem.user;
    NSLog(@"%@", simpleUser.nickname);
    [userService get:simpleUser.uid
            success:^(LLUser *user)
             {
                 currentUser = user;
                 if ( ![[[userService getMe] uid] isEqualToString:self.dataItem.user.uid] && !currentUser.follow )
                 {
                     self.followButton.text =  @"+ 关注";
                 }
                 else
                 {

                     timeLabel.hidden = NO;
                     timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.dataItem.posttime/1000] formatRelativeTime];
                     self.followButton.hidden = YES;
                 }
             }
               fail:^(NSError *error)
             {
                 NSLog(@"%@",error);
             }];
}

//相对布局，这里打住
- (void)addConstraintsToUserView{
    
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
//    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nicknameLabel]-[genderImageView]-[countryImageView]-|" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:NSDictionaryOfVariableBindings(nicknameLabel, genderImageView, countryImageView)];
//    [self addConstraints:constraints];
//    
}

#pragma mark - 点赞相关
// 取消点赞
- (void)decreaseLikeNum
{
    
    NSInteger count = [likeNumLabel.text integerValue] - 1 ;
    if (count < 0) {
        count = 0;
    }
    [self.dataItem setValue:@(count) forKey:@"goodCount"];
    likeNumLabel.text = [NSString stringWithFormat:@"%ld", count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListDecreased" object:nil];
    
}

// 点赞
- (void)increaseLikeNum
{
    
    int count = [likeNumLabel.text intValue] + 1;
    
    [self.dataItem setValue:@(count) forKey:@"goodCount"];//使用model好
    likeNumLabel.text = [NSString stringWithFormat:@"%d",count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListIncreased" object:nil];
}



- (void)increaseCommentNum{
    
    int count = [commentLabel.text intValue]+1;
    [(LLShare *)self.dataItem setCommentCount:count];
    commentLabel.text = [NSString stringWithFormat:@"%d",[commentLabel.text intValue] + 1];
    
}

- (IBAction)groupBarButtonClick:(id)sender
{
    [self routerEventWithName:@"LLGroupBarDetail" userInfo:@{@"share":self.dataItem}];
}
- (IBAction)enrollButtonClick:(id)sender
{
    
    [self routerEventWithName:LLMyCenterShareCommentClickEvent userInfo:@{@"dataItem":self.dataItem}];
}
- (IBAction)followClicked:(id)sender
{
       currentUser.follow?[self unfollow:self.dataItem.user]:[self follow:self.dataItem.user];
}

- (void)unfollow:(LLSimpleUser *)user {
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Unfollow
     parameters:@{@"uid":user.uid}
     success:^(id datas,BOOL hasNext)
    {
         self.followButton.text = @"+ 关注";
         
         NSString *message = @"已取消关注.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
         
     }
     failure:^(NSError *error)
    {

          //TODO: 添加关注失败
          NSString *message = @"取消关注失败.";
          [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
          self.followButton.text = @"- 取关";
     }];
}

- (void)follow:(LLSimpleUser *)user
{
    
    [[LLHTTPRequestOperationManager shareManager]
     GETWithURL:Olla_API_Follow
     parameters:@{@"uid":user.uid}
     success:^(id datas,BOOL hasNext)
    {
        timeLabel.hidden = NO;
        timeLabel.text = [[NSDate dateWithTimeIntervalSince1970:self.dataItem.posttime/1000] formatRelativeTime];
        self.followButton.hidden = YES;
         NSString *message = @"关注成功.";
         [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
         
     } failure:^(NSError *error){
         DDLogError(@"添加关注失败：%@",error);
         //[hud removeFromSuperview];
         
          NSString *message = @"关注失败，请重试.";
          [JDStatusBarNotification showWithStatus:message dismissAfter:1.f styleName:JDStatusBarStyleDark];
          self.followButton.text = @"+ 关注";
     }];
}

- (IBAction)toThirdCollection:(id)sender
{
    if(collection)
    {
        [self routerEventWithName:LLMyCenterShareThirdPlatfomButtonClickEvent userInfo:@{@"dataItem":self.dataItem}];
    }
    else
    {
        [self routerEventWithName:LLMyCenterShareCommentClickEvent userInfo:@{@"dataItem":self.dataItem}];
    }
}
- (IBAction)optAction:(id)sender
{
    [self routerEventWithName:LLMyCenterOptButtonClickEvent userInfo:@{@"dataItem":self.dataItem}];
}

- (IBAction)likeButtonClick:(id)sender
{
    
    POPSpringAnimation *springAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    springAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
    springAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.1, 1.1f)];
    [likeImageView pop_addAnimation:springAnimation forKey:@"com.olla.animation.like"];
    
    if (self.dataItem.good) {
        [self decreaseLikeNum];
    } else {
        [self increaseLikeNum];
    }
    
    if (self.dataItem.good) {
        likeImageView.image = [UIImage imageNamed:@"praise_count"];
    } else {
        likeImageView.image = [UIImage imageNamed:@"praise_count"];
    }
    
    //    [self routerEventWithName:LLMyCenterShareLikeClickEvent userInfo:@{@"isGood":@(self.dataItem.good), @"dataItem":self.dataItem, @"isShare":self.dataItem.bar ? @"NO" : @"YES"}];
    self.dataItem.good = !self.dataItem.good;
    
    //  [UIImage imageNamed:@"share_like_new_state_true"] : [UIImage imageNamed:@"share_like_new_state_false"];
    
    
}

- (IBAction)commentButtonClick:(id)sender
{
    [self routerEventWithName:LLMyCenterShareCommentClickEvent userInfo:@{@"dataItem":self.dataItem}];
}

- (IBAction)commentButtonCancelEvent:(UIButton *)sender {
    //    commentLogo.image = [UIImage imageNamed:@"comment_state_false"];
}

- (IBAction)commentButtonTouchDownEvent:(UIButton *)sender {
    
    //    commentLogo.image = [UIImage imageNamed:@"comment_state_true"];
}

//- (void)doAction:(id)sender{
//
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
//
//    [super doAction:sender];
//
//}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [self routerEventWithName:LLShareTextURLClickEvent userInfo:@{@"url":url}];
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber
{
    [self routerEventWithName:LLShareTextPhoneNumberClickEvent userInfo:@{@"phoneNumber":phoneNumber}];
}

- (IBAction)longPressPostHandler:(UIGestureRecognizer *)sender
{
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

- (void)copyText
{
    LLShare *share = self.dataItem;
    [[UIPasteboard generalPasteboard] setString:share.content];
    [[UIApplication sharedApplication].keyWindow.rootViewController showHint:@"Copy to pasteboard"];
    [UIMenuController sharedMenuController].menuItems = nil;
}

- (IBAction)detail:(id)sender
{
    [self routerEventWithName:LLMyCenterShareCommentClickEvent userInfo:@{@"dataItem":self.dataItem}];
}

- (IBAction)backgroundButtonClick:(id)sender {
    
    //    NSIndexPath *indexPath = self.
    [self routerEventWithName:LLMyCenterShareBackgroundButtonClickEvent userInfo:@{@"share":self.dataItem}];
}

- (IBAction)tapHandler:(id)sender {
    
    [self routerEventWithName:LLMyCenterShareTapGestureClickEvent userInfo:@{@"share":self.dataItem}];
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
//点击分享
- (IBAction)shareButtonClick:(id)sender
{
    
    
    [self routerEventWithName:LLMyCenterShareShareButtonClickEvent userInfo:@{@"share":self.dataItem}];
    
}

- (IBAction)shareButtonTouchDownEvent:(UIButton *)sender {
    
    //    shareLogo.image = [UIImage imageNamed:@"share_state_true"];
}

- (IBAction)shareButtonTouchCancel:(UIButton *)sender {
    
    //    shareLogo.image = [UIImage imageNamed:@"share_state_false"];
}

- (IBAction)avatarButtonClick:(id)sender {
    
    [self routerEventWithName:LLMyCenterShareAvatarButtonClickEvent userInfo:@{@"user":self.dataItem.user}];
}

- (IBAction)rewardButtonClick:(id)sender {
    
    [self routerEventWithName:LLMyCenterShareRewardButtonClickEvent userInfo:@{@"share":self.dataItem}];
}




@end
