//
//  OllaController.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaController.h"

@implementation OllaController

@synthesize context = _context;
@synthesize delegate = _delegate;

-(void)viewLoaded{

}

- (void)dealloc{
    
    self.delegate = nil;
    NSLog(@"Dealloc:%@",self);
}

@end
