//
//  LLShareViewController.m
//  jishou
//
//  Created by Reco on 16/7/20.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLShareViewController.h"

#define max_words_allowed 1024

@interface LLShareViewController ()
{
    NSMutableArray *selections;
    IBOutlet UITextView *contentTextView;
}
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
        UIImage *share_send_img = [UIImage imageNamed:@"share_send"];
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
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewDidLoad];
    self.imagePickerView.addImage = [UIImage imageNamed:@"publish_addphoto_n"];
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
    
}
- (void)viewDidAppear:(BOOL)animated
{

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
    
    NSString *categroy = [notification.userInfo valueForKey:@"categroy"];
    self.tagsLabel.text = categroy;
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
    [[LLHTTPWriteOperationManager shareWriteManager]
     POST:Olla_API_Share_Add
     parameters:@{@"content":_content.text,
                  @"tags":self.tagsLabel.text,
                  @"city":@"广东 广州",
                  @"location":self.postion,
                  @"address":self.location.text,
                  }
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData){// 一组图片上传！！
         
         NSMutableArray *images = [NSMutableArray arrayWithArray:[weakSelf.imagePickerView images]];
         for (id asset in images) {
             NSData *data = nil;
             if ([asset isKindOfClass:[UIImage class]]) {
                 data = UIImageJPEGRepresentation(asset, 0.4);
             }
             if ([asset isKindOfClass:ALAsset.class]) {
                 UIImage *original = [UIImage imageWithCGImage: [[asset defaultRepresentation] fullScreenImage]];
                 data = UIImageJPEGRepresentation(original, 0.4);
             }
             [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"multipart/form-data"];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self openURL:[NSURL URLWithString:@"." relativeToURL:self.url] animated:YES];
}

- (BOOL)checkInputContentLegal{
    
    if ([_content.text length]==0) {
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
    [self openURL:[NSURL URLWithString:@"present:///dev-catagory"] animated:YES];
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
    
    if ([text isEqualToString:@"\n"]) {//换行
        [textView resignFirstResponder];
    }
    
    if([text length]==0){// 删除
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


@end
