//
//  LLEMChatsTableViewCell.m
//  Olla
//
//  Created by Pat on 15/3/20.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEMChatsTableViewCell.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "NSDate+Category.h"
#import "LLBadgeNumberView.h"

@interface LLEMChatsTableViewCell () {
    UIImageView *coverView;
    LLBadgeNumberView *unreadLabel;
    UILabel *nameLabel;
    UILabel *textLabel;
    UILabel *timeLabel;
    UIImageView *genderView;
    UIImageView *nationView;
}

@end

@implementation LLEMChatsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        coverView = [[UIImageView alloc] init];
        coverView.layer.masksToBounds = YES;
        coverView.layer.cornerRadius = 22.0f;
        unreadLabel = [[LLBadgeNumberView alloc] init];
        unreadLabel.font = [UIFont systemFontOfSize:11.0f];
        unreadLabel.textColor = [UIColor whiteColor];
        unreadLabel.layer.masksToBounds = YES;
        unreadLabel.layer.cornerRadius = 8.0f;
        unreadLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        nameLabel.backgroundColor = [UIColor clearColor];
        textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont systemFontOfSize:14.0f];
        textLabel.textColor = [UIColor lightGrayColor];
        textLabel.backgroundColor = [UIColor clearColor];
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:12.0f];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        genderView = [[UIImageView alloc] init];
        nationView = [[UIImageView alloc] init];
        
        [self addSubview:coverView];
        [self addSubview:unreadLabel];
        [self addSubview:nameLabel];
        [self addSubview:textLabel];
        [self addSubview:timeLabel];
        [self addSubview:genderView];
        [self addSubview:nationView];
        
    }
    return self;
}

- (void)setChatsItem:(LLEMChatsItem *)chatsItem
{
    _chatsItem = chatsItem;
    LLUser *userInfo = _chatsItem.userInfo;
    EMConversation *conversation = _chatsItem.conversation;
    [coverView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatar] placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
    unreadLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)conversation.unreadMessagesCount];
    if (conversation.unreadMessagesCount == 0)
    {
        unreadLabel.hidden = YES;
    }
    else
    {
        unreadLabel.hidden = NO;
    }
    nameLabel.text = userInfo.nickname;
    
    NSString *message = [self messageByConversation:conversation];
    textLabel.text = message;
    
    if ([userInfo.gender isEqualToString:@"男"])
    {
        genderView.image = [UIImage imageNamed:@"sex_male"];
    }
    else if ([userInfo.gender isEqualToString:@"女"])
    {
        genderView.image = [UIImage imageNamed:@"sex_female"];
    }
    else
    {
        genderView.image = nil;
    }
    
    nationView.image = [UIImage imageNamed:[LLAppHelper countryIconFromString:userInfo.region]];
    
    timeLabel.text = [self lastMessageTimeByConversation:conversation];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [coverView sd_cancelCurrentImageLoad];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    coverView.frame = CGRectMake(10, 10, 44, 44);
    unreadLabel.frame = CGRectMake(44.0f, 8.0f, 16.0f, 16.0f);
    LLUser *userInfo = _chatsItem.userInfo;
    float nameWidth = [userInfo.nickname sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedSize:CGSizeMake(200, 20)].width;
    nameLabel.frame = CGRectMake(66.0f, 10.0f, nameWidth, 20.0f);
    textLabel.frame = CGRectMake(66.0f, 34.0f, 260.0f, 20.0f);
    
    genderView.frame = CGRectMake(nameLabel.right+5, 10.0f, 20.0f, 20.0f);
    nationView.frame = CGRectMake(genderView.right+5, 10.0f, 20.0f, 20.0f);
    
    timeLabel.frame = CGRectMake(self.width - 130, 10, 120, 20);
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)messageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
//                ret = NSLocalizedString(@"message.image1", @"[image]");
                ret = @"[图片]";
            } break;
            case eMessageBodyType_Text:{
                // 表情映射。
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                ret = didReceiveText;
            } break;
            case eMessageBodyType_Voice:{
               // ret = NSLocalizedString(@"message.voice1", @"[voice]");
                ret = @"[语音]";
            } break;
            case eMessageBodyType_Location: {
//                ret = NSLocalizedString(@"message.location1", @"[location]");
                ret = @"[共享位置]";
            } break;
            case eMessageBodyType_Video: {
               // ret = NSLocalizedString(@"message.video1", @"[video]");
                ret = @"[视频]";
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
}

@end
