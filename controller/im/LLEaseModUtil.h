//
//  LLEaseModUtil.h
//  Olla
//
//  Created by Pat on 15/4/22.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


static NSString *LLEMMessageSendNotification = @"LLEMMessageSendNotification";

static NSString* LLEaseShareCommentAccount       = @"10001"; // share评论
static NSString* LLEaseFollowAccount             = @"10002"; // Follow
static NSString* LLEaseFansAccount               = @"10003"; // Fans
static NSString* LLEaseGroupBarInviteAccount     = @"10004"; // 群吧邀请
static NSString* LLEaseGroupBarMessageAccount    = @"10005"; // 群吧消息
static NSString* LLEaseShareLikeAccount          = @"10006"; // share点赞
static NSString* LLEaseGroupBarLikeAccount       = @"10007"; // 群吧帖子点赞
static NSString* LLEaseGroupBarCommentAccount    = @"10008"; // 群吧帖子评论

@interface LLEaseModUtil : NSObject

AS_SINGLETON(LLEaseModUtil, sharedUtil);

@property (nonatomic, strong) NSArray *ollaAccounts;

- (void)saveUserName:(NSString *)userName password:(NSString *)password;
- (NSString *)easeUserName;
- (NSString *)easeUserPassword;

- (BOOL)isLoggedIn;
- (void)loginWithCompletion:(void (^)(BOOL succeed))completion;

- (void)saveChatDraft:(NSString *)text withUid:(NSString *)uid;
- (NSString *)chatDraftWithUid:(NSString *)uid;

// 设置是否开启振动
- (void)setVibrate:(BOOL)on;

- (NSArray *)groupBarMessages;
- (NSArray *)unreadGroupBarMessages;
- (NSArray *)shareMessages;
- (NSArray *)unreadShareMessages;
- (void)removeFansMessages;
- (void)removeShareMessages;
- (void)removeGroupBarMessages;
- (void)removeNewPostGroupBarMessagesWithBid:(NSString *)bid;

@end
