//
//  LLShareCommentCell.h
//  Olla
//
//  Created by Pat on 15/5/29.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLGenderImageView.h"
#import "LLCountryImageView.h"
#import "LLRelativeTimeLabel.h"
#import "LLRoundingCornersButton.h"
#import "LLComment.h"
#import "TTTAttributedLabel.h"

static NSString *LLShareCommentAvatorClickEvent = @"LLShareCommentAvatorClickEvent";

static NSString *LLShareCommentImageClickEvent = @"LLShareCommentImageClickEvent";

static NSString *LLShareCommentBackgroundClickEvent = @"LLShareCommentBackgroundClickEvent";

@protocol LLShareCommentCellDelegate <NSObject>

@required //必须实现的方法
- (void)deleteComment:(NSString *)commentId;

@optional

@end


@interface LLShareCommentCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (weak, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet LLRoundingCornersButton *backgroundButton;
@property (weak, nonatomic) IBOutlet UIButton *backgroundButton2;
@property (weak, nonatomic) IBOutlet UIButton *avatorButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet LLGenderImageView *genderView;
@property (weak, nonatomic) IBOutlet LLCountryImageView *countryView;
@property (weak, nonatomic) IBOutlet LLRelativeTimeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *voiceTimeLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@property (nonatomic, strong) LLComment *dataItem;

// ***** 用于判断是否吧主
//@property (nonatomic) LLGroupBarPost *barPost;

@property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;

- (IBAction)avatorClick:(id)sender;
- (IBAction)imageButtonClick:(id)sender;
- (IBAction)backgroundButtonClick:(id)sender;

@end
