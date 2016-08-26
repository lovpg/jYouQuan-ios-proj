//
//  EMMessage+Helper.m
//  Olla
//
//  Created by Pat on 15/7/9.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "EMMessage+Helper.h"

@implementation EMMessage (Helper)

//SYNTHESIZE_ASC_OBJ(extObject, setExtObject);

- (EMMessageExtType)extType {
    
    NSDictionary *ext = nil;
    
    if ([self.ext objectForKey:@"ext"])
    {
        ext = [self.ext objectForKey:@"ext"];
    }
    else {
        ext = self.ext;
    }
    
    if (! ext || [ext isKindOfClass:[NSString class]])ext = [self dictionaryWithJsonString:(NSString*)ext];
    if (![ext isKindOfClass:[NSDictionary class]])return EMMessageExtTypeNone;
    
    NSString *type = [ext stringForKey:@"type"];
    if ([type isEqualToString:@"groupbar"]) {
        if (ext[@"bid"]) {
            return EMMessageExtTypeGroupBar;
        }
    }
    if ([type isEqualToString:@"postGood"])
    {
        if (ext[@"id"])
        {
            return EMMessageExtTypePushGood;
        }
    }
    if ([type isEqualToString:@"comment"])
    {
        if (ext[@"shareId"])
        {
            return EMMessageExtTypePushComment;
        }
    }
    if ([type isEqualToString:@"post"]) {
        if (ext[@"pid"]) {
            return EMMessageExtTypeGroupBarPost;
        }
    }
    
    if ([type isEqualToString:@"share"]) {
        if (ext[@"sid"]) {
            return EMMessageExtTypePersonalShare;
        }
    }
    
    if ([type isEqualToString:@"quicktutor"]) {
        if (ext[@"uid"] && ext[@"coin"] && ext[@"chatId"]) {
            NSString *action = ext[@"action"];
            if ([action isEqualToString:@"ask"]) {
                return EMMessageExtTypeQuickTutor;
            }
            return EMMessageExtTypeQuickTutorRespond;
        }
    }
    
    return EMMessageExtTypeNone;
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
