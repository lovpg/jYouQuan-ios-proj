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

#import "EMChatBaseBubbleView.h"

NSString *const kRouterEventChatCellBubbleTapEventName = @"kRouterEventChatCellBubbleTapEventName";

@interface EMChatBaseBubbleView ()

@end

@implementation EMChatBaseBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _backImageView = [[UIImageView alloc] init];
        _backImageView.userInteractionEnabled = YES;
        _backImageView.multipleTouchEnabled = YES;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_backImageView];
        
        _deliveredView = [[UIImageView alloc] init];
        _deliveredView.image = [UIImage imageNamed:@"chat_message_checkMark"];
        _deliveredView.hidden = YES;
        [self addSubview:_deliveredView];
        
        _readView = [[UIImageView alloc] init];
        _readView.image = [UIImage imageNamed:@"chat_message_checkMark"];
        _readView.hidden = YES;
        [self addSubview:_readView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
        self.tapGestureRecognizer = tap;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutCheckMark];
}

- (void)layoutCheckMark {
    self.deliveredView.frame = CGRectMake(self.backImageView.left - 20, self.backImageView.bottom - 16, 16, 16);
    self.readView.frame = CGRectMake(self.backImageView.left - 26, self.backImageView.bottom - 16, 16, 16);
    if (self.model.isSender) {
        if (self.model.message.isDeliveredAcked) {
            self.deliveredView.hidden = NO;
        } else {
            self.deliveredView.hidden = YES;
        }
        if (self.model.message.isReadAcked) {
            self.readView.hidden = NO;
        } else {
            self.readView.hidden = YES;
        }
    } else {
        self.deliveredView.hidden = YES;
        self.readView.hidden = YES;
    }
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    _model = model;
    
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? BUBBLE_LEFT_IMAGE_NAME : BUBBLE_RIGHT_IMAGE_NAME;
    UIEdgeInsets inset = isReceiver ? BUBBLE_LEFT_INSET : BUBBLE_RIGHT_INSET;

    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
}

#pragma mark - public

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 30;
}

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventChatCellBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

- (void)progress:(CGFloat)progress
{
    //[UIProgressView setProgress:progress animated:YES];
}

@end
