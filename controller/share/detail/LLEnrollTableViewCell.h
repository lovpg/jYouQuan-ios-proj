//
//  LLEnrollTableViewCell.h
//  iDleChat
//
//  Created by Reco on 16/3/4.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *LLEnrollDetailButtonClick = @"LLEnrollDetailButtonClick";

@interface LLEnrollTableViewCell : UITableViewCell
{
    UIButton *enrollButton;
    UIButton *enrollDetailButton;
}
@property (weak, nonatomic) IBOutlet UIButton *enrollButton;

@end
