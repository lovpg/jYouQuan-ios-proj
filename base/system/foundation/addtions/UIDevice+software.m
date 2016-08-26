//
//  UIDevice+software.m
//  FuShuo
//
//  Created by nonstriater on 14-2-8.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "UIDevice+software.h"

@implementation UIDevice (software)

+ (BOOL)isJailBreak{
    
    const char* jailbreak_apps[] =
    {
        "/Applications/Cydia.app",
        "/Applications/blackra1n.app",
        "/Applications/blacksn0w.app",
        "/Applications/greenpois0n.app",
        "/Applications/limera1n.app",
        "/Applications/redsn0w.app",
        NULL,
    };
    
    for (int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString
                                                              stringWithUTF8String:jailbreak_apps[i]]])
        {
            return YES;
        }
    }
    
    return NO;

}



@end
