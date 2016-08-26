//
//  OllaDataSource.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaDataSource.h"
#import "NSObject+KeyPath.h"
#import "system.h"

@implementation OllaDataSource

@synthesize context = _context;
@synthesize delegate = _delegate;

@synthesize skipCached = _skipCached;
@synthesize dataChanged = _dataChanged;

- (void)viewLoaded{

}

-(void)setContext:(id<IOllaUIContext>)context{
    
    if (context != _context) {
        [_context cancelHandleForSource:self];
        _context = context;
    }
}


-(void) refreshData{
    
    //[self.dataObjects removeAllObjects];// 在新数据下载后再清
    [self loadData];
}

-(void) loadData{
    
    _loading = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(dataSourceWillLoading:)]) {
        [_delegate dataSourceWillLoading:self];
    }
    
}

-(void) cancel{
    
    _loading = NO;
}

-(NSInteger) count{
    
    return [_dataObjects count];
}


-(NSMutableArray *)dataObjects{
    if (!_dataObjects) {
        _dataObjects = [[NSMutableArray alloc] init];
    }
    return _dataObjects;
}

-(id) dataObjectAtIndex:(NSUInteger) index{
    
    if (index<[self count]) {
        return [_dataObjects objectAtIndex:index];
    }
    
    return nil;
}

- (BOOL)removeObjectAtIndex:(NSUInteger)index{
    
    if (index>=[self count]) {
        return NO;
    }
    [_dataObjects removeObjectAtIndex:index];
    return YES;
}

/**
 *  resutl.data
 *
 *  @param resultsData
 */
-(void) loadResultsData:(id) resultsData{
    
    id items = _dataKey ? [resultsData dataForKeyPath:_dataKey]:resultsData;
    if ([items isKindOfClass:[NSArray class]]) {
        [[self dataObjects] addObjectsFromArray:items];
        
    }else if([items isKindOfClass:[NSDictionary class]]){
        [[self dataObjects] addObject:[NSMutableDictionary dictionaryWithDictionary:items]];
    }
    
}

- (void)downlinkTaskDidLoadedFromCache:(id)cache timestamp:(NSDate *)timestamp forTaskType:(Protocol *)taskType{
    
    //    if (self.dataChanged) {
    //        [self.dataObjects removeAllObjects];
    //        [self loadResultsData:cache];
    //    }
    [self loadResultsData:cache];
    
    if ([_delegate respondsToSelector:@selector(dataSourceDidLoadedFromCache:timestamp:)]) {
        [_delegate dataSourceDidLoadedFromCache:self timestamp:timestamp];
    }
    
    // self.dataChanged = NO;
}

- (void)downlinkTaskDidLoaded:(id)data forTaskType:(Protocol *)taskType{
    _loaded = NO;
    [self loadResultsData:data];
    
    if (_delegate && [_delegate respondsToSelector:@selector(dataSourceDidLoaded:)]) {
        [_delegate dataSourceDidLoaded:self];
    }
    
    _loading = NO;
    _loaded = YES;
    //_skipCached = NO;
    //self.dataChanged = NO;
}

- (void)downlinkTaskDidFitalError:(NSError *)error forTaskType:(Protocol *)taskType{
    
    if ([_delegate respondsToSelector:@selector(dataSource:didFitalError:)]) {
        [_delegate dataSource:self didFitalError:error];
    }
    
    _loading = NO;
    _loaded = YES;
    
}



@end
