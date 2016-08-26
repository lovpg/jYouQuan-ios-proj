//
//  OllaCollectionDataController.m
//  Olla
//
//  Created by null on 14-10-30.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaCollectionDataController.h"

@implementation OllaCollectionDataController

#pragma mark - collectionview datasource

-(void)viewLoaded{

    [super viewLoaded];
    [self.collectionView registerNib:[UINib nibWithNibName:self.itemViewNib bundle:nil] forCellWithReuseIdentifier:self.itemViewNib];
    self.collectionView.collectionViewLayout = self.collectionLayout;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.dataSource count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
 
    id data = [self dataAtIndexPath:indexPath];
    NSString *reuseIdentifier = self.itemViewNib;
    //itemViewNib空会崩溃
    NSAssert([_itemViewNib length], @"itemViewNib空会崩溃");
   
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[OllaCollectionViewCell class]]) {
        [(OllaCollectionViewCell *)cell setDelegate:self];
        [(OllaCollectionViewCell *)cell setDataItem:data];
    }

    return cell;
}


// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *reusableView = nil;
    
    if ([kind isEqualToString:@""]) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"" forIndexPath:indexPath];
    }
    
    return reusableView;
}


#pragma mark - collectionview layout


#pragma mark - collectionview delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.delegate respondsToSelector:@selector(collectionController:didSelectAtIndexPath:)]) {
        [self.delegate collectionController:self didSelectAtIndexPath:indexPath];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

// cell上按钮点击
- (void)collectionViewCell:(OllaCollectionViewCell *)cell doAction:(id)sender event:(UIEvent *)event{

    if([self.delegate respondsToSelector:@selector(collectionController:cell:doAction:event:)]){
        [self.delegate collectionController:self cell:cell doAction:sender event:event];
    }
}



#pragma datasource delegate

- (void)dataSourceDidLoaded:(OllaDataSource *)dataSource{
    [super dataSourceDidLoaded:dataSource];
    [_collectionView reloadData];
}



@end

