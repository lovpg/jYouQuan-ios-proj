//
//  LLSupplyProfileService.h
//  Olla
//
//  Created by null on 14-11-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLMeDAO.h"
#import "Singleton.h"
@interface LLSupplyProfileService : NSObject{
    LLMeDAO *meDAO;
}

@property(nonatomic,assign) BOOL needSupply;

AS_SINGLETON(LLSupplyProfileService, sharedService);

@end
