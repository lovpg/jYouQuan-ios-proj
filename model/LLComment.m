//
//  LLComment.m
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLComment.h"

@implementation LLComment


- (id)initWithCoder:(NSCoder *)aDecoder{
   
    
    if (self = [super init]) {
        self.commentId = [aDecoder decodeObjectForKey:@"commentId"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.shareId = [aDecoder decodeObjectForKey:@"shareId"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.posttime = [[aDecoder decodeObjectForKey:@"posttime"] doubleValue];
        self.user = [aDecoder decodeObjectForKey:@"user"];
        
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.commentId forKey:@"commentId"];
    [aCoder encodeObject:self.content forKey:@"content"];
    
    [aCoder encodeObject:self.shareId forKey:@"shareId"];
    [aCoder encodeObject:@(self.posttime) forKey:@"posttime"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    
    [aCoder encodeObject:self.user forKey:@"user"];
   
    
    
}

- (NSString *)vlen {
    
    return [NSString stringWithFormat:@"%d", _vlen.intValue];
}




@end
