//
//  VJ_VideoRecorderToolView.h
//  test
//
//  Created by Vincent_Jac on 16/8/10.
//  Copyright © 2016年 Vincent_Jac. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 拍摄按钮
 */
typedef NS_ENUM(NSUInteger, VJ_VideoRecordBtnType) {
    StartRecording,
    OverRecord
};
@interface VJ_RecordBtn : UIButton
@property (nonatomic, assign) VJ_VideoRecordBtnType recordState;

- (void)touchBtn;

@end


/**
 * 摄像头按钮
 */
typedef NS_ENUM (NSUInteger, VJ_CameraType) {
    BackCamera,
    FontCamera
};

@interface VJ_CameraBtn :UIButton
@property(nonatomic, assign) VJ_CameraType cameraType;
@property(nonatomic, strong)NSString * type;

- (void)touchCameraBtn;

@end

/**
 * 摄像头闪光灯按钮
 */
typedef NS_ENUM (NSUInteger, VJ_FlashState) {
    FlashOn,
    FlashOFF
};

@interface VJ_CameraFlashBtn : UIButton

@property (assign)VJ_FlashState flashState;

- (void)touchCameraFlashBtn;

- (void)setCameraFlashOFF;

@end

/**
 * 拍摄时间Label
 */
@interface VJ_RecordMinuteNumberLabel : UILabel

- (void)beginRecord;

- (void)endRecord;

@end

/**
 * 聚焦时候显示的绿色小方框
 */
@interface VJ_FocusView : UIView

- (void)focusingEvent;

@end