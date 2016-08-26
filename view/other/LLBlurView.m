//
//  LLBlurView.m
//  Olla
//
//  Created by null on 14-10-29.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBlurView.h"

@interface LLBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation LLBlurView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInitial];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitial];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitial];
    }
    return self;
}


- (void)commonInitial {
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
    
    if (![self toolbar]) {
        [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
        [self.toolbar setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self insertSubview:[self toolbar] atIndex:0];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_toolbar]|"
                                                                     options:0
                                                                     metrics:0
                                                                       views:NSDictionaryOfVariableBindings(_toolbar)]];
    }
}


- (void) setBlurTintColor:(UIColor *)blurTintColor {
    [self.toolbar setBarTintColor:blurTintColor];
}


@end
