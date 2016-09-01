//
//  KZVideoConfig.h
//  KZWeChatSmallVideo_OC
//
//  Created by Corporal on 16/7/19.
//  Copyright © 2016年 Corporal. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kzSCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define kzSCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height


#define kzThemeBlackColor   [UIColor blackColor]
#define kzThemeTineColor    [UIColor greenColor]

#define kzThemeWaringColor  [UIColor redColor]
#define kzThemeWhiteColor   [UIColor whiteColor]
#define kzThemeGraryColor   [UIColor grayColor]

// 视频保存路径
#define kzVideoDicName      @"jYouQuanSmailVideo"

// 视频录制 时长
#define kzRecordTime        10.0

// 视频的长宽按比例
#define kzVideo_w_h (4.0/3)

// 视频默认 宽的分辨率  高 = kzVideoWidthPX / kzVideo_w_h
#define kzVideoWidthPX  200.0

//控制条高度 小屏幕时
#define kzControViewHeight  120.0
// 是否保存到手机相册
//#define saveToLibrary   (0)


extern void kz_dispatch_after(float time, dispatch_block_t block);

typedef NS_ENUM(NSUInteger, KZVideoViewShowType) {
    KZVideoViewShowTypeSmall,  // 小屏幕 ...聊天界面的
    KZVideoViewShowTypeSingle, // 全屏 ... 朋友圈界面的
};

@interface KZVideoConfig : NSObject
// 录像 的 View 大小
+ (CGRect)viewFrameWithType:(KZVideoViewShowType)type;

//视频View的尺寸
+ (CGSize)videoViewDefaultSize;

// 默认视频分辨率
+ (CGSize)defualtVideoSize;
// 渐变色
+ (NSArray *)gradualColors;

// 模糊View
+ (void)motionBlurView:(UIView *)superView;


+ (void)showHinInfo:(NSString *)text inView:(UIView *)superView frame:(CGRect)frame timeLong:(NSTimeInterval)time;

@end


