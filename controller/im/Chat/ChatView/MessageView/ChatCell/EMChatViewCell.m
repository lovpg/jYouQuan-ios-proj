/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EMChatViewCell.h"
#import "EMMessage+Helper.h"
#import "UIResponder+Router.h"

NSString *const kResendButtonTapEventName = @"kResendButtonTapEventName";
NSString *const kShouldResendCell = @"kShouldResendCell";

@implementation EMChatViewCell

- (id)initWithMessageModel:(MessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _headImageView.clipsToBounds = YES;
        _headImageView.layer.cornerRadius = HEAD_SIZE / 2;
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = CELLPADDING;
    
    if (self.messageModel.isSender) {
        bubbleFrame.origin.y = CELLPADDING;
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.messageModel.status) {
            case eMessageDeliveryState_Delivering:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case eMessageDeliveryState_Delivered:
            {
                [_activtiy stopAnimating];
                [_activityView setHidden:YES];
                
            }
                break;
            case eMessageDeliveryState_Failure:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - HEAD_PADDING;
        _bubbleView.frame = bubbleFrame;
        
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        
        
        if (self.messageModel.isSender && self.messageModel.type == eMessageBodyType_Voice) {
            frame.origin.x -= 30.0f;
        }
        
        self.activityView.frame = frame;
    }
    else{
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)setMessageModel:(MessageModel *)model
{
    [super setMessageModel:model];
    
    if (model.message.messageType == eMessageTypeGroupChat) {
        _nameLabel.text = model.username;
        _nameLabel.hidden = model.isSender;
    }
    
    _bubbleView.model = self.messageModel;
    // 调用 sizeToFit 后, UIView 会根据子视图的布局调用自身的 sizeThatFit  去确定 frame
    [_bubbleView sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - action

// 重发按钮事件
-(void)retryButtonPressed:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [WCAlertView showAlertWithTitle:@"确定重发该消息?"  message:nil customizationBlock:nil completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView) {
        if (buttonIndex == 1) {
            [weakSelf routerEventWithName:kResendButtonTapEventName
                             userInfo:@{kShouldResendCell:self}];
        }
    } cancelButtonTitle:@"放弃" otherButtonTitles:@"发送", nil];
    
}

#pragma mark - private

- (void)setupSubviewsForMessageModel:(MessageModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setBackgroundImage:[UIImage imageNamed:@"im_error"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
    [_bubbleView removeFromSuperview];
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}

- (EMChatBaseBubbleView *)bubbleViewForMessageModel:(MessageModel *)messageModel
{
    switch (messageModel.type) {
        case eMessageBodyType_Text:
        {
//            if (messageModel.message.extType == EMMessageExtTypeGroupBar) {
//                return [[EMChatGroupBarBubbleView alloc] init];
//            }
            if (messageModel.message.extType == EMMessageExtTypePushGood) {
                return [[EMChatShareBubbleView alloc] init];
            }
            if (messageModel.message.extType == EMMessageExtTypePushComment) {
                return [[EMChatShareBubbleView alloc] init];
            }
            if (messageModel.message.extType == EMMessageExtTypePersonalShare) {
                return [[EMChatShareBubbleView alloc] init];
            }
//            if (messageModel.message.extType == EMMessageExtTypeQuickTutor) {
//                return [[EMChatQuickTutorBubbleView alloc] init];
//            }
//            if (messageModel.message.extType == EMMessageExtTypeQuickTutorRespond) {
//                return [[EMChatQuickTutorRespondBubbleView alloc] init];
//            }
            return [[EMChatTextBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Image:
        {
            return [[EMChatImageBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Voice:
        {
            return [[EMChatAudioBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Location:
        {
            return [[EMChatLocationBubbleView alloc] init];
        }
            break;
        case eMessageBodyType_Video:
        {
            return [[EMChatVideoBubbleView alloc] init];
        }
            break;
        default:
            break;
    }
    
    return nil;
}

+ (CGFloat)bubbleViewHeightForMessageModel:(MessageModel *)messageModel
{
    switch (messageModel.type) {
        case eMessageBodyType_Text:
        {
            EMMessageExtType extType = messageModel.message.extType;
//            if (extType == EMMessageExtTypeGroupBar) {
//                return [EMChatGroupBarBubbleView heightForBubbleWithObject:messageModel];
//            }
//            if (extType == EMMessageExtTypeGroupBarPost) {
//                return [EMChatGroupBarPostBubbleView heightForBubbleWithObject:messageModel];
//            }
            if (extType == EMMessageExtTypePersonalShare) {
                return [EMChatShareBubbleView heightForBubbleWithObject:messageModel];
            }
            if (extType == EMMessageExtTypePushGood) {
                return [EMChatShareBubbleView heightForBubbleWithObject:messageModel];
            }
            if (extType == EMMessageExtTypePushComment) {
                return [EMChatShareBubbleView heightForBubbleWithObject:messageModel];
            }
//            if (extType == EMMessageExtTypeQuickTutorRespond) {
//                return [EMChatQuickTutorRespondBubbleView heightForBubbleWithObject:messageModel];
//            }
            return [EMChatTextBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Image:
        {
            return [EMChatImageBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Voice:
        {
            return [EMChatAudioBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Location:
        {
            return [EMChatLocationBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        case eMessageBodyType_Video:
        {
            return [EMChatVideoBubbleView heightForBubbleWithObject:messageModel];
        }
            break;
        default:
            break;
    }
    
    return HEAD_SIZE;
}

#pragma mark - public

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MessageModel *)model
{
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_PADDING * 2 + HEAD_SIZE;
    if (model.message.messageType == eMessageTypeGroupChat && !model.isSender) {
        headHeight += NAME_LABEL_HEIGHT;
    }
    return MAX(headHeight, bubbleHeight) + CELLPADDING;
}


@end
