//
//  OllaImagePickerScrollView.h
//  Olla
//
//  Created by null on 14-11-4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OllaImagePickerScrollViewDelegate;


// 支持相册相机取图，且支持相册多选(基于CTAssetsPickerController实现)
@interface OllaImagePickerScrollView : UIView
{
}

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) NSMutableArray *images;
@property(nonatomic,strong) UIImage *addImage;
@property(nonatomic,assign) CGFloat cellImageCornerRadius;
@property(nonatomic,assign) NSUInteger maxImageCount;//default 9;

@property (nonatomic, strong) NSString *TypeShowing; // 用来设置出现视图要出现的效果

@property(nonatomic,weak) IBOutlet id<OllaImagePickerScrollViewDelegate> delegate;
@property(nonatomic,weak) IBOutlet UIViewController *viewController;// for pickercontroller里的actionsheet, 注意循环引用
@property(nonatomic,strong) OllaImagePickerController *cameraPickerController;//拍照



@end


@protocol OllaImagePickerScrollViewDelegate <NSObject>
@optional
- (void)imagePickerScrollView:(OllaImagePickerScrollView *)scrollView didSelectedAtIndex:(NSInteger)index;

@end

