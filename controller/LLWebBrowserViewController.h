//
//  LLWebBrowserViewController.h
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"

@interface LLWebBrowserViewController : LLBaseViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;

@end
