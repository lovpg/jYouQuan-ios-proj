//
//  OllaSearchTableController.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-2.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaTableDataController.h"

@interface OllaSearchTableController : OllaTablePageController<UISearchBarDelegate,UISearchDisplayDelegate>

@property(nonatomic,strong) IBOutlet UISearchBar *searchBar;
@property(nonatomic,strong) IBOutlet UISearchDisplayController *searchDisplayController;//replace by UISearchController iOS8
@property(nonatomic,strong) NSString *searchCellNib;
@property(nonatomic,strong) NSString *resultCellReuseIdentifier;
@property(nonatomic,strong) NSMutableArray *searchResultObjects;
@property(nonatomic,assign) BOOL searchBarHidden;

@property(nonatomic,strong) NSMutableArray *groupData;//分组数据 @[@{@"A":@[]},@{@"F":@[]}]

@property(nonatomic,strong) NSArray *sectionHeaderTitles;
@property(nonatomic,strong) NSArray *sectionIndexTitles;
@property(nonatomic,assign) BOOL sectionIndexHidden;//是否使用边索引的开关

- (void)hiddenSearchBarAnimated:(BOOL)animated;
//如dataItem.user.nickname

- (void)sortAndGroupDataWithKeyPath:(NSString *)keyPath;
- (void)sortWithDataKeyPath:(NSString *)keyPath;
- (void)setupSectionTitlesWithDataKeyPath:(NSString *)keyPath;

@end




@protocol OllaSearchTableControllerDelegate <NSObject>

- (void)tableDataController:(OllaController *)controller tableView:(UITableView *)tableView didSelectAtIndexPath:(NSIndexPath *)indexPath;


@end

