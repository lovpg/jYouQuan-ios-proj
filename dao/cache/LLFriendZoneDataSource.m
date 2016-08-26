//
//  LLFriendZoneDataSource.m
//  Olla
//
//  Created by nonstriater on 14-7-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFriendZoneDataSource.h"
#import "LLHTTPRequestOperationManager.h"
#import "LLShare.h"

@implementation LLFriendZoneDataSource

//TODO: LLFriendZoneDataSource 与 LLPlazaDataSource 区别仅是url不同，整合

- (void)loadData{
    [super loadData];
    // sucess block 被call 了多次！！！
    __weak __typeof(self)weakSelf = self;
    [[LLHTTPRequestOperationManager shareManager]
     GETListWithURL:Olla_API_Share_Friends
     parameters:@{@"pageId":[NSNumber numberWithInt:self.pageIndex],
                  @"size":[NSNumber numberWithInt:self.pageSize]}
     modelType:[LLShare class]
     success:^(NSArray *datas , BOOL hasNext){
         
         __strong __typeof(self)strongSelf = weakSelf;
         strongSelf.hasMoreData = hasNext;
         
         [strongSelf downlinkTaskDidLoaded:datas forTaskType:nil];
         
         
     } failure:^(NSError *error){
         [self downlinkTaskDidFitalError:error forTaskType:nil];
     }];
    
}

//做shareid过滤，服务端没法做到完全不重复
- (void)loadResultsData:(NSArray *)resultsData{
    
    // super 是不用调用了
    if (self.pageIndex==1 && [self.dataObjects count]>0) {
        [self.dataObjects removeAllObjects];
    }

    
    for (LLShare *newShare in resultsData) {
        if (![newShare isKindOfClass:LLShare.class]) {
            continue;
        }
        
        BOOL exists = NO;
        for (LLShare *share in self.dataObjects) {
            if ([newShare.shareId isEqualToString:share.shareId]) {
                exists = YES;
                break;
            }
        }
        if (!exists) {
            [self.dataObjects addObject:newShare];
        }
        
    }
    
}



@end
