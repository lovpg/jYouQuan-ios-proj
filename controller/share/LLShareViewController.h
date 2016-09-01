//
//  LLShareViewController.h
//  jishou
//
//  Created by Reco on 16/7/20.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"
#import "OllaImagePickerScrollView.h"

#import "KZVideoConfig.h"

@class KZVideoViewController;

@interface LLShareViewController : LLBaseViewController<UITextViewDelegate>
{
    IBOutlet __weak UIActivityIndicatorView *indicatorView;
    IBOutlet UILabel *placeholdLabel;
}

@property (weak, nonatomic) IBOutlet UILabel *location;
@property (strong, nonatomic) NSString *postion;
@property (strong, nonatomic) IBOutlet OllaTableSource *tableSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet OllaImagePickerScrollView *imagePickerView;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;


@property (nonatomic, strong) NSURL *thumbImageUrl;
@property (nonatomic, strong) UIImage *thumbImage;
+ (AFHTTPSessionManager *)sharedAFManager;

@end
