//
//  LLPhotoLayoutManager.h
//  Olla
//
//  Created by null on 14-11-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLPhotoLayout.h"

@interface LLPhotoLayoutManager : NSObject

@property(nonatomic,assign) CGFloat maxWidth;
@property(nonatomic,strong) NSArray *photos;
@property(nonatomic,strong,readonly) LLPhotoLayout *photoLayout;
@property(nonatomic,assign,readonly) CGFloat photoLayoutHeight;

@end


