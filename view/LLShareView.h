//
//  LLShareView.h
//  Olla
//
//  Created by Pat on 15/8/19.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LLShareTypeText,
    LLShareTypeTextAndImage
} LLShareExtType;

@interface LLShareExt : NSObject

@property (nonatomic, assign) LLShareExtType type;
@property(nonatomic,strong) NSString *shareText;
@property(nonatomic,strong) UIImage *shareImage;
@property(nonatomic,strong) NSString *shareURL;
@property(nonatomic,strong) NSString *wxShareURL;
@property(nonatomic,strong) NSString *shareTitle;
@property(nonatomic,strong) NSString *shareImageURL;
@property(nonatomic,strong) NSDictionary *userInfo;
@property(nonatomic,assign) BOOL ollaViewHidden;

@end

typedef enum : NSUInteger {
    LLShareTypeWeixin        = 10,
    LLShareTypeWeixinMoments = 11,
    LLShareTypeSinaWeibo     = 12,
    LLShareTypeFacebook      = 13,
    LLShareTypeTwitter       = 14,
    LLShareTypeOlla          = 15,
    LLShareTypeVK          = 16
} LLShareType;

@protocol LLShareViewDelegate;

@interface LLShareView : UIView

@property (nonatomic,weak) id<LLShareViewDelegate> delegate;
@property (nonatomic,strong) LLShareExt *shareExt;
@property (nonatomic,strong) IBOutlet UIButton *maskView;
@property (nonatomic,strong) IBOutlet UIView *shareContentView;
@property (nonatomic,strong) IBOutlet UIImageView *blurView;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UIView *ollaView;

@property (nonatomic, strong) NSString *type;

- (void)show;
- (void)hide;

@end

@protocol LLShareViewDelegate <NSObject>

@optional
- (void)shareToVKWithExt:(LLShareExt *)shareExt;
- (void)shareToOllaWithExt:(LLShareExt *)shareExt;

@end
