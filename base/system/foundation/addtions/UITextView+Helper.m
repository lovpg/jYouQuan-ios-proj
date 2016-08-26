//
//  UITextView+Helper.m
//  Olla
//
//  Created by Pat on 15/6/8.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "UITextView+Helper.h"

@implementation UITextView (Helper)

- (CGFloat)heightToFits {
    return [self sizeThatFits:CGSizeMake(self.width, MAXFLOAT)].height;
}

- (CGFloat)contentHeight {
    
    if (!IS_IOS6) {
        NSDictionary *attributes = self.font ? @{NSFontAttributeName: self.font} : nil;
        CGRect rect = [self.text boundingRectWithSize:CGSizeMake(self.width - 10.0f, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        // 向上取整.防止文字被截断
        return ceilf(CGRectGetHeight(rect) + 16.0f);
    }
    
    return self.contentSize.height;
    
}

- (CGFloat)attributedTextContentHeight {
    CGRect rect = [self.attributedText boundingRectWithSize:CGSizeMake(self.width - 10.0f, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil];
    // 向上取整.防止文字被截断
    return ceilf(CGRectGetHeight(rect) + 16.0f);
}

@end
