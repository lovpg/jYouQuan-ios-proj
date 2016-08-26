//
//  LLShare.m
//  Olla
//
//  Created by nonstriater on 14/8/23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLShare.h"

@implementation LLShare

- (NSString *)uniqueId {
    return self.shareId;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.shareId = [aDecoder decodeObjectForKey:@"shareId"];
        self.content = [aDecoder decodeObjectForKey:@"content"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
         self.imageList = [aDecoder decodeObjectForKey:@"imageList"];
        
        self.location = [aDecoder decodeObjectForKey:@"location"];
        self.posttime = [[aDecoder decodeObjectForKey:@"posttime"] doubleValue];
       
        self.commentCount = [[aDecoder decodeObjectForKey:@"commentCount"] intValue];
        self.goodCount = [[aDecoder decodeObjectForKey:@"goodCount"] intValue];
        self.good = [[aDecoder decodeObjectForKey:@"good"] boolValue];
        self.user = [aDecoder decodeObjectForKey:@"user"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.shareId forKey:@"shareId"];
    [aCoder encodeObject:self.content forKey:@"content"];
    
    [aCoder encodeObject:@(self.posttime) forKey:@"posttime"];
    [aCoder encodeObject:self.imageList forKey:@"imageList"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.address forKey:@"address"];
    
    [aCoder encodeObject:@(self.commentCount) forKey:@"commentCount"];
    [aCoder encodeObject:@(self.goodCount) forKey:@"goodCount"];
    [aCoder encodeObject:@(self.good) forKey:@"good"];
    [aCoder encodeObject:self.user forKey:@"user"];
    
}

- (NSString *)timeString {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.posttime/1000];
    return [date formatRelativeTime];
}


@end
