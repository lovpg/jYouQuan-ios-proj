//
//  LLPhotoLayout.h
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPhotoLayoutProtocol.h"

@interface LLPhotoLayout : UIView<LLPhotoLayoutProtocol>

@property (nonatomic, assign) CGFloat maxWidth;

- (void)photoSelectedAtIndex:(NSInteger)index;
- (void)photoSelected:(id)sender;

@end
