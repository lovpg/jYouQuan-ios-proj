//
//  LLEaseModUtil.m
//  Olla
//
//  Created by Pat on 15/4/22.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEaseModUtil.h"
#import "GCDObjC.h"
//#import "LLShareMessage.h"
////#import "LLGroupBarMessage.h"
//#import "LLGroupBarConstant.h"
#import "LLEMIMDraft.h"
#import "NSDate+Category.h"
#import "LLEaseNotificationObject.h"

@interface LLEaseModUtil () {
    GCDQueue *_loginQueue;
}

@end

@implementation LLEaseModUtil


DEF_SINGLETON(LLEaseModUtil, sharedUtil);

- (instancetype)init
{
    self = [super init];
    if (self) {
        _loginQueue = [[GCDQueue alloc] initSerial];
        _ollaAccounts = @[LLEaseShareCommentAccount,
                          LLEaseFollowAccount,
                          LLEaseFansAccount,
                          LLEaseGroupBarInviteAccount,
                          LLEaseGroupBarMessageAccount,
                          LLEaseShareLikeAccount,
                          LLEaseGroupBarLikeAccount,
                          LLEaseGroupBarCommentAccount];
    }
    return self;
}

- (void)saveUserName:(NSString *)userName password:(NSString *)password
{
    if (userName.length == 0 || password.length == 0)
    {
        DDLogError(@"保存环信用户名密码失败!两者其中之一为空!");
        return;
    }
    [OllaKeychain setPassword:userName forService:@"Olla" account:@"easeUserName" error:NULL];
    [OllaKeychain setPassword:password forService:@"Olla" account:@"easePassword" error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"easeUserName"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"easePassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)easeUserName {
    NSString *userName = [[LLPreference shareInstance] easeUserName];
    
    if (userName.length == 0) {
        userName = [OllaKeychain passwordForService:@"Olla" account:@"easeUserName" error:nil];
    }
    if (userName.length == 0) {
        userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"easeUserName"];
    }
    return userName;
    
}

- (NSString *)easeUserPassword {
   // NSString *password = [[OllaPreference shareInstance] easePassword];
//    if (password.length) {
      NSString *password = [OllaKeychain passwordForService:@"Olla" account:@"easePassword" error:nil];
//    }
//    if (password.length) {
//        password = [[NSUserDefaults standardUserDefaults] stringForKey:@"easePassword"];
//    }
    return password;
}

- (BOOL)isLoggedIn {
    return [[EaseMob sharedInstance].chatManager isLoggedIn] && [[EaseMob sharedInstance].chatManager loginInfo];
}

- (void)setVibrate:(BOOL)on {
//    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
//    if (on) {
//        options.noDisturbStatus = ePushNotificationNoDisturbStatusClose;
//    } else {
//        options.noDisturbStatus = ePushNotificationNoDisturbStatusDay;
//    }
//    [[EaseMob sharedInstance].chatManager updatePushOptions:options error:NULL];
}

