//
//  LLAvatarImageView.m
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLAvatarImageView.h"

@implementation LLAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.thumbSize = CGSizeMake(80.f,80.f);
 
    }
    return self;
}


- (void)setRemoteImageURL:(NSString *)remoteImageURL{
    
    if ([remoteImageURL length]==0) {
        DDLogError(@"头像地址为空。remoteURL=%@",remoteImageURL);
        //不要return，下面的api还要显示默认头像
    }
    NSString *thumbURL = [LLAppHelper thumbImageWithURL:remoteImageURL size:self.thumbSize];
    //服务端图片给的绝对路径，要适配最优host路径
    if ([thumbURL hasPrefix:@"http"]&&[thumbURL containsSubString:@"olla.im"]) {
        NSString *adptiveHost = [LLAppHelper baseAPIURL];
        NSRange range = [thumbURL rangeOfString:@"olla.im"];
        thumbURL = [thumbURL stringByReplacingCharactersInRange:NSMakeRange(0, range.location+range.length) withString:adptiveHost];
    }

    [super setRemoteImageURL:thumbURL];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
