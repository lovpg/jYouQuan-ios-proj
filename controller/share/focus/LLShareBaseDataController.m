//
//  LLShareBaseDataController.m
//  Olla
//
//  Created by null on 14-9-9.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShareBaseDataController.h"
#import "LLShare.h"

@implementation LLShareBaseDataController

//对有 message notify 等情况的需要,重写，以保证数据不错位
//不要一边遍历一边删除元素
- (void)deleteShare:(NSString *)shareID{
    
    NSInteger index = NSIntegerMax;
    for (int i=0;i<[self.dataSource count];i++) {    
        LLShare *item = [self.dataSource dataObjects][i];
        if ([item.shareId isEqualToString:shareID]) {
            index = i;
            break;
        }
    }
    
    if (index!=NSIntegerMax) {
        if([self.dataSource removeObjectAtIndex:index]){
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index+[self.headerCells count] inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }else{
            [self.tableView reloadData];
        }
    }
    
}


@end