- (void)loginWithCompletion:(void (^)(BOOL succeed))completion
{
    
    if ([self isLoggedIn])
    {
        if (completion)
        {
            completion(YES);
        }
        return;
    }
    
    __block __weak typeof(self) weakSelf = self;
    [_loginQueue queueBlock:^{
        
        if ([weakSelf isLoggedIn])
        {
            [[GCDQueue mainQueue] queueBlock:^
            {
                completion(YES);
            }];
            return;
        }
        
        NSString *easeUserName = [self easeUserName];
        NSString *easeUserPassword = [self easeUserPassword];
        if (easeUserName.length == 0 || easeUserPassword.length == 0)
        {
            sleep(2);
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate logout];
            return;
        }
        
        [[GCDQueue mainQueue] queueBlock:^
        {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
        }];
        
        int retryTime = 3;
        __block BOOL logging = YES;
        __block BOOL logginFinished = NO;
        
        while (retryTime > 0)
        {
            retryTime --;
            
            GCDSemaphore *semaphore = [[GCDSemaphore alloc] initWithValue:0];
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:easeUserName
                                                                password:easeUserPassword
                                                              completion:^(NSDictionary *loginInfo, EMError *error)
             {
                logging = NO;
                if (error.errorCode == EMErrorServerAuthenticationFailure
                    || error.errorCode == EMErrorNotFound)
                {
                    // 用户名或密码错误,退出
                    if (retryTime == 0)
                    {
                        
                        logginFinished = YES;
                        [semaphore signal];
                        
                        [[GCDQueue mainQueue] queueBlock:^
                        {
                            NSString *env = [LLAppHelper isTestEnv] ? @"测试环境" : @"正式环境";
                            NSString *userName = [LLAppHelper userName];
                            NSString *message = [NSString stringWithFormat:@"当前是%@, 账户名: %@, 环信用户不存在, 请使用新注册用户登录!", env, userName];
                            [PSTAlertController showBossMessage:message];
                        }];
                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [delegate logout];
                        
                        
                    }
                    else
                    {
                        [semaphore signal];
                    }
                }
                else if (error.errorCode == EMErrorServerTooManyOperations)
                {
                    [semaphore signal];
                }
                else if ([error.description hasPrefix:@"Already logged"] || !error)
                {

                    logginFinished = YES;
                    
                    id value = [[LLPreference shareInstance] valueForKey:@"Vibrate"];
                    if (!value)
                    {
                        [[LLPreference shareInstance] setValue:@(1) forKey:@"Vibrate"];
                        [[LLPreference shareInstance] synchronize];
                    }
                    
                    //将旧版的coredata数据导入新的数据库
                    EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
                    if (!error) {
                        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                    }
                    
                    [self removeOldNotificationMessages];
                    
                    [[EaseMob sharedInstance].chatManager disableAutoLogin];
                    
                    [[GCDQueue highPriorityGlobalQueue] queueBlock:^
                    {
                        NSDictionary *dict = [[[LLPreference shareInstance] userInfo] objectForKey:@"userInfo"];
                        NSString *nickname = [dict objectForKey:@"nickname"];
                        //设置推送设置
                        [[EaseMob sharedInstance].chatManager setApnsNickname:nickname];
                        [[EaseMob sharedInstance].chatManager enableDeliveryNotification];
                        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                        options.nickname = nickname;
                        options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
                        [[EaseMob sharedInstance].chatManager updatePushOptions:options error:NULL];
                    }];
                    
                    if (completion) {
                        completion(YES);
                    }
                    
                    [semaphore signal];
                }
                
                
            } onQueue:nil];
            
            // 20 秒超时
            [semaphore wait:10];
            
            if (logginFinished) {
                return;
            }
            
            sleep(1);
        }
        
        if (retryTime == 0 && !logginFinished) {
            if (completion) {
                completion(NO);
            }
            [weakSelf uploadLog];
        }
        
    }];
}

// 上传环信日志
- (void)uploadLog {
    
    __block __weak typeof(self) weakSelf = self;
    
    [[GCDQueue backgroundPriorityGlobalQueue] queueBlock:^
    {
        NSString *libraryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
        NSString *directoryPath = [libraryPath stringByAppendingPathComponent:@"EaseMobLog"];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath:directoryPath];
        NSString *targetFilePath;
        NSDate *targetFileDate;
        NSString *fileName;
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        while ((fileName = [dirEnumerator nextObject]))
        {
            if ([fileName hasPrefix:identifier]) {
                NSString *fullFilePath = [directoryPath stringByAppendingPathComponent:fileName];
                NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fullFilePath error:NULL];
                NSDate *modificationDate = [fileAttributes objectForKey:NSFileModificationDate];
                if (!targetFileDate || modificationDate.timeIntervalSince1970 > targetFileDate.timeIntervalSince1970 ) {
                    targetFilePath = fullFilePath;
                    targetFileDate = modificationDate;
                }
            }
        }
        
        [weakSelf queryIPWithCompleteBlock:^(NSString *ip, NSError *error) {
            NSString *log = [[NSString alloc] initWithContentsOfFile:targetFilePath encoding:NSUTF8StringEncoding error:NULL];
            if (log.length == 0) {
                log = @"";
            }
            if (ip.length > 0) {
                NSString *message = [NSString stringWithFormat:@"IP:%@\n%@",ip,log];
                [weakSelf uploadErrorLogWithMessage:message];
            } else {
                [weakSelf uploadErrorLogWithMessage:log];
            }
        }];
    }];
}

