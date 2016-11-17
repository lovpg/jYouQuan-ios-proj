//
//  LLShareDetailTableViewCellRefactor.h
//  Olla
//
//  Created by Charles on 15/6/25.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPhotoLayoutManager.h"
#import "LLUser.h"
//#import "LLGroupBarPostCell.h"
static NSString *LLFollowButtonClickEvent = @"LLFollowButtonClickEvent";
static NSString *LLShareDetailAvatarButtonClick = @"LLShareDetailAvatarButtonClick";
static NSString *LLShareDetailLikeButtonClickEvent = @"LLShareDetailLikeButtonClickEvent";
static NSString *LLShareDetailCommentButtonClickEvent = @"LLShareDetailCommentButtonClickEvent";
static NSString *LLShareDetailReportButtonClick = @"LLShareDetailReportButtonClick";
static NSString *LLShareDetailShareButtonClick = @"LLShareDetailShareButtonClick";
static NSString *LLShareDetailFavoriteButtonClick = @"LLShareDetailFavoriteButtonClick";
static NSString *LLShareDetailEnrollButtonClick = @"LLShareDetailEnrollButtonClick";
static NSString *LLShareDetailThirdPlatfomButtonClickEvent = @"LLShareDetailThirdPlatfomButtonClickEvent";

@interface LLShareDetailTableViewCellRefactor : UITableViewCell {
    
    LLPhotoLayoutManager *layoutManager;
    LLUser *currentUser;
    LLUserService *userSerive ;
}
@property (weak, nonatomic) IBOutlet UILabel *enrollCountLabel;

@property (strong, nonatomic) LLShare *share;

@property (weak, nonatomic) IBOutlet UIButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIImageView *locationImage;
@property (weak, nonatomic) IBOutlet UIButton *tags2button;

@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *countryImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *shareDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet OllaImageLimitGridView *imagesContainer;
@property (weak, nonatomic) IBOutlet UIView *locationContainerView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIView *selectionButtonsContainerView;
@property (weak, nonatomic) IBOutlet UILabel *likeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentNumberLabel;

@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UIView *line3;

@property (weak, nonatomic) IBOutlet UIImageView *likeLogo;
@property (weak, nonatomic) IBOutlet UIImageView *commentLogo;
@property (weak, nonatomic) IBOutlet UIImageView *shareLogo;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteLogo;

- (void)increaseCommentNum;
- (void)decreaseCommentNum;

// if like is yes, then increase the likeNum, or decrease it.
- (void)changeLikeNum:(BOOL)like;

- (float)shareDetaileCellHeight;

- (IBAction)longPressPostHandler:(id)sender;
- (void)copyText;

@end
