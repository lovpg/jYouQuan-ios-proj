//
//  OllaDataSource.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OllaTask.h"
#import "IOllaController.h"
#import "IOllaDownlinkTask.h"

@interface OllaDataSource : OllaTask<IOllaController,IOllaDownlinkTask>

@property(nonatomic,weak) IBOutlet id delegate;
@property(nonatomic,strong) NSMutableArray *dataObjects;

/**
 *   json数据中的key链  eg. result.data
 */
@property(nonatomic,strong) NSString *dataKey;

@property(nonatomic,assign,getter = isLoading) BOOL loading;
@property(nonatomic,assign,getter = isLoaded) BOOL loaded;
@property(nonatomic,readonly,getter = isEmpty) BOOL empty;

-(void) refreshData;

-(void) loadData;

-(void) cancel;

-(NSInteger) count;

-(NSMutableArray *)dataObjects;

- (id)dataObjectAtIndex:(NSUInteger) index;
- (BOOL)removeObjectAtIndex:(NSUInteger)index;

- (void)loadResultsData:(id) resultsData;

@end



@protocol OllaDataSourceDelegate
@optional

-(void) dataSourceWillLoading:(OllaDataSource *) dataSource;
-(void) dataSourceDidLoadedFromCache:(OllaDataSource *) dataSource timestamp:(NSDate *) timestamp;
-(void) dataSourceDidLoaded:(OllaDataSource *) dataSource;
-(void) dataSource:(OllaDataSource *) dataSource didFitalError:(NSError *) error;
-(void) dataSourceDidContentChanged:(OllaDataSource *) dataSource;

@end



