//
//  LLShell.h
//  Olla
//
//  Created by nonstriater on 14-6-23.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "IChatManagerDelegate.h"
#import "LLSignupService.h"
#import "LLLoginService.h"
#import "LLUserService.h"
#import "LLLoginAuth.h"

@interface LLShell : OllaShell<UIApplicationDelegate, IChatManagerDelegate>
{
    EMConnectionState _connectionState;
    LLSignupService *signupService;
    LLLoginService *loginService;
    LLUserService *userService;
}


@property(nonatomic, strong) IBOutlet UIWindow *window;
@property (strong, nonatomic) NSDictionary *refererAppLink;
@property(nonatomic,strong) LLUser *userInfo;
@property(nonatomic,strong) LLLoginAuth *userAuth;

- (void)sendDeviceToken:(NSString *)token;

@end
