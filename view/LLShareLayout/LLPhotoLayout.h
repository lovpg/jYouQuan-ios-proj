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

@property (nonatomic, assign) BOOL isMovie; // 记录该帖子是否是视频帖子
@property (nonatomic, strong) NSString *videoUrl; // 视频的播放地址

- (void)photoSelectedAtIndex:(NSInteger)index;
- (void)photoSelected:(id)sender;

@end
