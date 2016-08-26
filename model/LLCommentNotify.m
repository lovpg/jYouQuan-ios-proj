//
//  LLCommentNotify.m
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCommentNotify.h"

@implementation LLCommentNotify

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {  
        self.share = [aDecoder decodeObjectForKey:@"share"];
        self.comment = [aDecoder decodeObjectForKey:@"comment"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeObject:self.share forKey:@"share"];
    [aCoder encodeObject:self.comment forKey:@"comment"];
}


- (void)dealloc{
    
    DDLogInfo(@"%@ <%@> dealloced",[self class],self);

}

@end
