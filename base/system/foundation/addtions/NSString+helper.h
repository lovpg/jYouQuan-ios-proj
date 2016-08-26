//
//  NSString+helper.h
//  Olla
//
//  Created by Pat on 15/5/26.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (NSString *)trim;
- (BOOL)containString:(NSString *)string;
- (BOOL)isEmpty;
- (NSString *)detectLanguage;
- (BOOL)isEmojiString;
- (NSString *)stringWithoutEmoji;
- (NSString *)stringByReplacingChineseMark;

- (BOOL)isArabic;

@end
