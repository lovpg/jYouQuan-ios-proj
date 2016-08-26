//
//  MJRefreshAutoNormalFooter+Helper.h
//  Olla
//
//  Created by Pat on 15/7/23.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "MJRefreshFooter.h"

@interface MJRefreshFooter (Helper)

- (NSInteger)page;
- (NSInteger)size;

- (void)setPage:(NSInteger)page;
- (void)setSize:(NSInteger)size;

@end
