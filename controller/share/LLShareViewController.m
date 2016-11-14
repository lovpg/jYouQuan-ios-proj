//
//  LLShareViewController.m
//  jishou
//
//  Created by Reco on 16/7/20.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLShareViewController.h"

#import "KZVideoViewController.h"
#import "KZVideoPlayer.h"

#import <AFNetworking.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VJ_VideoFolderManager.h"

#define max_words_allowed 1024



@interface LLShareViewController () <KZVideoViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    NSMutableArray *selections;
    IBOutlet UITextView *contentTextView;
    
}

@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, strong) NSString *videoLocalPath;
@property (nonatomic, strong) UIButton *videoButton;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;




@end

@implementation LLShareViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
       if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        UIImage *aimage = [UIImage imageNamed:@"navigation_back_arrow_new"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:image
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(backAction:)];
        UIImage *share_send_img = [UIImage imageNamed:@"post_submit"];
        UIImage *share_send = [share_send_img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:share_send
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(submitShare:)];
        [self.navigationItem setLeftBarButtonItem:leftItem animated:YES];
        [self.navigationItem setRightBarButtonItem:rightItem animated:YES];
    }
    

    return self;
}

- (IBAction)backAction:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    if (_thumbImage)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
//    self.tabBarController.tabBar.hidden = YES;
//    self.view.contentMode = UIEdgeInsetsMake(0, 0, -64, 0);
//    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, -64, 0)];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    self.imagePickerView.cellImageCornerRadius = 3.f;
    indicatorView.hidden = YES;
    self.postion = @"0,0";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(locationSelectedHandler:)
                                                  name:@"LLLocationChooseNotification"
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(categorySelectedHandler:)
                                                 name:@"LLCatatoryChooseNotification"
                                               object:nil];
    
   
    
    
    
        NSString *string = [self.params objectForKey:@"tags"];
        if ([string isEqualToString:@"camera"])
        {
            self.imagePickerView.addImage = [UIImage imageNamed:@"publish_addphoto_n"];
            _imagePickerView.TypeShowing = @"openCamera";
        }
        
        else if ([string isEqualToString:@"album"])
        {
            self.imagePickerView.addImage = [UIImage imageNamed:@"publish_addphoto_n"];
            _imagePickerView.TypeShowing = @"openPhotoAlbum";
        }
        
        else if ([string isEqualToString:@"video"])
        {
            /*
            // 仿微信录制视频的打开方式, 没完善, 以后会更改
            _thumbImage = [self.params objectForKey:@"videoPic"];
            
            UIImage *composeImage = [self composeImg:_thumbImage frontImage:[UIImage imageNamed:@"videoPlay"]];
            
            
            _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _videoButton.frame = CGRectMake(5, -1, 62, 60);
            [self.imagePickerView addSubview:_videoButton];
            _videoButton.image = composeImage;
            
            [_videoButton addTarget:self action:@selector(playVideoActions:) forControlEvents:UIControlEventTouchUpInside];
            self.videoUrl = [self.params objectForKey:@"videoUrl"];
             */
            
            
             // 环信录制视频模式
#if TARGET_IPHONE_SIMULATOR
            [self showHint:@"simulator does not support video"];
#elif TARGET_OS_IPHONE
            UIImagePickerController *imagePicker = [self imagePicker];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            [self presentViewController:imagePicker animated:YES completion:NULL];
#endif


        }
}





// 环信录制视频模式
#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                    NSLog(@"导出成功，导出的MP4文件大小为:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                    _image = [self thumbnailImageForVideo:exportSession.outputURL atTime:1];
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker) {
        _imagePicker.delegate = nil;
        _imagePicker = nil;
    }
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
    _imagePicker.delegate = self;
    
    return _imagePicker;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"录制取消");
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];

    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSLog(@"录制结束");
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:nil];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self convert2Mp4:videoURL];
        
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
       [self submitVideo:mp4];
        
        UIImage *composeImage = [self composeImg:_image frontImage:[UIImage imageNamed:@"videoPlay"]];
        
        
        _videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoButton.frame = CGRectMake(5, -1, 62, 60);
        [self.imagePickerView addSubview:_videoButton];
        _videoButton.image = composeImage;
        
        [_videoButton addTarget:self action:@selector(playVideoWithVideoPath:) forControlEvents:UIControlEventTouchUpInside];

        
        
    }
}

- (void)playVideoWithVideoPath:(UIButton *)button
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    NSURL *videoURL = [NSURL fileURLWithPath:self.videoLocalPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}




- (UIImage *) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    
    
    assetImageGenerator.appliesPreferredTrackTransform =YES;        assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    
    CFTimeInterval thumbnailImageTime = time;
    
    NSError *thumbnailImageGenerationError = nil;
    
    thumbnailImageRef = [assetImageGenerator
                         copyCGImageAtTime:CMTimeMake(thumbnailImageTime,60) actualTime:NULL error:&thumbnailImageGenerationError];
    //    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:<#(nullable CMTime *)#> error:<#(NSError *__autoreleasing  _Nullable * _Nullable)#>]
    
    if (!thumbnailImageRef)
        
        DDLogInfo(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] :nil;
    
    return thumbnailImage;
    
}


