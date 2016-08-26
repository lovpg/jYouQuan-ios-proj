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

#import "EMChatViewBaseCell.h"
#import "UIImageView+WebCache.h"

NSString *const kRouterEventChatHeadImageTapEventName = @"kRouterEventChatHeadImageTapEventName";

NSString *const kRouterEventLongPressEventName = @"kRouterEventLongPressEventName";

@interface EMChatViewBaseCell()

@end

@implementation EMChatViewBaseCell

- (id)initWithMessageModel:(MessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        _headImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_nameLabel];
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5;
        [self addGestureRecognizer:lpgr];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.bubbleView setNeedsLayout];
    if (_messageModel.isSender) {
        _headImageView.frame = CGRectMake(self.bounds.size.width - _headImageView.frame.size.width - HEAD_PADDING, self.bounds.size.height - HEAD_SIZE - CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    } else {
        _headImageView.frame = CGRectMake(HEAD_PADDING, self.bounds.size.height - HEAD_SIZE - CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
    
    _nameLabel.frame = CGRectMake(CGRectGetMinX(_headImageView.frame), CGRectGetMaxY(_headImageView.frame), CGRectGetWidth(_headImageView.frame), NAME_LABEL_HEIGHT);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    
    _nameLabel.hidden = (messageModel.messageType == eMessageTypeChat);
    
    UIImage *placeholderImage = [UIImage imageNamed:@"headphoto_default"];
    [self.headImageView sd_setImageWithURL:_messageModel.headImageURL placeholderImage:placeholderImage];
}

#pragma mark - private

-(void)headImagePressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{KMESSAGEKEY:self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public

- (void)setupSubviewsForMessageModel:(MessageModel *)model
{
    if (model.isSender) {
        self.headImageView.frame = CGRectMake(self.bounds.size.width - HEAD_SIZE - HEAD_PADDING, self.bounds.size.height - HEAD_SIZE - CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
    else{
        self.headImageView.frame = CGRectMake(0, self.bounds.size.height - HEAD_SIZE - CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
}

+ (NSString *)cellIdentifierForMessageModel:(MessageModel *)model
{
    NSString *identifier = @"MessageCell";
    
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    } else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.type)
    {
        case eMessageBodyType_Text:
        {
            if (model.message.extType == EMMessageExtTypeGroupBar) {
                identifier = [identifier stringByAppendingString:@"GroupBar"];
            } else if (model.message.extType == EMMessageExtTypeGroupBarPost) {
                identifier = [identifier stringByAppendingString:@"GroupBarPost"];
            } else if (model.message.extType == EMMessageExtTypePersonalShare) {
                identifier = [identifier stringByAppendingString:@"PersonalShare"];
            } else if (model.message.extType == EMMessageExtTypeQuickTutor) {
                identifier = [identifier stringByAppendingString:@"QuickTutor"];
            } else if (model.message.extType == EMMessageExtTypeQuickTutorRespond) {
                identifier = [identifier stringByAppendingString:@"QuickTutorRespond"];
            } else if (model.message.extType == EMMessageExtTypePushGood) {
                identifier = [identifier stringByAppendingString:@"PersonalShare"];
            }else if (model.message.extType == EMMessageExtTypePushComment) {
                identifier = [identifier stringByAppendingString:@"PersonalShare"];
            }
            else {
                identifier = [identifier stringByAppendingString:@"Text"];
            }
        }
            break;
        case eMessageBodyType_Image:
        {
            identifier = [identifier stringByAppendingString:@"Image"];
        }
            break;
        case eMessageBodyType_Voice:
        {
            identifier = [identifier stringByAppendingString:@"Audio"];
        }
            break;
        case eMessageBodyType_Location:
        {
            identifier = [identifier stringByAppendingString:@"Location"];
        }
            break;
        case eMessageBodyType_Video:
        {
            identifier = [identifier stringByAppendingString:@"Video"];
        }
            break;
            
        default:
            break;
    }
    
    return identifier;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)lgr {
    [self routerEventWithName:kRouterEventLongPressEventName userInfo:@{@"longPressGestureRecognizer" : lgr}];
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MessageModel *)model
{
    return HEAD_SIZE + CELLPADDING;
}

@end
