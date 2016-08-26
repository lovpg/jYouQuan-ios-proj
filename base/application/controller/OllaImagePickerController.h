//
//  OllaImagePickerController.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-16.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaController.h"

typedef NS_ENUM(NSUInteger , OllaImagePickerType){
    OllaImagePickerCamera,
    OllaImagPickerAlbum,
    OllaImagePickerPhotoLibrary
};

@class OllaImagePickerController;
typedef void(^imagePickerComplete)(OllaImagePickerController *controller,UIImage *image);

//图片相机封装
@interface OllaImagePickerController : OllaController

@property(nonatomic,assign) OllaImagePickerType imagePickerType;
@property(nonatomic,strong) imagePickerComplete completeBlock;
@property(nonatomic,assign) BOOL allowsEditing;

@property(nonatomic,weak) UIViewController *presentedViewController;

- (instancetype) initWithViewController:(UIViewController *)viewController;
- (void)picker;
- (void)pickerImage;// 快捷接口


@end
