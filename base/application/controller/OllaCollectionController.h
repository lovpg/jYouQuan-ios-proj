//
//  OllaCollectionController.h
//  Olla
//
//  Created by null on 14-10-30.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

// base controller for collectionView & tableView
#import "OllaDataController.h"

@interface OllaCollectionController : OllaDataController

@property(nonatomic, strong) IBOutlet UIView *dataEmptyView;
@property(nonatomic,strong) IBOutlet UIView *dataNotFoundView;
@property(nonatomic,assign) BOOL dataLoadingError;

- (void)startLoading;
- (void)stopLoading;

- (id)dataAtIndexRow:(NSInteger)row;
- (id)dataAtIndexPath:(NSIndexPath *)indexPath;


@end
