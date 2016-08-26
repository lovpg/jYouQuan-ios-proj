//
//  UColor+Hex.h
//  iDleChat
//
//  Created by Reco on 16/1/25.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColorHex : NSObject

+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end
