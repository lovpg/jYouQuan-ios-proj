//
//  LLAppHelper.m
//  Olla
//
//  Created by nonstriater on 14-7-20.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLAppHelper.h"
#include <dlfcn.h>
#include <stdio.h>

@implementation LLAppHelper

+ (void)saveUserName:(NSString *)userName password:(NSString *)password {
    
    if (userName.length == 0 || password.length == 0) {
        DDLogError(@"保存用户名密码失败!两者其中之一为空!");
        return;
    }
    [OllaKeychain setPassword:userName forService:@"Olla" account:@"ollaUserName" error:NULL];
    [OllaKeychain setPassword:password forService:@"Olla" account:@"ollaPassword" error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"ollaUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"ollaPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)userName {
    NSString *userName = [OllaKeychain passwordForService:@"Olla" account:@"ollaUserName" error:nil];
    if (!userName) {
        userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ollaUserName"];
    }
    return userName;
}

+ (NSString *)password {
    NSString *password = [OllaKeychain passwordForService:@"Olla" account:@"ollaPassword" error:nil];
    if (!password) {
        password = [[NSUserDefaults standardUserDefaults] stringForKey:@"ollaPassword"];
    }
    return password;
}

+ (NSString *)tabBadgeKeyAtIndex:(NSInteger)index{
    NSArray *keys = @[[NSString stringWithFormat:@"com.lbslm.badge.posts"],
                      [NSString stringWithFormat:@"com.lbslm.badge.tmiles"],
                      [NSString stringWithFormat:@"com.lbslm.badge.messages"],
                      [NSString stringWithFormat:@"com.lbslm.badge.me"]
                      ];
    return [keys objectAtIndex:index];
}

+ (NSString *)storeKeyAtIndex:(NSInteger)index uid:(NSString *)uid{
    
    NSArray *keys = @[[NSString stringWithFormat:@"com.olla.badge.xx_%@",uid],
                      [NSString stringWithFormat:@"com.olla.badge.chats_%@",uid],
                      [NSString stringWithFormat:@"com.olla.badge.friends_%@",uid],
                      [NSString stringWithFormat:@"com.olla.badge.me_%@",uid]
                      ];
    return [keys objectAtIndex:index];
    
}



+ (NSString *)genderIconFromString:(NSString *)gender{
    
//    if (![gender isString] ) {
//        return nil;
//    }
    if ([gender length]==0) {
        gender = @"secret";
    }
    NSString *icon = @"sex_secret";// 默认女性
    if ([gender isEqualToString:@"女"]) {
        icon = @"sex_female";
    } else if([gender isEqualToString:@"男"]){
        icon = @"sex_male";
    } else if([gender isEqualToString:@"gay"]){
        icon = @"sex_gay";
    }
    return icon;
}


+ (NSString *)countryIconFromString:(NSString *)country{

    return [NSLocale countryCodeWithName:country];
}


+ (NSArray *)countries{
    
    return [NSLocale allCountries];
    
    //下面咱不用
    return @[@"English",
             @"French",
             @"Spanish",
             @"German",
             @"Italian",
             @"Chinese",
             @"Japanese",
             @"Korean",
             @"Russian",
             @"Dutch",
             @"Portuguese",
             @"Arabic",
             @"Hindi",
             @"Bulgarian",
             @"Croatian",
             @"Czech",
             @"Danish",
             @"Finnish",
             @"Greek",
             @"Norwegian",
             @"Polish",
             @"Romanian",
             @"Swedish",
             @"Catalan",
             @"Filipino",
             @"Hebrew",
             @"Indonesian",
             @"Latvian",
             @"Lithuanian",
             @"Serbian",
             @"Slovak",
             @"Slovene",
             @"Ukrainian",
             @"Vietnamese",
             @"Albanian",
             @"Estonian",
             @"Galician",
             @"Hungarian",
             @"Maltese",
             @"Thai",
             @"Turkish",
             @"Persian",
             @"Afrikaans",
             @"Belarusian",
             @"Icelandic",
             @"Irish",
             @"Macedonian",
             @"Malay",
             @"Swahili",
             @"Welsh",
             @"Yiddish",
             @"Haitian Creole",
             @"Armenian",
             @"Azerbaijani",
             @"Basque",
             @"Georgian",
             @"Urdu",
             @"Latin",
             @"Bengali",
             @"Gujarati",
             @"Kannada",
             @"Tamil",
             @"Telugu",
             @"Esperanto",
             @"Lao",
             @"Khmer",
             @"Bosnian",
             @"Cebuano",
             @"Hmong",
             @"Javanese",
             @"Marathi"];
   
}

+ (NSInteger)flagCountWithFriendList:(NSArray *)friends {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (LLSimpleUser *friend in friends) {
        NSString *region = friend.region;
        if (region.length == 0) {
            continue;
        }
        if ([dict objectForKey:region]) {
            int count = [[dict objectForKey:region] intValue];
            [dict setObject:@(count+1) forKey:region];
        } else {
            [dict setObject:@(1) forKey:region];
        }
    }
    
    return dict.allKeys.count;
}

+ (NSString *)imThumbImageURLWithString:(NSString *)key{
    
    NSString *extention = [key pathExtension];
    NSString *thumb = @"_120x160_crop";//120x160
    
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
}

+ (NSString *)imImageURLWithThumbString:(NSString *)key{
    return [key stringByReplacingOccurrencesOfString:@"_120x160" withString:@""];
}


+ (NSString *)oneShareThumbImageURLWithString:(NSString *)key {
    NSString *extention = [key pathExtension];
//    NSString *thumb = @"_280x280_crop";
    NSString *thumb = @"_320x320_crop";
    
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
}

+ (NSString *)shareThumbImageURLWithString:(NSString *)key
{
    NSString *extention = [key pathExtension];
    NSString *thumb = @"_240x240_crop";// 80x80较模糊//_160x160_crop
    
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
}

+ (NSString *)shareThumbMidImageURLWithString:(NSString *)key
{
    NSString *extention = [key pathExtension];
    NSString *thumb = @"_320x320_crop";// 80x80较模糊    
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
}

+ (NSString *)shareImageURLWithThumbString:(NSString *)key
{
    if ([key containString:@"_320x320_crop"]) {
        return [key stringByReplacingOccurrencesOfString:@"_320x320_crop" withString:@""];
    }
    return [key stringByReplacingOccurrencesOfString:@"_160x160_crop" withString:@""];
}


+ (NSString *)headPhotoThumbImageURLWithString:(NSString *)key{

    NSString *extention = [key pathExtension];
    NSString *thumb = @"_120x120_crop";
    
    return [key stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
    
}


+ (NSString *)headPhotoImageURLWithThumbString:(NSString *)key{
    return [key stringByReplacingOccurrencesOfString:@"_120x120_crop" withString:@""];
}


+ (NSString *)thumbImageWithURL:(NSString *)url size:(CGSize)size{
    
    NSString *extention = [url pathExtension];
    NSString *thumb =  [NSString stringWithFormat:@"_%@x%@_crop",@(size.width),@(size.height)];
    
    return [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@",extention] withString:[NSString stringWithFormat:@"%@.%@",thumb,extention]];
    
    
}

+ (NSString *)ImageURLWithThumbString:(NSString *)url size:(CGSize)size{

    NSString *thumb =  [NSString stringWithFormat:@"_%@x%@_crop",@(size.width),@(size.height)];
    return [url stringByReplacingOccurrencesOfString:thumb withString:@""];
}


+ (NSString *)errorMessageWithError:(NSError *)error{
    
    NSString *errorMessage = error.userInfo[@"message"];
    if (![errorMessage isString]) {
        return @"There is something unnormal...";
    }
    
    if ([errorMessage length]) {
        return errorMessage;
    }
    
    if (error.code==NSURLErrorDNSLookupFailed || error.code==NSURLErrorCannotFindHost) {
        errorMessage = @"DNS error...";
    }
    
    if (error.code == NSURLErrorTimedOut) {
        errorMessage = @"Request Timeout";
    }
    
    if (error.code == NSURLErrorBadServerResponse) {
        errorMessage = @"Service Unavailable";
    }
    
    
    if ([errorMessage length]==0) {
        errorMessage = @"There is something unnormal...";
    }
    
    return errorMessage;
}

+ ( NSString* )getNamefromCategory : (NSString*) category
{
    return category;
}

+ (BOOL)versionGreaterThanOrEqual:(NSString *)v{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    return ([version compare:v options:NSNumericSearch] != NSOrderedAscending);
}

+ (BOOL)isTestEnv {
    return [[NSUserDefaults standardUserDefaults] boolForKey:httpTestKey];
}


+ (BOOL)showDevUsage {
    return [[NSUserDefaults standardUserDefaults] boolForKey:devUsageKey];
}

// 各种环境切换  //////////////////////////////////////
+ (NSString *)baseAPIURL {

//    return @"http://app.uk.olla.im";
    
    NSString *scheme = [self httpScheme];
    BOOL test = [[[NSUserDefaults standardUserDefaults] valueForKey:httpTestKey] boolValue];
    
    if (test) {//test环境的https
        return [scheme stringByAppendingString:@"app.lbslm.com"];//@"https://test.olla.im";
    }
    
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.between.evn.host"];
    if (!host) {
        host = @"app.lbslm.com";//192.168.0.102
    }
    
    return [scheme stringByAppendingString:host];
}

+ (NSString *)wxBaseAPIURL {
    
    NSString *scheme = [self httpScheme];
    BOOL test = [[[NSUserDefaults standardUserDefaults] valueForKey:httpTestKey] boolValue];
    
    if (test) {//test环境的https
        return [scheme stringByAppendingString:@"test.cn.olla.im"];
    }
    
    return [scheme stringByAppendingString:@"cn.olla.im"];
}

// 写操作 URL
+ (NSString *)writeOperationURL {

    NSString *scheme = [self httpScheme];
    BOOL test = [[[NSUserDefaults standardUserDefaults] valueForKey:httpTestKey] boolValue];
    
    if (test) {
        return [scheme stringByAppendingString:@"app.lbslm.com"];
    }
    
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.between.evn.write.host"];
    if (!host) {
        host = @"app.lbslm.com";
    }
    
    return [scheme stringByAppendingString:host];
}

+ (NSString *)baseIMURL{
    
    NSString *server = [[NSUserDefaults standardUserDefaults] valueForKey:@"com.between.evn.imserver"];
    
    if (server.length) {
        return server;
    }
    
    BOOL test = [[[NSUserDefaults standardUserDefaults] valueForKey:httpTestKey] boolValue];
    if (test) {
        return @"test.im.olla.im";
    }
    
    return @"im.olla.im";
    
}


+ (NSString *)httpScheme{
    return @"http://";
    
//    BOOL test = [[[NSUserDefaults standardUserDefaults] valueForKey:httpTestKey] boolValue];
//    
//    if (test) {
//        return @"http://";
//    }
//
//    NSString *scheme =  [[NSUserDefaults standardUserDefaults] valueForKey:httpSchemeKey];
//    if ([scheme length]==0) {
//        scheme = @"https://";//默认
//    }
//    return scheme;
}


// https 测试环境
+ (void)resetHTTPSTestEnv{
    
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:httpTestKey];
    
//    [[LLHTTPRequestOperationManager shareManager] setBaseURL:[NSURL URLWithString:[[self class] baseAPIURL]]];
//    
//    LLIMContext *messageManger =  [(LLAppDelegate *)[UIApplication sharedApplication].delegate messageManager];
//    [[messageManger.imSender getClient] setHost:[[self class] baseIMURL]];
//    
}

// https 线上环境
+ (void)resetHTTPSProdEnv{
    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:httpTestKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[LLHTTPRequestOperationManager shareManager] setBaseURL:[NSURL URLWithString:[[self class] baseAPIURL]]];
//    
//    LLIMContext *messageManger =  [(LLAppDelegate *)[UIApplication sharedApplication].delegate messageManager];
//    [[messageManger.imSender getClient] setHost:[[self class] baseIMURL]];
//    [(LLAppDelegate *)[UIApplication sharedApplication].delegate logout];
    
}


// 测试环境 http(s)://ip/
+ (void)resetHTTPEnv{
    
    [[NSUserDefaults standardUserDefaults] setValue:@"http://" forKey:httpSchemeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[LLHTTPRequestOperationManager shareManager] setBaseURL:[NSURL URLWithString:[[self class] baseAPIURL]]];
}

+(OllaBarButtonItem *)barButtonItemWithUserInfo:(NSString *) userInfo imageName:(NSString *)imageName target:(id)target action:(SEL)selector{
    
    UIImage* itemImage= [UIImage imageNamed:imageName];
    if(IS_IOS7){
        itemImage = [itemImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    OllaBarButtonItem *item = [[OllaBarButtonItem alloc]initWithImage:itemImage style:UIBarButtonItemStylePlain target:target action:selector];
    item.actionName = @"url";
    item.userInfo = userInfo;
    return item;
    
}

+ (void)clearCookies {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[[LLHTTPRequestOperationManager shareManager] requestSerializer] setValue:@"" forHTTPHeaderField:@"Cookie"];
    [[[LLHTTPWriteOperationManager shareWriteManager] requestSerializer] setValue:@"" forHTTPHeaderField:@"Cookie"];
}

+ (UIImage *)screenShot {
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        // 程序进入后台不能截屏
        return nil;
    }
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)ollaShareScreenshot {
    UIImage *screenshot = [self screenShot];
    UIImage *titleImage = [UIImage imageNamed:@"olla_screenshot_logo"];
    float scale = screenshot.scale;
    
    CGSize size = CGSizeMake(screenshot.size.width + 200, screenshot.size.height + titleImage.size.height + 260);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [RGB_DECIMAL(33, 84, 165) set];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextStrokePath(context);
    
    CGRect imageRect = CGRectMake(100, 150, screenshot.size.width, screenshot.size.height);
    
    
    CGRect phoneRect = CGRectMake(CGRectGetMinX(imageRect) - 25, CGRectGetMinY(imageRect) - 93, CGRectGetWidth(imageRect) + 50, CGRectGetHeight(imageRect) + 185);
    UIImage *phoneImage = [[UIImage imageNamed:@"olla_screenshot_phone"] resizableImageWithCapInsets:UIEdgeInsetsMake(93, 25, 93, 25) resizingMode:UIImageResizingModeStretch];
    UIImageView *phoneView = [[UIImageView alloc] initWithFrame:phoneRect];
    phoneView.image = phoneImage;

    UIImage *borderImage = [phoneView screenshot];
    [borderImage drawInRect:phoneRect];
    [screenshot drawInRect:imageRect];
    
    float factor = titleImage.size.width * 0.75 / size.width;
    CGSize titleSize = CGSizeMake(size.width * 0.75, titleImage.size.height * factor);
    
    CGRect titleRect = CGRectMake((size.width - titleSize.width) / 2, size.height - titleSize.height - 40, titleSize.width, titleSize.height);
    [titleImage drawInRect:titleRect];
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


@end
