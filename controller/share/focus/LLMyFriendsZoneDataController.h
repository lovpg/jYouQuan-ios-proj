//
//  LLMyFriendsZoneDataController.h
//  Olla
//
//  Created by nonstriater on 14-8-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareDataController.h"

// 新消息提醒
@interface LLMyFriendsZoneDataController : LLShareDataController


@property(nonatomic,strong) IBOutlet OllaTableViewCell *commentNotifyCell;// 如果为weak，为nil
@property(nonatomic,assign) BOOL hasMessageNotification;

//@{}

- (void)showMessageNotificationWithAvatar:(NSString *)avatar messageCount:(NSInteger)messageCount;
- (void)hideMessageNotification;




@end
