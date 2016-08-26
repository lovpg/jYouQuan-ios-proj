//
//  LLShareDataSouce.h
//  Olla
//
//  Created by Pat on 15/7/31.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LLShareDataSourceDelegate;

@interface LLShareDataSource : NSObject

@property (nonatomic, weak) id<LLShareDataSourceDelegate> delegate;

- (void)loadAllNotifyMessages;
- (void)loadUnreadNotifyMessages;
@end

@protocol LLShareDataSourceDelegate <NSObject>

@optional
- (void)shareNotifyMessagesDidChange:(NSArray *)messages;

@end
