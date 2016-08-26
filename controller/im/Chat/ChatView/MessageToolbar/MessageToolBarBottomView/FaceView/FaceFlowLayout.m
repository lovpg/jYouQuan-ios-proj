//
//  FaceFlowLayout.m
//  Olla
//
//  Created by Pat on 15/3/25.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "FaceFlowLayout.h"

@implementation FaceFlowLayout

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSInteger section = self.collectionView.numberOfSections;
    
    NSMutableArray *array = [NSMutableArray array];
    int row = 4;

    for (int i=0; i<section; i++) {
        for (int j=0; j<row; j++) {
            UICollectionViewLayoutAttributes *atts = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            [array addObject:atts];
        }
    }
    
    return array;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* atts = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    float width = self.itemSize.width;
    float height = self.itemSize.height;
    atts.frame = CGRectMake(indexPath.section * width, indexPath.row * height, width, height);
    
    return atts;
}

- (CGSize)collectionViewContentSize {
    NSInteger section = self.collectionView.numberOfSections;
    CGSize size = CGSizeMake((ceil(section / 7)) * self.collectionView.width, self.collectionView.height);
    return size;
}

@end
