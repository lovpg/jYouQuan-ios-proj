//
//  OllaDB.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLFMDBUtil.h"
#import "LLPreference.h"

@implementation LLFMDBUtil

+ (void)execInDatabase:(void (^)(FMDatabase *db))block
{

    NSString *uid = [[LLPreference shareInstance] uid];
    if ([uid length]==0) {
        DDLogError(@"%s:u must set the uid first",__PRETTY_FUNCTION__);
        return ;
    }
    NSString *dpPath = [LLFMDBUtil dbPathWithUid:uid];
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
    }else{
        DDLogError(@"db(%@) open error",dpPath);
    }
    
    db = nil;
}


+ (NSString *)dbPathWithUid:(NSString *)uid{

    NSString *path = [[OllaSandBox documentPath] stringByAppendingPathComponent:[uid MD5Encode]] ;
    if (![OllaSandBox createPathIfNotExist:path]) {
        DDLogError(@"DB ERROR:%@ path create fail",path);
    }
    NSString *dbPath = [path stringByAppendingPathComponent:@"DB"];
    DDLogInfo(@"dbPath= %@",dbPath);
    if (![OllaSandBox createPathIfNotExist:dbPath]) {
        DDLogError(@"DB ERROR:%@ path create fail",dbPath);
    }
    
    return [dbPath stringByAppendingPathComponent:@"MM.sqlite"];
}

@end


