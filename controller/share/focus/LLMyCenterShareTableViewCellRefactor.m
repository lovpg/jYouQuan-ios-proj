//
//  LLMyCenterShareTableViewCellRefactor.m
//  Olla
//
//  Created by Charles on 15/8/17.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLMyCenterShareTableViewCellRefactor.h"
#import "LLPhotoLayoutManager.h"
#import "LLSupplyProfileService.h"
#import "LLThirdCollection.h"

@implementation LLMyCenterShareTableViewCellRefactor
{
    LLPhotoLayoutManager *layoutManager;
    LLThirdCollection *collection;
    
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
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    shareBgImageView.cornerRadius = 3.f;
    shareBgImageView.borderWidth = 1.f;
    shareBgImageView.borderColor = [UIColor colorWithRed:220 / 255.f green:220 / 255.f blue:220 / 255.f alpha:1.f];
    
    [avatarButton sd_setImageWithURL:[NSURL URLWithString:self.dataItem.user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default_128"]];
    avatarButton.cornerRadius = avatarButton.height / 2.f;
    
    nicknameLabel.text = self.dataItem.user.nickname;
    nicknameLabel.width = [self.dataItem.user.nickname sizeWithFont:[UIFont systemFontOfSize:16.f] constrainedSize:CGSizeMake(320, 21)].width + 5.f ;
    if (nicknameLabel.width>95.f)
    {
        nicknameLabel.width = 95.f;
    }
    
    genderImageView.gender = self.dataItem.user.gender;
    genderImageView.originX = nicknameLabel.width+nicknameLabel.originX;
    
    countryImageView.region = self.dataItem.user.region;
    countryImageView.originX = genderImageView.width+genderImageView.originX+2.f;
    
    CGFloat topMargin = (25+21+22)/2+45;// 20是卡片的间距
    CGFloat spacing1 = 11.f;
    CGFloat spacing2 = 25.f/2;
    //CGFloat spacing3 = 25.f/2;
    // CGFloat bottomMargin = 20.f;
    
    CGFloat y = topMargin;
    tagsButton.text =  [LLAppHelper getNamefromCategory:self.dataItem.tags];
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
            layoutManager.photos = @[[LLAppHelper oneShareThumbImageURLWithString:self.dataItem.imageList.firstObject]];
        }
        else
        {
            NSMutableArray *thumbImages = [NSMutableArray array];
            for (NSString *originImage in self.dataItem.imageList) {
                [thumbImages addObject:[LLAppHelper shareThumbMidImageURLWithString:originImage]];
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
//    
//    interactiveView.originY = imageGroupView.originY+imageGroupView.height+10.f;// 加了这句，位置反而不正常了！!
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
    if (self.dataItem.good)
    {
        likeImageView.image = [UIImage imageNamed:@"praise_count"];
    }
    else
    {
        likeImageView.image = [UIImage imageNamed:@"praise_count"];
    }
    
    timeLabel.text = [NSString stringWithFormat:@"%f", self.dataItem.posttime];
    timeLabel.text = [self.dataItem timeString];
    
//    if (self.dataItem.bar) {
//        [groupBarButton setTitle:self.dataItem.bar.nickname forState:UIControlStateNormal];
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
}

- (float)shareCellHeight:(LLShare *)dataItem
{
    //固定的头像信息
    CGFloat topMargin = (25+21+22)/2+45;
    CGFloat spacing1 = 11.f;
    CGFloat spacing2 = 25.f/2;
    CGFloat spacing3 = 25.f/2;
    CGFloat bottomMargin = 76/2.f;
    CGFloat height = topMargin;
    NSString *textContent = dataItem.content;
    if ([textContent length])
    {
        CGSize size = [textContent sizeWithFont:App_Text_Font(15) constrainedSize:CGSizeMake(288, self.showAllContent ? MAXFLOAT : 80)];
        height += (size.height+spacing1);
    }
    
    CGFloat imageGroupViewHeight = 0.f;
    if ([dataItem.imageList count]>0)
    {
        
        //imageGroupViewHeight=[OllaImageLimitGridView heightWhenImagesCount:[dataItem.imageList count] imageSize:CGSizeMake(80, 80)];
        if(!layoutManager)
        {
            layoutManager = [[LLPhotoLayoutManager alloc] init];
        }
        layoutManager.photos = dataItem.imageList;
        imageGroupViewHeight = [layoutManager.photoLayout layoutHeight];
        
        height += (imageGroupViewHeight+spacing2);
    }
    
    if (self.displayLocation && [dataItem.address length])
    {
        height += (25.f+spacing3);
    }
    
    return height + bottomMargin;
}

//相对布局，这里打住
- (void)addConstraintsToUserView
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nicknameLabel]-[genderImageView]-[countryImageView]-|" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:NSDictionaryOfVariableBindings(nicknameLabel, genderImageView, countryImageView)];
    [self addConstraints:constraints];
}

#pragma mark - 点赞相关
// 取消点赞
- (void)decreaseLikeNum
{
    
    NSInteger count = [likeNumLabel.text integerValue] - 1 ;
    if (count < 0)
    {
        count = 0;
    }
    [self.dataItem setValue:@(count) forKey:@"goodCount"];
    likeNumLabel.text = [NSString stringWithFormat:@"%ld", count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListDecreased" object:nil];
    
}

// 点赞
- (void)increaseLikeNum{
    
    int count = [likeNumLabel.text intValue] + 1;
    
    [self.dataItem setValue:@(count) forKey:@"goodCount"];//使用model好
    likeNumLabel.text = [NSString stringWithFormat:@"%d",count];
    
    // 发送通知,更新点赞列表
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LikeListIncreased" object:nil];
}

- (IBAction)toThirdPlatform:(id)sender
{
    if(collection)
    {
        [self routerEventWithName:LLMyCenterShareThirdPlatfomButtonClickEvent userInfo:@{@"dataItem":self.dataItem}];
    }
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

- (IBAction)likeButtonClick:(id)sender {
    
    // 先判断是否填写资料
//    if ([LLSupplyProfileService sharedService].needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                
//                [self routerEventWithName:LLMyCenterShareNotFullFillProfileEvent userInfo:nil];
//            }
//            
//        }];
//        return;
//    }
    
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

- (IBAction)commentButtonClick:(id)sender {
//    commentLogo.image = [UIImage imageNamed:@"comment_state_false"];
    
    // 先判断是否填写资料
//    if ([LLSupplyProfileService sharedService].needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                
//                [self routerEventWithName:LLMyCenterShareNotFullFillProfileEvent userInfo:nil];
//            }
//            
//        }];
//        return;
//    }
    
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

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [self routerEventWithName:LLShareTextURLClickEvent userInfo:@{@"url":url}];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [self routerEventWithName:LLShareTextPhoneNumberClickEvent userInfo:@{@"phoneNumber":phoneNumber}];
}

- (IBAction)longPressPostHandler:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
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

- (void)translate {
    [self routerEventWithName:LLMyCenterShareTranslateClickEvent
                     userInfo:@{@"post":self.dataItem}];
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
- (IBAction)shareButtonClick:(id)sender {
    
    
    // 先判断是否填写资料
//    if ([LLSupplyProfileService sharedService].needSupply) {
//        [UIAlertView showWithTitle:nil message:@"please fulfill your profile first , tell us who are you" cancelButtonTitle:@"NO" otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
//            
//            if (tapIndex==1) {//OK
//                
//                [self routerEventWithName:LLMyCenterShareNotFullFillProfileEvent userInfo:nil];
//            }
//            
//        }];
//        return;
//    }
//    shareLogo.image = [UIImage imageNamed:@"share_state_false"];
    
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
