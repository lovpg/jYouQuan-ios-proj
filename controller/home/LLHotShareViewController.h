//
//  LLHotShareViewController.h
//  jishou
//
//  Created by Reco on 16/7/22.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import "LLBaseViewController.h"
#import "LLShareDataSource.h"

@interface LLHotShareViewController : LLBaseViewController<UITableViewDataSource, UITableViewDelegate,LLShareDataSourceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
