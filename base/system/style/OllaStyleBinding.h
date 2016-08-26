//
//  OllaStyleBinding.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-2.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OllaStyleBinding : NSObject

@property(nonatomic,strong) NSString *styleName;
@property(nonatomic,strong) IBOutletCollection(UIView) NSArray* views;

- (void)applyStyle;

@end
