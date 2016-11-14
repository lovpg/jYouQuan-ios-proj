//
//  LLMyCenterShareTableViewCellRefactor.h
//  Olla
//
//  Created by Charles on 15/8/17.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
#import "LLGenderImageView.h"
#import "LLCountryImageView.h"

static NSString *LLMyCenterShareTranslateClickEvent = @"LLMyCenterShareTranslateClickEvent";
static NSString *LLMyCenterShareLikeClickEvent = @"LLMyCenterShareLikeClickEvent";
static NSString *LLMyCenterShareCommentClickEvent = @"LLMyCenterShareCommentClickEvent";
static NSString *LLMyCenterShareBackgroundButtonClickEvent = @"LLMyCenterShareBackgroundButtonClickEvent";
static NSString *LLMyCenterShareTapGestureClickEvent = @"LLMyCenterShareTapGestureClickEvent";
static NSString *LLMyCenterShareShareButtonClickEvent = @"LLMyCenterShareShareButtonClickEvent";
static NSString *LLMyCenterShareAvatarButtonClickEvent = @"LLMyCenterShareAvatarButtonClickEvent";
static NSString *LLMyCenterShareNotFullFillProfileEvent = @"LLMyCenterShareNotFullFillProfileEvent";
static NSString *LLMyCenterShareRewardButtonClickEvent = @"LLMyCenterShareRewardButtonClickEvent";
static NSString *LLMyCenterShareThirdPlatfomButtonClickEvent = @"LLMyCenterShareThirdPlatfomButtonClickEvent";

@interface LLMyCenterShareTableViewCellRefactor : UITableViewCell <TTTAttributedLabelDelegate> {
    
    IBOutlet UIButton *shareBgImageView;
    IBOutlet UIImageView *shareBgTureImageView;
    
    __weak IBOutlet UILabel *enrollCount;
    __weak IBOutlet UIButton *avatarButton;
    
    __weak IBOutlet UIButton *tags2button;
    IBOutlet TTTAttributedLabel *shareTextLabel;
    IBOutlet OllaImageLimitGridView *imageGroupView;
    IBOutlet UIView *interactiveView;
    
    IBOutlet UIView *locationView;
    IBOutlet UILabel *locationLabel;
    
    IBOutlet UIButton *tagsButton;
    //相对布局
    IBOutlet UILabel *nicknameLabel;
    IBOutlet LLGenderImageView *genderImageView;
    IBOutlet LLCountryImageView *countryImageView;
    
    IBOutlet UIButton *groupBarButton;
    IBOutlet UILabel *timeLabel;
    
    IBOutlet UIImageView *locationImage;
    //要设置选中背景的拉升图片
    IBOutlet OllaButton *likeButton;
    IBOutlet UIImageView *likeImageView;
    IBOutlet UILabel *likeNumLabel;
    IBOutlet UIButton *commentButton;
    IBOutlet UILabel *commentLabel;
    IBOutlet UIButton *reportButton;
    
    
    __weak IBOutlet UIImageView *commentLogo;
    __weak IBOutlet UIImageView *shareLogo;
    
    __weak IBOutlet UILabel *coinsNum;
    __weak IBOutlet UIImageView *coinsLogo;
}

@property (nonatomic, strong) LLShare *dataItem;

- (float)shareCellHeight:(LLShare *)dataItem;

@property(nonatomic,assign) BOOL displayLocation;
@property(nonatomic,assign) BOOL needSelectionBackgroundImage;
@property(nonatomic,assign) BOOL showAllContent;

- (void)decreaseLikeNum;
- (void)increaseLikeNum;
- (void)increaseCommentNum;


@end
