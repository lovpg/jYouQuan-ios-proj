//
//  LLThirdCollection.h
//  iDleChat
//
//  Created by Reco on 16/3/27.
//  Copyright © 2016年 Reco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLThirdCollection : OllaModel<NSCoding>

@property(nonatomic,strong) NSString *tcid;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSString *images;
@property(nonatomic,strong) NSString *platform;

@end
