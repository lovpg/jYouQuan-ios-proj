//
//  TmcCenterShareViewCell.h
//  iDleChat
//
//  Created by Reco on 16/3/15.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLShare.h"
#import "TTTAttributedLabel.h"
#import "LLGenderImageView.h"
#import "LLCountryImageView.h"
#import <MediaPlayer/MediaPlayer.h>

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
static NSString *LLMyCenterFocusButtonClickEvent = @"LLMyCenterFocusButtonClickEvent";
static NSString *LLMyCenterOptButtonClickEvent = @"LLMyCenterOptButtonClickEvent";
static NSString *LLShareCategoryButtonClickEvent = @"LLShareCategoryButtonClickEvent";
static NSString *LLShareLocationButtonClickEvent = @"LLShareLocationButtonClickEvent";

@interface LLHomeShareViewCell : UITableViewCell<TTTAttributedLabelDelegate>
{
    
    IBOutlet UIButton *shareBgImageView;
    IBOutlet UIImageView *shareBgTureImageView;
    
    __weak IBOutlet UIButton *tagsButton;
    __weak IBOutlet UILabel *enrollCount;
    __weak IBOutlet UIButton *avatarButton;
    
    __weak IBOutlet UIImageView *topImageView;
    IBOutlet TTTAttributedLabel *shareTextLabel;
    IBOutlet OllaImageLimitGridView *imageGroupView;
    IBOutlet UIView *interactiveView;
    
    IBOutlet UIView *locationView;
    IBOutlet UILabel *locationLabel;
    //相对布局
    IBOutlet UILabel *nicknameLabel;
    __weak IBOutlet UIButton *tags2Button;
    
    IBOutlet LLGenderImageView *genderImageView;
    
    __weak IBOutlet UIImageView *locationImage;
    IBOutlet UIButton *groupBarButton;
    IBOutlet UILabel *timeLabel;
    
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
@property (weak, nonatomic) IBOutlet UIButton *optButton;

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (nonatomic, strong) LLShare *dataItem;

- (float)shareCellHeight:(LLShare *)dataItem;

@property(nonatomic,assign) BOOL displayLocation;
@property(nonatomic,assign) BOOL needSelectionBackgroundImage;
@property(nonatomic,assign) BOOL showAllContent;

- (void)decreaseLikeNum;
- (void)increaseLikeNum;
- (void)increaseCommentNum;
@end
