//
//  OllaImagePickerScrollView.m
//  Olla
//
//  Created by null on 14-11-4.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaImagePickerScrollView.h"
#import "CTAssetsPickerController.h"
#import "JDStatusBarNotification.h"

@interface OllaImagePickerScrollView ()<CTAssetsPickerControllerDelegate>{}


@end

@implementation OllaImagePickerScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitial];
    }
    return self;
}

- (void)awakeFromNib{
    [self commonInitial];
}

- (void)commonInitial{
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    self.maxImageCount = 9;
    self.images = [NSMutableArray arrayWithCapacity:3];
}

- (void)dealloc{
    self.cameraPickerController = nil;
}

- (void)drawRect:(CGRect)rect{

    for (UIView *view in [self.scrollView subviews]) {
        [view removeFromSuperview];
    }
    self.scrollView.contentSize = CGSizeZero;
    
    if ([self.images count]>self.maxImageCount) {
        [self.images removeObjectsInRange:NSMakeRange(self.maxImageCount, [self.images count]-self.maxImageCount)];
    }
    
    for (int i=0; i<[self.images count]; i++) {
        
        id asset = self.images[i];
        if ([asset isKindOfClass:ALAsset.class]) {
           [self setButtonWithImage:[UIImage imageWithCGImage:[(ALAsset *)asset thumbnail]] atIndex:i];
        }
        
        if ([asset isKindOfClass:UIImage.class]) {
            [self setButtonWithImage:asset atIndex:i];
        }
    }
    
    // add +
    if ([self.images count]<self.maxImageCount) {
        [self setButtonWithImage:self.addImage atIndex:[self.images count]];
    }
    
    CGFloat offset = self.scrollView.contentSize.width-self.scrollView.width;
    if (offset<0) {
        offset=0;
    }
    [self.scrollView setContentOffset:CGPointMake(offset, self.scrollView.contentOffset.y) animated:YES];

}


- (void)setButtonWithImage:(UIImage *)image atIndex:(NSInteger)index{
    
    CGFloat margin = 5.f;
    CGFloat width = 60.f;
    
    // add +
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(margin+index*(margin+width), 0.f, width, width);
    [button setImage:image];
    if (self.cellImageCornerRadius) {
        button.layer.cornerRadius = self.cellImageCornerRadius;
    }
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.tag = index+1;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width+(margin+width), width);
    
}

- (void)buttonClicked:(id)sender{
    
    if (![sender isKindOfClass:[UIButton class]]) {
        return ;
    }

    int index = [(UIView *)sender tag];
    if (index==[self.images count]+1) {//打开相册选择器
        [self addImageFromCameraOrAlbum];
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(imagePickerScrollView:didSelectedAtIndex:)]) {
        [_delegate imagePickerScrollView:self didSelectedAtIndex:index-1];
    }
}

- (void)addImageFromCameraOrAlbum{
    
    [UIActionSheet showInView:[[self getValidViewControllerForActionSheet] view] withTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"拍照",@"从相册中选择照片"] tapBlock:^(UIActionSheet *actionSheet,NSInteger tapIndex){
        if (0==tapIndex) {//camera
            //默认 camera
            [[self cameraImagePickerController] setImagePickerType:OllaImagePickerCamera];
            [[self cameraImagePickerController] picker];
            
        }else if(1==tapIndex){// album
            
            if (IS_IOS7) {
               [[self getValidViewControllerForActionSheet] presentViewController:[self albumPickerController] animated:YES completion:^{}];
            }else{
                [[self cameraImagePickerController] setImagePickerType:OllaImagePickerPhotoLibrary];
                [[self cameraImagePickerController] picker];
            }    
        }// cancel 2
        
    }];
}

- (OllaImagePickerController *)cameraImagePickerController{
 
    if (!self.cameraPickerController) {
        OllaImagePickerController *imagePickerController = [[OllaImagePickerController alloc] initWithViewController:[self getValidViewControllerForActionSheet]];
        self.cameraPickerController = imagePickerController;
        
        __weak typeof(self) weakSelf = self;
        [imagePickerController setCompleteBlock:^(OllaImagePickerController *imagePickerController,UIImage *image){
            //__strong typeof(self) strongSelf = weakSelf;
            UIImage *cImage = [image resizeAspectImageWithSize:CGSizeMake(640, 1136)];
            [weakSelf addCropImageFromCamera:cImage];
        }];  
    }

    return self.cameraPickerController;
}


- (void)addCropImageFromCamera:(UIImage *)image{

    [self.images addObject:image];
    [self setNeedsDisplay];
}


/**
 'Sheet can not be presented because the view is not in a window
 */
- (UIViewController *)getValidViewControllerForActionSheet{
    return _viewController;
}

////// 多图选择 ///////////////////////////////////////
- (CTAssetsPickerController *)albumPickerController{
    
    CTAssetsPickerController *pickerController = [[CTAssetsPickerController alloc] init];
    pickerController.assetsFilter = [ALAssetsFilter allPhotos];
    pickerController.delegate = self;
    return pickerController;
    
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldShowAsset:(ALAsset *)asset{

    
    if ([self.images count]>self.maxImageCount) {
        DDLogInfo(@"图片数量超过最大限制(%lud)",self.maxImageCount);
        [UIAlertView showWithTitle:nil message:@"超过9张照片啦" cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    return YES;
}

-(void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self.images addObjectsFromArray:assets];
    
//    for (ALAsset *asset in assets) {
//        UIImage *image = [self imageForAsset:asset];
//        UIImage *cropImage = [image resizeAspectImageWithSize:CGSizeMake(640,1136)];
//        if (!self.images) {
//            self.images = [NSMutableArray arrayWithCapacity:3];
//        }
//        [self.images addObject:cropImage];
//    }
    
    [self setNeedsDisplay];
}

-(UIImage*) imageForAsset:(ALAsset*) aAsset{
    
    ALAssetRepresentation *rep;
    
    rep = [aAsset defaultRepresentation];
    
    return [UIImage imageWithCGImage:[rep fullResolutionImage]];
}

@end


