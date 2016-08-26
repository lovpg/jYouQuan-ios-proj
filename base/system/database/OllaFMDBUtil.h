//
//  OllaDB.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vender.h"

@interface OllaFMDBUtil : NSObject

+ (void)execInDatabase:(void (^)(FMDatabase *db))block;

@end
