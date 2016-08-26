//
//  OllaTableDataController.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaTableDataController.h"
#import "OllaTableViewCell.h"
#import "OllaPageDataSource.h"

@interface OllaTableDataController (){
}
@end

@implementation OllaTableDataController


- (void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)stopLoading{
    
    if (self.dataLoadingError) {
        if (self.dataNotFoundView && self.dataNotFoundView.superview==nil) {
            self.dataNotFoundView.frame = _tableView.bounds;
            [_tableView addSubview:self.dataNotFoundView];
            return;
        }
    }else{
        [self.dataNotFoundView removeFromSuperview];
    }
    
    if ([self.dataSource isEmpty]) {
        if (self.dataEmptyView && self.dataEmptyView.superview==nil) {
            self.dataEmptyView.frame = _tableView.bounds;
            [_tableView addSubview:self.dataEmptyView];
        }
    }else{
        [self.dataEmptyView removeFromSuperview];
    }
}


- (void)setHeaderCells:(NSArray *)headerCells{
    if (_headerCells != headerCells) {
        _headerCells = [NSMutableArray arrayWithArray:headerCells];
    }
}


#pragma mark - tableview datasource / delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSUInteger dataSourceCount = [self.dataSource count];
    //    if (!dataSourceCount) {
    //        return [_headerCells count];
    //    }
    return [_headerCells count] + dataSourceCount ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<[_headerCells count]) {
        return [[_headerCells objectAtIndex:indexPath.row] frame].size.height;
    }
    
    return tableView.rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<[_headerCells count]) {
        return [_headerCells objectAtIndex:indexPath.row];
    }
    
    
    //itemViewNib空会崩溃
    NSAssert([_itemViewNib length], @"itemViewNib空会崩溃");
    NSString *reuseIdentifier=nil;
    NSString *nibName = _itemViewNib;
    
    if (!reuseIdentifier) {
        reuseIdentifier = _itemViewNib;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        
        //意义在于可以在自定义的cell的init..nib..方法中初始化参数
        Class clazz = NSClassFromString(_itemViewNib);
        if ( !clazz ) {
            clazz = [OllaTableViewCell class];
        }
        
        cell = [[clazz alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier nibName:nibName];
    }
    
    if ([cell isKindOfClass:[OllaTableViewCell class]]) {
        [(OllaTableViewCell *)cell setDelegate:self];// 代理cell上的button event
        [self configCell:(OllaTableViewCell *)cell atIndexPath:indexPath];
    }
    
    return cell;
}

// to be override
- (void)configCell:(OllaTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    id data = [self dataAtIndexPath:indexPath];
    [(OllaTableViewCell *)cell setDataItem:data];
}

- (id)dataAtIndexRow:(NSInteger)row{
    
    return [self dataAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

// middle insert/ search table 就可以重写这个方法，这样写，主要是方便子类重写
- (id)dataAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource dataObjectAtIndex:(indexPath.row-[_headerCells count])];// 这里要设置好，不然数据错位
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(tableDataController:didSelectAtIndexPath:)]) {
        [self.delegate tableDataController:self didSelectAtIndexPath:indexPath];
    }
    
}

- (void)tableViewCell:(OllaTableViewCell *)cell doAction:(id)sender event:(UIEvent *)event{
    
    if ([self.delegate respondsToSelector:@selector(tableDataController:cell:doAction: event:)]) {
        [self.delegate tableDataController:self cell:cell doAction:sender event:event];
    }
}


// index  /////////////////////////////////////////////////
-(NSArray *)sectionIndexTitlesForTableView{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}


// cell edit ///////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row<[self.headerCells count] || indexPath.row == [self.headerCells count]+[self.dataSource count]) {
        return NO;
    }
    
    return _canCellDelete;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return _canCellDelete?UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"Delete";
    
}


#pragma datasource delegate

- (void)dataSourceDidLoaded:(OllaDataSource *)dataSource{
    [super dataSourceDidLoaded:dataSource];
    [_tableView reloadData];
}


-(void)dataSourceDidLoadedFromCache:(OllaDataSource *)dataSource timestamp:(NSDate *)timestamp{
    [super dataSourceDidLoadedFromCache:dataSource timestamp:timestamp];
    [_tableView reloadData];
    
}





@end
