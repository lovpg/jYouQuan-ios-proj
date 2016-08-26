//
//  SignupViewController.h
//  iDleChat
//
//  Created by Reco on 16/1/26.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLBaseViewController.h"

@interface SignupViewController :  LLBaseViewController<UITextViewDelegate,OllaTableDataControllerDelegate>


@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *l_timeButton;
@property (weak, nonatomic) IBOutlet UITextField *codeLabel;

@property (strong, nonatomic) IBOutlet OllaTableSource *tableSource;
@property (weak, nonatomic) IBOutlet UIButton *toLoginButton;


@end
