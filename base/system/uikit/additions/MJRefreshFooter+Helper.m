//
//  MJRefreshAutoNormalFooter+Helper.m
//  Olla
//
//  Created by Pat on 15/7/23.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "MJRefreshFooter.h"

@implementation MJRefreshFooter (Helper)

SYNTHESIZE_ASC_OBJ(page_, setPage_);
SYNTHESIZE_ASC_OBJ_ASSIGN(size_, setSize_);

- (NSInteger)page {
    return [self.page_ integerValue];
}

- (NSInteger)size {
    return [self.size_ integerValue];
}

- (void)setPage:(NSInteger)page {
    self.page_ = @(page);
}

- (void)setSize:(NSInteger)size {
    self.size_ = @(size);
}

@end
