//
//  LLAppHelper.h
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *httpSchemeKey = @"com.between.evn.httpScheme";
static NSString *httpTestKey = @"com.between.evn.test";
static NSString *devUsageKey = @"com.between.devUsage";

@interface LLAppHelper : NSObject

+ (void)saveUserName:(NSString *)userName password:(NSString *)password;
+ (NSString *)userName;
+ (NSString *)password;

+ (UIImage *)screenShot;
+ (UIImage *)ollaShareScreenshot;

+ (NSString *)genderIconFromString:(NSString *)gender;
+ (NSString *)countryIconFromString:(NSString *)country;

/*
 IM 60*80    有大小图
 share 80*80 有大小图
 userCenter 上得share  40*40
 头像 100*100   有大小图
 usercenter 头像 160x160
 **/
+ (NSString *)imThumbImageURLWithString:(NSString *)key;
+ (NSString *)oneShareThumbImageURLWithString:(NSString *)key;
+ (NSString *)shareThumbImageURLWithString:(NSString *)key;
+ (NSString *)headPhotoThumbImageURLWithString:(NSString *)key;
+ (NSString *)shareThumbMidImageURLWithString:(NSString *)key;
/**
 缩略图会源地址
 */
+ (NSString *)imImageURLWithThumbString:(NSString *)key;
+ (NSString *)shareImageURLWithThumbString:(NSString *)key;
+ (NSString *)headPhotoImageURLWithThumbString:(NSString *)key;


+ (NSString *)thumbImageWithURL:(NSString *)url size:(CGSize)size;
+ (NSString *)ImageURLWithThumbString:(NSString *)url size:(CGSize)size;


// 自定义的一个国家列表
+ (NSArray *)countries;
+ (NSInteger)flagCountWithFriendList:(NSArray *)friends;

+ (NSString *)tabBadgeKeyAtIndex:(NSInteger)index;
+ (NSString *)storeKeyAtIndex:(NSInteger)index uid:(NSString *)uid;

+ (NSString *)errorMessageWithError:(NSError *)error;

+ ( NSString* )getNamefromCategory : (NSString*) category;

+ (BOOL)versionGreaterThanOrEqual:(NSString *)v;

+ (BOOL)isTestEnv;
+ (BOOL)showDevUsage;

+ (NSString *)baseAPIURL;
+ (NSString *)baseIMURL;
+ (NSString *)writeOperationURL;

// 微信分享 Host
+ (NSString *)wxBaseAPIURL;

+ (void)resetHTTPSTestEnv;
+ (void)resetHTTPSProdEnv;
+ (void)resetHTTPEnv;
+(OllaBarButtonItem *)barButtonItemWithUserInfo:(NSString *) userInfo imageName:(NSString *)imageName target:(id)target action:(SEL)selector;
+ (void)clearCookies;
@end
