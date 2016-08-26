//
//  LLShareImageButton.m
//  Olla
//
//  Created by null on 15-2-1.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareImageButton.h"

@implementation LLShareImageButton

- (void)setRemoteImageURL:(NSString *)remoteImageURL{
    
    NSString *thumbURL = remoteImageURL;
    //服务端图片给的绝对路径，要适配最优host路径
    if ([thumbURL hasPrefix:@"http"]&&[thumbURL containsSubString:@"lbslm.com"])
    {
        NSString *adptiveHost = [LLAppHelper baseAPIURL];
        NSRange range = [thumbURL rangeOfString:@"lbslm.com"];
        thumbURL = [thumbURL stringByReplacingCharactersInRange:NSMakeRange(0, range.location+range.length) withString:adptiveHost];
    }
//    DDLogInfo(@"share image thumb imageurl = %@",thumbURL);
    [super setRemoteImageURL:thumbURL];
    
}

@end
