//
//  LLMyCenterViewControllerRefactor.h
//  Olla
//
//  Created by Charles on 15/8/14.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLBaseViewController.h"

//#import "LLGroupBarAuth.h"

@interface LLMyCenterViewControllerRefactor : LLBaseViewController

//@property (nonatomic, strong) LLGroupBarAuth *groupBarAuth;


@property (nonatomic, strong) NSArray *unreadShareMessages;



@property(nonatomic,strong) IBOutlet OllaTableViewCell *commentNotifyCell;// 如果为weak，为nil
@property(nonatomic,assign) BOOL hasMessageNotification;

@end
