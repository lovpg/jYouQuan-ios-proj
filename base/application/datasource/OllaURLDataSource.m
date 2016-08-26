//
//  OllaURLDataSource.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaURLDataSource.h"

@implementation OllaURLDataSource

@synthesize url = _url;
@synthesize urlKey = _urlKey;

- (id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)loadData{

    [super loadData];
    [self.context handle:@protocol(IOllaURLDownlinkTask) task:self priority:0];
}

- (void)loadMoreData{

    [super loadMoreData];
    [self.context handle:@protocol(IOllaURLDownlinkTask) task:self priority:0];
}

- (void)cancel{

    [super cancel];
    [self.context cancelHandle:@protocol(IOllaURLDownlinkTask) task:self];
}

@end
