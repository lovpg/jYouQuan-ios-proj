//
//  UserInfoFillContorllerViewController.h
//  iDleChat
//
//  Created by Reco on 16/3/2.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import "LLBaseViewController.h"

@interface UserInfoFillContorllerViewController : LLBaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UISwitch *gender;
@property (weak, nonatomic) IBOutlet UIButton *fillButton;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (strong, nonatomic) IBOutlet OllaTableSource *tableSource;

@end