- (void)uploadErrorLogWithMessage:(NSString *)message {
    NSDictionary *parameters = @{@"level":@"ios-huanxin-error", @"message":message};
    [[LLHTTPRequestOperationManager shareManager] POSTWithURL:Olla_Error_Log parameters:parameters success:^(NSDictionary *responseObject) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)queryIPWithCompleteBlock:(void (^)(NSString *ip, NSError *error))block {
    NSString *string = @"http://api.ipify.org";
    NSURL *url = [NSURL URLWithString:string];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *ipAddress = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([ipAddress hasPrefix:@"error"]) {
            block(nil, nil);
        } else if (ipAddress.length > 0) {
            block(ipAddress, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    }];
    
    [operation start];
}

- (void)saveChatDraft:(NSString *)text withUid:(NSString *)uid {
    if (uid.length == 0) {
        return;
    }
    NSString *draftText = text.trim;
    LLEMIMDraft *draft = [LLEMIMDraft find:uid];
    if (draft) {
        draft.text = draftText;
        [LLEMIMDraft update:draft];
    }
    if (!draft) {
        draft = [LLEMIMDraft new];
        draft.uid = uid;
        draft.text = draftText;
        [LLEMIMDraft save:draft];
    }
    
}

- (NSString *)chatDraftWithUid:(NSString *)uid {
    LLEMIMDraft *draft = [LLEMIMDraft find:uid];
    if (draft) {
        return draft.text;
    }
    return nil;
}

- (void)removeOldNotificationMessages
{
    // 移除 3.6.1 版本以前的老数据
    if ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] isEqualToString:@"3.6.1"]) {
        BOOL removed = [[NSUserDefaults standardUserDefaults] boolForKey:@"RemoveOldNotificationMessages"];
        if (!removed) {
            
            for (NSString *account in _ollaAccounts) {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:account deleteMessages:YES append2Chat:NO];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"RemoveOldNotificationMessages"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    
}

- (NSArray *)groupBarMessagesWithAll:(BOOL)all {
    NSMutableArray *messages = [NSMutableArray array];
    
    NSArray *groupBarAccounts = @[LLEaseGroupBarInviteAccount, LLEaseGroupBarMessageAccount,LLEaseGroupBarLikeAccount,LLEaseGroupBarCommentAccount];
    
    for (NSString *account in groupBarAccounts) {
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:account conversationType:eConversationTypeChat];
        
        NSArray *conversationMessages = [conversation loadAllMessages];
        
        for (EMMessage *message in conversationMessages) {
            if (!all) {
                if (message.isRead) {
                    continue;
                }
            }
            NSDictionary *dict = [[message.ext objectForKey:@"ext"] jsonValue];
            if(!dict) {
                continue;
            }
            
            NSString *type = [dict stringForKey:@"type"];
            NSString *uid = [dict stringForKey:@"uid"];
            NSString *bid = [dict stringForKey:@"bid"];
            NSString *ouid = [dict stringForKey:@"ouid"];
            NSString *postId = [dict stringForKey:@"shareId"];
            NSString *comment = [dict stringForKey:@"comment"];
            
            if ([uid isEqualToString:[[LLPreference shareInstance] uid]]) {
                uid = ouid;
            }
            
            if (postId.length == 0) {
                postId = [dict stringForKey:@"postId"];
            }
            
            if (postId.length == 0) {
                postId = [dict stringForKey:@"id"];
            }
            
//            if ([type isEqualToString:LLGroupBarMessageTypeComment] ||
//                [type isEqualToString:LLGroupBarMessageTypeGood]) {
//                if (ouid.length == 0 || postId.length == 0) {
//                    continue;
//                }
//            } else {
//                if (uid.intValue == 0 || bid.intValue == 0) {
//                    continue;
//                }
//            }
//            
//            LLGroupBarMessage *groupBarMessage = [[LLGroupBarMessage alloc] init];
//            groupBarMessage.type = type;
//            groupBarMessage.chatId = account;
//            if (uid.length) {
//                groupBarMessage.uid = uid;
//            } else if (ouid.length) {
//                groupBarMessage.uid = ouid;
//            }
//            groupBarMessage.bid = bid;
//            groupBarMessage.ouid = ouid;
//            groupBarMessage.postId = postId;
//            if (comment.length > 0) {
//                groupBarMessage.message = comment;
//            } else {
//                id messageBody = message.messageBodies.lastObject;
//                NSString *text = ((EMTextMessageBody *)messageBody).text;
//                groupBarMessage.message = text;
//            }
//            groupBarMessage.date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:message.timestamp];
//            [messages insertObject:groupBarMessage atIndex:0];
        }
    }
    
//    NSArray *sortMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        LLGroupBarMessage *msg1 = obj1;
//        LLGroupBarMessage *msg2 = obj2;
//        
//        if (msg1.date.timeIntervalSince1970 > msg2.date.timeIntervalSince1970) {
//            return NSOrderedAscending;
//        }
//        
//        if (msg1.date.timeIntervalSince1970 < msg2.date.timeIntervalSince1970) {
//            return NSOrderedDescending;
//        }
//        
//        return NSOrderedSame;
//    }];
    
    return nil;
}

- (NSArray *)unreadGroupBarMessages {
    return [self groupBarMessagesWithAll:NO];
}

- (NSArray *)groupBarMessages {
    return [self groupBarMessagesWithAll:YES];
}

