//
//  OllaStyleContainer.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-2.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OllaStyleBinding.h"

@interface OllaStyleContainer : NSObject

@property(nonatomic,strong) IBOutletCollection(OllaStyleBinding) NSArray *styleBindings;

- (void)applyStyle;

@end
