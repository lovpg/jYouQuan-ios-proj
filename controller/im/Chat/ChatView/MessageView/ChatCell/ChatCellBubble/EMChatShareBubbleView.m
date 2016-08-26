//
//  LLChatShareBubbleView.m
//  Olla
//
//  Created by Pat on 15/8/25.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "EMChatShareBubbleView.h"
#import "LLShare.h"



NSString *const kRouterEventPersonalBubbleTapEventName = @"kRouterEventPersonalBubbleTapEventName";

#define SHARE_BUBBLE_LEFT_IMAGE_NAME @"chat_groupbar_left_bubble"
#define SHARE_BUBBLE_RIGHT_IMAGE_NAME @"chat_groupbar_right_bubble"

#define SHARE_BUBBLE_LEFT_INSET UIEdgeInsetsMake(36, 15, 36, 15)
#define SHARE_BUBBLE_RIGHT_INSET UIEdgeInsetsMake(36, 15, 36, 15)

#define SHARE_BUBBLE_WIDTH  200
#define SHARE_BUBBLE_HEIGHT 110

@interface EMChatShareBubbleView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *avatorView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation EMChatShareBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        _avatorView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 35, 60, 60)];
        _avatorView.cornerRadius = 3.0f;
        [self addSubview:_avatorView];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatorView.right+10, _titleLabel.bottom+10, 110, 20)];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor lightGrayColor];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_contentLabel];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = CGPointMake(SHARE_BUBBLE_WIDTH / 2, SHARE_BUBBLE_HEIGHT / 2);
        [self addSubview:_indicatorView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float x = self.model.isSender ? 10 : 15;
    _titleLabel.left = x;
    _avatorView.left = x;
    _contentLabel.left = _avatorView.right + 10;
}

- (void)layoutCheckMark {
    self.deliveredView.frame = CGRectMake(self.backImageView.left - 20, self.backImageView.bottom - 16, 16, 16);
    self.readView.frame = CGRectMake(self.backImageView.left - 26, self.backImageView.bottom - 16, 16, 16);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(SHARE_BUBBLE_WIDTH, SHARE_BUBBLE_HEIGHT);
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    BOOL isReceiver = !_model.isSender;
    NSString *imageName = isReceiver ? SHARE_BUBBLE_LEFT_IMAGE_NAME : SHARE_BUBBLE_RIGHT_IMAGE_NAME;
    UIEdgeInsets inset = isReceiver ? SHARE_BUBBLE_LEFT_INSET : SHARE_BUBBLE_RIGHT_INSET;
    NSString *messageContent = model.content;
    self.backImageView.image = [[UIImage imageNamed:imageName] resizableImageWithCapInsets:inset resizingMode:UIImageResizingModeStretch];
    [self.indicatorView stopAnimating];
//    if (model.message.extObject && model.message.extObject.share) {
//        [self setupWithShare:model.message.extObject.share];
//    } else
       if(model.message.ext[@"sid"])
       {
        NSString *shareId = model.message.ext[@"sid"];
        if (shareId.length == 0) {
            return;
        }
        
        LLShare *cacheShare = [LLShare selectWhere:[NSString stringWithFormat:@"shareId='%@'",shareId] groupBy:nil orderBy:nil limit:@"1"].firstObject;
        
        if (cacheShare) {
            EMMessageExtObject *extObj = [[EMMessageExtObject alloc] init];
            extObj.share = cacheShare;
            model.message.extObject = extObj;
            [self setupWithShare:cacheShare:messageContent];
            return;
        }
        [self.indicatorView startAnimating];
        @weakify(self);
        
        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Detail parameters:@{@"shareId":shareId} modelType:[LLShare class] success:^(OllaModel *model) {
            @strongify(self);
            LLShare *share = (LLShare *)model;
            NSString *shareId = self.model.message.ext[@"sid"];
            if (shareId.longLongValue != share.shareId.longLongValue) {
                [self.indicatorView stopAnimating];
                return;
            }
            EMMessageExtObject *extObj = [[EMMessageExtObject alloc] init];
            extObj.share = share;
//            self.model.message.extObject = extObj;
            [LLShare save:share];
            [self setupWithShare:share:messageContent];
            [self setNeedsLayout];
            [self.indicatorView stopAnimating];
        } failure:^(NSError *error) {
            @strongify(self);
            [self.indicatorView stopAnimating];
        }];
    }
    NSString * ext = [model.message.ext objectForKey:@"ext"];
    NSDictionary *extDic;
    if (! ext || [ext isKindOfClass:[NSString class]])
    {
        extDic = [self dictionaryWithJsonString:(NSString*)ext];
    }
    if(extDic[@"id"] || extDic[@"shareId"])
    {
        NSString *shareId = extDic[@"id"] ? extDic[@"id"]: extDic[@"shareId"] ;
        if (shareId.length == 0) {
            return;
        }
        
        LLShare *cacheShare = [LLShare selectWhere:[NSString stringWithFormat:@"shareId='%@'",shareId] groupBy:nil orderBy:nil limit:@"1"].firstObject;
        
        if (cacheShare)
        {
            EMMessageExtObject *extObj = [[EMMessageExtObject alloc] init];
            extObj.share = cacheShare;
           // model.message.extObject = extObj;
            [self setupWithShare:cacheShare:messageContent];
            return;
        }
        [self.indicatorView startAnimating];
        @weakify(self);
        
        [[LLHTTPRequestOperationManager shareManager] GETWithURL:Olla_API_Share_Detail parameters:@{@"shareId":shareId} modelType:[LLShare class] success:^(OllaModel *model) {
            @strongify(self);
            LLShare *share = (LLShare *)model;
           // NSString *shareId = self.model.message.ext[@"sid"];
            NSString *shareId  = share.shareId;
            if (shareId.longLongValue != share.shareId.longLongValue) {
                [self.indicatorView stopAnimating];
                return;
            }
//            EMMessageExtObject *extObj = [[EMMessageExtObject alloc] init];
//            extObj.share = share;
//            self.model.message.extObject = extObj;
            [LLShare save:share];
            [self setupWithShare:share:messageContent];
            [self setNeedsLayout];
            [self.indicatorView stopAnimating];
        } failure:^(NSError *error) {
            @strongify(self);
            [self.indicatorView stopAnimating];
        }];
    }
    
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil)return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)setupWithShare:(LLShare *)share : (NSString*)content
{
    self.titleLabel.text = content;
    self.contentLabel.text = share.content.trim;
    
    CGSize size = [_contentLabel sizeThatFits:CGSizeMake(90, CGFLOAT_MAX)];
    if (size.height > 50) {
        self.contentLabel.height = 50;
    } else {
        self.contentLabel.height = ceilf(size.height);
    }
    NSString *urlString = nil;
    if (share.imageList.count > 0)
    {
        urlString = share.imageList.firstObject;
    } else {
       // urlString = [share.bar smallBarAvator];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    [self.avatorView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"group_bar_default_avatar"]];
    
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventPersonalBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return SHARE_BUBBLE_HEIGHT + 5;
}

@end
