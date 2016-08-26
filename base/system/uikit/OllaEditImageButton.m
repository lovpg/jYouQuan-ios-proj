//
//  OllaEditImageView.m
//  OllaFramework
//
//  Created by nonstriater on 14/8/29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaEditImageButton.h"


@interface OllaEditImageButton (){

    OllaImagePickerController *imagePickerController;

}

@end

@implementation OllaEditImageButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)editImageWithPOSTURL:(NSString *)url OnSuccess:(void (^)(UIImage *image,NSString *url))successBlock onError:(void (^)(NSError *error))failBlock{

//    if (!imagePickerController) {
//        imagePickerController = [[OllaImagePickerController alloc] initWithViewController:self];
//        imagePickerController.allowsEditing = YES;
//    }
//    
//    __weak typeof(self) weakSelf =self;
//    imagePickerController.completeBlock= ^(OllaImagePickerController *controllr,UIImage *image){
//        //上传服务器
//           
//    };
    
    [imagePickerController pickerImage];
    
    
    
    

}




@end
