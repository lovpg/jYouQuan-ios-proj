//
//  LLMeViewController.h
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"
#import "LLAvatarImageButon.h"

@interface LLMeViewController : LLBaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet LLAvatarImageButon *avatorButoon;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *equipType;

@end
