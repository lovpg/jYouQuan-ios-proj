//
//  LLPhotoLayoutProtocol.h
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

@protocol LLPhotoLayoutProtocol <NSObject>

@property(nonatomic,strong) NSArray *photos;

- (CGRect)viewFrameAtIndex:(NSUInteger)index;
- (CGFloat)layoutHeight;
- (void)layout;

@end
