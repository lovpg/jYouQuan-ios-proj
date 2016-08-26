//
//  LLAvatarImageButon.m
//  Olla
//
//  Created by null on 14-9-5.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLAvatarImageButon.h"

@implementation LLAvatarImageButon

- (void)setRemoteImageURL:(NSString *)remoteImageURL{
    
    //加一个缩略
    NSString *thumbURL = [LLAppHelper thumbImageWithURL:remoteImageURL size:self.thumbSize];
    //服务端图片给的绝对路径，要适配最优host路径
    if ([thumbURL hasPrefix:@"http"]&&[thumbURL containsSubString:@"olla.im"]) {
        NSString *adptiveHost = [LLAppHelper baseAPIURL];
        NSRange range = [thumbURL rangeOfString:@"olla.im"];
        thumbURL = [thumbURL stringByReplacingCharactersInRange:NSMakeRange(0, range.location+range.length) withString:adptiveHost];
    }
//    DDLogInfo(@"url=%@, thumb imageurl = %@",remoteImageURL,thumbURL);
    [super setRemoteImageURL:thumbURL];

}


@end