- (void)submitVideo:(NSURL *)videoUrl
{
    NSString *videoPath = videoUrl.relativePath;
    self.videoLocalPath = videoPath;
    
    
    [[LLHTTPRequestOperationManager shareManager] POSTWithURL:Olla_API_Video_Submit parameters:nil data:[NSData dataWithContentsOfFile:videoPath] success:^(NSDictionary *responseObject)
     {
         NSLog(@"upload ok: %@", responseObject[@"data"]);
         NSString *videoUrl = responseObject[@"data"];
         
         NSLog(@"网址为%@", videoUrl);
         self.videoUrl = videoUrl;
         //         NSDictionary *dictionary = @{@"tags" : @"video", @"videoPic" : _image, @"videoUrl" : videoUrl};
//         [self openURL:[self.url URLByAppendingPathComponent:@"share"] params:dictionary animated:YES];
         
         
     } failure:^(NSError *error)
     {
         DDLogError(@"whatup视频 upload error:%@",error);
         
     }];
    
    
    
}





- (void)viewDidAppear:(BOOL)animated
{

    
}

- (void)playVideoActions:(UIButton *)button
{
    
//    NSURL *videoUrl = [NSURL fileURLWithPath:_videoModel.videoAbsolutePath];
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[VJ_VideoFolderManager getVideoCompositionFilePathString]];
    NSLog(@"Will play video from url:%@", [VJ_VideoFolderManager getVideoCompositionFilePathString]);
    KZVideoPlayer *player = [[KZVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) videoUrl:mergeFileURL];
//    [self.view addSubview:player];
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    [keyWindow addSubview:player];

//    self.navigationController.navigationBar.hidden = YES;
    
    
}


