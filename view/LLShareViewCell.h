//
//  LLShareViewCell.h
//  jishou
//
//  Created by Reco on 16/7/19.
//  Copyright © 2016年 广州市易工信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLShareViewCell : UITableViewCell
{
    IBOutlet UILabel *nickname;
}

@property (nonatomic, strong) NSString *dataItem;

@end
