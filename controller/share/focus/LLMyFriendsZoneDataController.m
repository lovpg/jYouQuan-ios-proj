//
//  LLMyFriendsZoneDataController.m
//  Olla
//
//  Created by nonstriater on 14-8-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLMyFriendsZoneDataController.h"
#import "LLShare.h"

@implementation LLMyFriendsZoneDataController

-(void)viewLoaded{
    [self.bottomLoadingView.indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.bottomLoadingView.textLabel setTextColor:[UIColor blackColor]];
    
    if(!IS_IOS7){
        self.flicker = YES;
    }

}

// 覆盖掉refreshview
- (void)showMessageNotificationWithAvatar:(NSString *)avatar messageCount:(NSInteger)count{
    
    if (![avatar isString] || [avatar length]==0) {
        DDLogError(@"收到新评论通知，但是avatar信息不对：%@",avatar);
        return;
    }
    
    if (count <= 0) {
        return;
    }
    
    NSString *promptMessage = [NSString stringWithFormat:@"%li comment",(long)count];
    if (count>1) {
        promptMessage = [promptMessage stringByAppendingString:@"s"];
    }
    
    [self.commentNotifyCell setDataItem:@{@"avatar":[LLAppHelper thumbImageWithURL:avatar size:CGSizeMake(120.f,120.f)],@"message":promptMessage}];
    if (![self.headerCells containsObject:self.commentNotifyCell]) {
        
        self.hasMessageNotification = YES;
        
        [self.tableView beginUpdates];
        
        [self.headerCells addObject:self.commentNotifyCell];//如果xib还没有load，这时候commentNotifyCell为nil，会造成崩溃，使用强制loadView
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }
    
}

- (void)hideMessageNotification{
    
    if ([self.headerCells containsObject:self.commentNotifyCell]) {
        
        self.hasMessageNotification = NO;
        
        [self.tableView beginUpdates];
        
        [self.headerCells removeObject:self.commentNotifyCell];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
        
    }
}


@end


