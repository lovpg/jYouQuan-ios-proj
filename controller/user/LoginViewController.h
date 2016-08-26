//
//  LoginViewController.h
//  iDleChat
//
//  Created by Reco on 16/1/25.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLBaseViewController.h"

@interface LoginViewController : LLBaseViewController<UITextViewDelegate,OllaTableDataControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextFeild;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property(nonatomic,strong) LLLoginAuth *userAuth;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet OllaTableSource *tableSource;

@end
