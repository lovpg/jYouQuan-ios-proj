//
//  OllaViewController.h
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBaseUIViewController.h"

@interface LLCoreViewController : UIViewController<IBaseUIViewController>

@property(nonatomic,strong) IBOutlet OllaDataBindContainer *dataBindContainer;
@property(nonatomic, strong) IBOutletCollection(id) NSArray *controllers;

- (IBAction)doAction:(id)sender;

- (void)applyDataBinding;

//just for test
-(BOOL)openURL:(NSURL *)url animated:(BOOL)animation;

@end
