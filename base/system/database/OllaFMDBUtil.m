//
//  OllaDB.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaFMDBUtil.h"

@implementation OllaFMDBUtil

+ (void)execInDatabase:(void (^)(FMDatabase *db))block{

    NSString *dpPath = nil;
    FMDatabase *db = [FMDatabase databaseWithPath:dpPath];
    
    if([db open]){
        @try {
            block(db);
        }
        @catch (NSException *exception) {
            DDLogError(@"db exception:%@",exception);
        }
        @finally {
            [db close];
        }
    }
    
    db = nil;
}



@end