- (NSArray *)shareMessagesWithAll:(BOOL)all {
    
    NSMutableArray *messages = [NSMutableArray array];
    
    NSArray *groupBarAccounts = @[LLEaseShareCommentAccount, LLEaseShareLikeAccount];
    
    for (NSString *account in groupBarAccounts) {
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:account conversationType:eConversationTypeChat];
        
        NSArray *conversationMessages = [conversation loadAllMessages];
        
        for (EMMessage *message in conversationMessages) {
            if (!all) {
                if (message.isRead) {
                    continue;
                }
            }
            NSDictionary *dict = [[message.ext objectForKey:@"ext"] jsonValue];
            if(!dict) {
                continue;
            }
            NSString *type = [dict stringForKey:@"type"];
            NSString *uid = [dict stringForKey:@"ouid"];
            NSString *comment = [dict stringForKey:@"comment"];
            NSString *commentId = [dict stringForKey:@"commentId"];
            NSString *shareId = [dict stringForKey:@"shareId"];
            
//            if (![type isEqualToString:LLShareMessageTypeComment] && ![type isEqualToString:LLShareMessageTypeLike]
//                ) {
//                continue;
//            }
            
            if (shareId.length == 0) {
                shareId = [dict stringForKey:@"id"];
            }
            
            if (uid.length == 0 || shareId.length == 0) {
                continue;
            }
//            
//            LLShareMessage *shareMessage = [[LLShareMessage alloc] init];
//            shareMessage.type = type;
//            shareMessage.chatId = account;
//            if (uid.length) {
//                shareMessage.uid = uid;
//            }
//            shareMessage.shareId = shareId;
//            shareMessage.commentId = commentId;
//            if (comment.length > 0) {
//                shareMessage.message = comment;
//            } else {
//                id messageBody = message.messageBodies.lastObject;
//                NSString *text = ((EMTextMessageBody *)messageBody).text;
//                shareMessage.message = text;
//            }
//            shareMessage.date = [NSDate dateWithTimeIntervalInMilliSecondSince1970:message.timestamp];
//            [messages insertObject:shareMessage atIndex:0];
        }
    }
    
//    NSArray *sortMessages = [messages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        LLGroupBarMessage *msg1 = obj1;
//        LLGroupBarMessage *msg2 = obj2;
//        
//        if (msg1.date.timeIntervalSince1970 > msg2.date.timeIntervalSince1970) {
//            return NSOrderedAscending;
//        }
//        
//        if (msg1.date.timeIntervalSince1970 < msg2.date.timeIntervalSince1970) {
//            return NSOrderedDescending;
//        }
//        
//        return NSOrderedSame;
//    }];
    
    return nil;
}

- (NSArray *)shareMessages {
    return [self shareMessagesWithAll:YES];
}

- (NSArray *)unreadShareMessages {
    return [self shareMessagesWithAll:NO];
}

- (void)removeFansMessages {
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:LLEaseFansAccount conversationType:eConversationTypeChat];
    [conversation markAllMessagesAsRead:YES];
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:LLEaseFansAccount deleteMessages:YES append2Chat:YES];
}

- (void)removeShareMessages {
    NSArray *groupBarAccounts =@[LLEaseShareCommentAccount, LLEaseShareLikeAccount];
    for (NSString *account in groupBarAccounts) {
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:account conversationType:eConversationTypeChat];
        [conversation markAllMessagesAsRead:YES];
    }
}

- (void)removeGroupBarMessages {
    NSArray *groupBarAccounts =@[LLEaseGroupBarInviteAccount, LLEaseGroupBarMessageAccount,LLEaseGroupBarLikeAccount,LLEaseGroupBarCommentAccount];
    for (NSString *account in groupBarAccounts) {
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:account conversationType:eConversationTypeChat];
        [conversation markAllMessagesAsRead:YES];
    }
   // [[NSNotificationCenter defaultCenter] postNotificationName:LLGroupBarNewMessgeNotification object:@(0)];
}

- (void)removeNewPostGroupBarMessagesWithBid:(NSString *)bid {
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:LLEaseGroupBarMessageAccount conversationType:eConversationTypeChat];
    NSArray *messages = [conversation loadAllMessages];
    NSMutableArray *removeMessageIds = [NSMutableArray array];
    for (EMMessage *message in messages) {
        NSDictionary *dict = [[message.ext objectForKey:@"ext"] jsonValue];
        NSString *barId = [dict stringForKey:@"bid"];
        if ([barId isEqualToString:bid]) {
            [removeMessageIds addObject:message.messageId];
        }
    }
    
    [conversation removeMessagesWithIds:removeMessageIds];
}


@end