- (void)locationSelectedHandler:(NSNotification *)notification
{
    
    NSString *address = [notification.userInfo valueForKey:@"address"];
    self.location.text = address;

    
    CLLocation *location = [notification.userInfo valueForKey:@"location"];
    self.postion = [NSString stringWithFormat:@"%@,%@",[NSNumber numberWithDouble:location.coordinate.latitude],[NSNumber numberWithDouble:location.coordinate.longitude]];
}
- (void)categorySelectedHandler:(NSNotification *)notification
{
    NSDictionary *param = notification.userInfo;
    if( [[param objectForKey:@"opt"] isEqualToString:@"tags"] )
    {
        NSString *categroy = [param objectForKey:@"categroy"];
        self.tagsLabel.text = categroy;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (IBAction)doAction:(id)sender
{
    [[[UIApplication sharedApplication] delegate] window].rootViewController = [self.context rootViewControllerWithURLKey:@"login"];
}


- (IBAction)submitShare:(id)sender
{
    if (![self checkInputContentLegal])
    {
        return;
    }
    [self submit];
}

- (void) submit
{
    [contentTextView resignFirstResponder];
    indicatorView.hidden = NO;
    [indicatorView startAnimating];
    
    __weak typeof(self) weakSelf = self;
    
    LLUser *user = [[[LLUserService alloc]init] getMe];
    
    NSString *tags = [NSString stringWithFormat:@"%@,%@",user.equipType, self.tagsLabel.text];
    
    NSDictionary *dictionary = [NSDictionary dictionary];
    
    if (!self.videoUrl)
    {
      
        dictionary = @{@"content"  :_content.text,
                       @"tags"     :tags,
                       @"city"     :@"中国",
                       @"location" :self.postion,
                       @"address"  :self.location.text,
                       @"vedioUrl" :@""
                       };
    }
    else
    {
        
        dictionary = @{@"content"  :_content.text,
                       @"tags"     :tags,
                       @"city"     :@"中国",
                       @"location" :self.postion,
                       @"address"  :self.location.text,
                       @"vedioUrl" :self.videoUrl
                       };
    }
    
    
    
    [[LLHTTPWriteOperationManager shareWriteManager]
     POST:Olla_API_Share_Add
     parameters:dictionary  constructingBodyWithBlock:^(id<AFMultipartFormData> formData){// 一组图片上传！！
         
         NSArray *images = [NSArray array];
         if (_image)
         {
             images = @[_videoButton.image];
             for (id asset in images)
             {
                 NSData *data = nil;
                 if ([asset isKindOfClass:[UIImage class]])
                 {
                     data = UIImageJPEGRepresentation(asset, 0.4);
                 }
                 if ([asset isKindOfClass:ALAsset.class])
                 {
                     UIImage *original = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                     data = UIImageJPEGRepresentation(original, 0.4);
                 }
                 [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
             }
         

         }
         else
         {
//         images = [NSMutableArray arrayWithArray:[weakSelf.imagePickerView images]];
          images = [weakSelf.imagePickerView images];
          for (id asset in images)
          {
             NSData *data = nil;
             if ([asset isKindOfClass:[UIImage class]])
             {
                 data = UIImageJPEGRepresentation(asset, 0.4);
             }
             if ([asset isKindOfClass:ALAsset.class])
             {
                 UIImage *original = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                 data = UIImageJPEGRepresentation(original, 0.4);
             }
             [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
           }
         }
         
     } success:^(AFHTTPRequestOperation *operation,id respondObject){
         
         NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:respondObject options:NSJSONReadingMutableLeaves error:nil];
         
         __strong typeof(self)strongSelf = weakSelf;
         if (![dict[@"status"] isEqualToString:@"200"]) {
             DDLogError(@"upload share error :%@",dict);
             NSString *errorMessage = [LLAppHelper errorMessageWithError:[NSError errorWithDomain:@"com.olla.api" code:0 userInfo:dict]];
             [UIAlertView showWithTitle:nil message:errorMessage cancelButtonTitle:@"知道了" otherButtonTitles:nil tapBlock:nil];
             [strongSelf errorHandler:nil];
             return;
         }
         [strongSelf successHandler:dict[@"data"]];
         
     } failure:^(AFHTTPRequestOperation *operation,NSError *error){
         __strong typeof(self)strongSelf = weakSelf;
         [JDStatusBarNotification showWithStatus:[LLAppHelper errorMessageWithError:error] dismissAfter:1.f styleName:JDStatusBarStyleDark];
         [strongSelf errorHandler:error];
     }];
        
    
}



- (void)errorHandler:(NSError *)error
{
    indicatorView.hidden = YES;
    [indicatorView stopAnimating];
}



- (void)successHandler:(id)result{
    
    DDLogInfo(@"send share ok :%@",result);
//    [self.navigationController popViewControllerAnimated:YES];
    if (_thumbImage)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
    }
}

- (BOOL)checkInputContentLegal
{
    
    if ([_content.text length]==0)
    {
        [UIAlertView showWithTitle:nil message:@"写点啥吧，你这样我交不了差！" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return NO;
    }
    
    return YES;
}

- (IBAction)updataLoaction:(UIButton *)sender
{
    
    [self openURL:[NSURL URLWithString:@"present:///location-choose"] animated:YES];
}
- (IBAction)categoryChooseAction:(id)sender
{
    [self openURL:[NSURL URLWithString:@"present:///dev-catagory"] params:@"tags" animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

////// 多图编辑 ///////////////////////////
- (void)imagePickerScrollView:(OllaImagePickerScrollView *)pickerView didSelectedAtIndex:(NSInteger)index{
    
    MWPhotoBrowser *imagePreview = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    [imagePreview setCurrentPhotoIndex:index];
    imagePreview.displaySelectionButtons = YES; // 不管用？？
    imagePreview.alwaysShowControls = NO; // 导航条是否自动消失
    imagePreview.displayActionButton = NO;// share or copy
    selections = [NSMutableArray new];
    for (int i = 0; i < [pickerView.images count]; i++)
    {
        [selections addObject:[NSNumber numberWithBool:YES]];
    }
    [self.navigationController pushViewController:imagePreview animated:YES];
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected{
    [selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)_photoBrowser{
    [_photoBrowser dismissViewControllerAnimated:NO completion:nil];
}


- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [self.imagePickerView.images count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    
    UIImage *image = nil;
    id asset = [self.imagePickerView.images objectAtIndex:index];
    if ([asset isKindOfClass:[UIImage class]]) {
        image = asset;
    }
    if ([asset isKindOfClass:[ALAsset class]]) {
        image = [UIImage imageWithAsset:asset];
    }
    
    return [MWPhoto photoWithImage:image];
}

// textview delegate 计算字数 /////////////////////////////////
// @""删除时
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {//换行
        [textView resignFirstResponder];
    }
    
    if([text length]==0)
    {// 删除
        return YES;
    }
    if ([textView.text length]+[text length]>max_words_allowed ) {//如果添加的内容以后操作最大，就不让
        return NO;
    }
    
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    

    placeholdLabel.hidden = [textView.text length];
    //fix bug:以表情打头时submitButton.enabled = [textView.text length]; 无效
    if ([textView.text length]>max_words_allowed) {
        return;
    }
    
    NSUInteger length = [textView.text length];
    // wordsWrittenlabel.text = [NSString stringWithFormat:@"%d/%d",length,max_words_allowed];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    placeholdLabel.text = @"";
    return YES;
}

// 合成图片的方法(两张图片)
- (UIImage *)composeImg:(UIImage *)backImage frontImage:(UIImage *)frontImage
{
    
    //以1.png的图大小为画布创建上下文
    UIGraphicsBeginImageContext(CGSizeMake(640, 640));
    [backImage drawInRect:CGRectMake(0, 0, 640, 640)];//先把1.png 画到上下文中
    [frontImage drawInRect:CGRectMake((640-140)/2.0, (640-140)/2.0, 140, 140)];//再把小图放在上下文中
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获得最终图片
    UIGraphicsEndImageContext();//关闭上下文
    
    return resultImg;

}


//- (void)videoViewControllerDidCancel:(KZVideoViewController *)videoController
//{
//    NSLog(@"没有录到视频");
//}







@end
