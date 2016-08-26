//
//  OllaButton.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-27.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBaseAction.h"

@interface OllaButton : UIButton<IBaseAction>

@property(nonatomic,assign) CGFloat expandMargin;//default 0;

@end
