//
//  OllaStyleParser.m
//  OllaFramework
//
//  Created by nonstriater on 14-8-13.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaStyleParser.h"

@interface OllaStyleParser (){
    
    NSString *_path;
}

@end

@implementation OllaStyleParser

+ (instancetype)sharePareser{

    static OllaStyleParser *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OllaStyleParser alloc] init];
    });
    
    return instance;
}

- (void)parseWithPath:(NSString *)path{


    //_path  = path;
    //self.styles = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    if (![dict isDictionary]) {
        return ;
    }
    
    _styles = dict;
    
}





@end
