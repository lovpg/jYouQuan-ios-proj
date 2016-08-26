//
//  EMMessage+Helper.h
//  Olla
//
//  Created by Pat on 15/7/9.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "EMMessage.h"
#import "EMMessageExtObject.h"

typedef enum : NSUInteger {
    EMMessageExtTypeNone,
    EMMessageExtTypeGroupBar,
    EMMessageExtTypeGroupBarPost,
    EMMessageExtTypePersonalShare,
    EMMessageExtTypeQuickTutor,       // 发起
    EMMessageExtTypeQuickTutorRespond, // 响应
    EMMessageExtTypePushGood,
    EMMessageExtTypePushComment
} EMMessageExtType;

@interface EMMessage (Helper)

// 自定义扩展对象
@property (nonatomic, strong) EMMessageExtObject *extObject;

- (EMMessageExtType)extType;

@end
