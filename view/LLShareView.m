//
//  LLShareView.m
//  Olla
//
//  Created by Pat on 15/8/19.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareView.h"
#import "UMSocial.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UMSocialWechatHandler.h"

@implementation LLShareExt

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shareText = @"Free to talk with foreigners all over the world! >> http://www.olla.im";
        self.shareURL = Olla_APP_WEBSITE_URL;
        self.ollaViewHidden = YES;
    }
    return self;
}

@end

@implementation LLShareView

+ (instancetype)new {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"LLShareView" owner:self options:nil];
     return nibs.firstObject;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}


- (void)show {
    self.maskView.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
    self.cancelButton.cornerRadius = 6;
    [self.cancelButton setBackgroundImage:[UIImage imageWithColor:RGB_DECIMAL(123, 123, 123)] forState:UIControlStateNormal];
    
    UIView *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIImage *orignalImage = [keyWindow imageWithRect:CGRectMake(0, Screen_Height-CGRectGetHeight(self.shareContentView.bounds), CGRectGetWidth(self.shareContentView.bounds), CGRectGetHeight(self.shareContentView.bounds))];
    UIImage * blurImage = [orignalImage blurWithLevel:15];
    self.blurView.image = blurImage;
    
    UIView *blurMaskView = [[UIView alloc] initWithFrame:self.blurView.bounds];
    blurMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.blurView addSubview:blurMaskView];
    self.ollaView.hidden = self.shareExt.ollaViewHidden;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.maskView.alpha = 0;
    float top = self.shareContentView.top;
    self.shareContentView.top = self.bottom;
    [UIView animateWithDuration:0.35 animations:^{
        self.maskView.alpha = 1;
        self.shareContentView.top = top;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.35 animations:^{
        self.maskView.alpha = 0;
        self.shareContentView.top = self.bottom;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)shareButtonClick:(UIButton *)button {
    NSInteger tag = button.tag;
    switch (tag) {
        case LLShareTypeWeixin: {
            if (self.shareExt.shareTitle) {
                [UMSocialData defaultData].extConfig.wechatSessionData.title = self.shareExt.shareTitle;
            }
            if (self.shareExt.shareURL) {
                [UMSocialData defaultData].extConfig.wechatSessionData.url = self.shareExt.wxShareURL;
            } else {
                [UMSocialData defaultData].extConfig.wechatSessionData.url = Olla_APP_WEBSITE_URL;
            }
            [self shareWithSNSName:UMShareToWechatSession];
        }
            break;
        case LLShareTypeWeixinMoments: {
            if (self.shareExt.shareTitle) {
                [UMSocialData defaultData].extConfig.wechatTimelineData.title = self.shareExt.shareTitle;
            }
            if (self.shareExt.shareURL) {
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.shareExt.shareURL;
            } else {
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = Olla_APP_WEBSITE_URL;
            }
            
            [self shareWithSNSName:UMShareToWechatTimeline];
        }
            break;
        case LLShareTypeSinaWeibo: {
            [self shareWithSNSName:UMShareToSina];
        }
            break;
        case LLShareTypeFacebook: {
            [self doFBShare];
        }
            break;
        case LLShareTypeTwitter: {
            [self shareWithSNSName:UMShareToTwitter];
        }
            break;
        case LLShareTypeOlla: {
            if ([self.delegate respondsToSelector:@selector(shareToOllaWithExt:)]) {
                [self.delegate shareToOllaWithExt:self.shareExt];
            }
        }
            break;
        case LLShareTypeVK: {
            if ([self.delegate respondsToSelector:@selector(shareToVKWithExt:)]) {
                [self.delegate shareToVKWithExt:self.shareExt];
            }
        }
            break;
        default:
            break;
    }
    [self hide];
}

- (void)shareWithSNSName:(NSString *)snsName
{
   
    
//    if ([self.type isEqualToString:@"live"])
//    {
//        UIViewController *viewController = [self getCurrentVC];
//        [[UMSocialControllerService defaultControllerService] setShareText:self.shareExt.shareText shareImage:self.shareExt.shareImage socialUIDelegate:nil];
//        [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName].snsClickHandler(viewController,[UMSocialControllerService defaultControllerService],YES);
//
//    }
//    else
//    {
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [[UMSocialControllerService defaultControllerService] setShareText:self.shareExt.shareText shareImage:self.shareExt.shareImage socialUIDelegate:nil];
        [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName].snsClickHandler(viewController,[UMSocialControllerService defaultControllerService],YES);
    
//    }
}

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (IBAction)cancel:(id)sender {
    [self hide];
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        DDLogInfo(@"share to %@ ok ",[[response.data allKeys] objectAtIndex:0]);
        //[JDStatusBarNotification showWithStatus:@"share success" dismissAfter:1.f styleName:JDStatusBarStyleDark];
        [self hide];
        
    }else{
        DDLogError(@"share error: message = %@,error = %@",response.message,response.error);
        
    }
    
    
}


- (void)doFBShare {
    
    NSString *shareText = self.shareExt.shareText;
    
    if (!shareText) {
        shareText = @"Free to talk with foreigners all over the world! ";
    }
    
    NSString *shareURL = self.shareExt.shareURL;
    
    if (!shareURL) {
        shareURL = Olla_APP_WEBSITE_URL;
    }
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:shareURL];
    params.description = shareText;
    params.caption = shareText;
    
    if (self.shareExt.shareImageURL) {
        params.picture = [NSURL URLWithString:self.shareExt.shareImageURL];
    } else {
        params.picture = [NSURL URLWithString:@"http://test.cn.olla.im/static/img/olla_for_fb.png"];
    }
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                DDLogError(@"Error publishing story: %@", error.description);
            } else {
                // Success
                NSLog(@"result %@", results);
                [JDStatusBarNotification showWithStatus:@"share success" dismissAfter:1.f styleName:JDStatusBarStyleDark];
                [self hide];
            }
        }];
        
        //        [FBDialogs presentShareDialogWithLink:params.link
        //                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        //
        //                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        //        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        //                                       @"olla", @"name",
        //                                       @"Free to talk with foreigners all over the world!", @"caption",
        //                                       @"Free to talk with foreigners all over the world!", @"description",
        //                            Olla_APP_STORE_URL, @"link",
        //
        //                                       nil];
        NSString *imageURL = nil;
        if (self.shareExt.shareImageURL) {
            imageURL = self.shareExt.shareImageURL;
        } else {
            imageURL = @"http://test.cn.olla.im/static/img/olla_for_fb.png";
        }
        
        NSDictionary *parameters = @{@"name":@"olla",
                                     @"caption":shareText,
                                     @"description":shareText,
                                     @"link":shareURL,
                                     @"picture":imageURL};
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
    
    
    
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

@end
