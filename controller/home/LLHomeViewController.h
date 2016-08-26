//
//  LLHomeViewController.h
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"



@interface LLHomeViewController :
LLBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *avatorButton;
@property (weak, nonatomic) IBOutlet UIButton *qrScanButton;
@property (weak, nonatomic) IBOutlet UIButton *downLoadQrButton;
@property (weak, nonatomic) IBOutlet UIButton *reGengerateButton;
@property (weak, nonatomic) IBOutlet UIButton *closeQrButton;
@property (weak, nonatomic) IBOutlet UIView *qrView;

@property (weak, nonatomic) IBOutlet UIButton *followButton;

@end
