//
//  LLEMChatsViewController.h
//  Olla
//
//  Created by Pat on 15/3/19.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLEMChatsViewController : LLBaseViewController

- (void)refreshDataSource;
- (void)networkChanged:(EMConnectionState)connectionState;

@end
