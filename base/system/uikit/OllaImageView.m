//
//  OllaImageView.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-3.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaImageView.h"
#import "UIImageView+CacheURL.h"

@implementation OllaImageView

@synthesize src = _src;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver:self forKeyPath:@"src" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
         [self addObserver:self forKeyPath:@"src" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"src"]) {
       // [self setImageURL:[NSURL URLWithString:keyPath]];
    }

}


- (void)dealloc{

    [self removeObserver:self forKeyPath:@"src"];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
