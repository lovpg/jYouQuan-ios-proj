//
//  LLCrownGoodCell.h
//  Olla
//
//  Created by Pat on 15/4/28.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *CrownGoodButtonClickEvent = @"CrownGoodButtonClickEvent";
static NSString *CrownAvatorButtonClickEvent = @"CrownAvatorButtonClickEvent";

@interface LLCrownGoodCell : UITableViewCell

@property (nonatomic, strong) NSArray *goodList;

@end
