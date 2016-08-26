//
//  LLIMClientLogin.m
//  Olla
//
//  Created by null on 14-9-7.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLIMClientLogin.h"
#import "OllaLocationManager.h"

@interface LLIMClientLogin (){
    
    OllaLocationManager *locationManager;
    int loginCount;
    NSThread *loginThread;
}

@property(nonatomic,strong) NSString *location;

@end


@implementation LLIMClientLogin

// 重写
- (void)onRead:(NSString *)cmd status:(NSString *)status message:(NSDictionary *)message{
    [super onRead:cmd status:status message:message];
    
    if ([cmd isEqualToString:@"login"]) {
        [self loginWithStatus:status message:message];
    }else if([cmd isEqualToString:@"logout"]){
        self.sessionID = 0;
        [self onLogout];
    }
}


- (void)loginWithStatus:(NSString *)status message:(NSDictionary *)message{

    if ([status isEqualToString:@"LoginExistException"]) {
        return;
    }
    
    if ([status isEqualToString:@"200"]) {
        
        NSString *uid = [message[@"uid"] stringValue];
        if (![uid isEqualToString:self.uid]) {
            DDLogError(@"登陆返回的UID怎么不一致");
            [self onLoginError:[NSError errorWithDomain:@"com.olla.im.login" code:0 userInfo:@{@"message":@"登陆返回的UID怎么不一致"}]];
            return;
        }
        self.sessionID = [uid doubleValue];
        [self onLoginSuccess];
        
    }else if([status isEqualToString:@"WrongPasswordException"]||
             [status isEqualToString:@"UserNotFoundException"]||
             [status isEqualToString:@"DisableLoginException"]){
    
        DDLogError(@"IM登录异常:%@",message);
//        [(LLAppDelegate *)[[UIApplication sharedApplication] delegate] logout];

    }else{
        
        DDLogError(@"login error:%@",message);
        self.sessionID = -1;
        NSError *error = [NSError errorWithDomain:@"com.olla.im.login" code:0 userInfo:@{@"message":message[@"message"]}];
        [self onLoginError:error];
    }

}

// 重写，开始login
- (void)onConnect{
    [super onConnect];
    
    loginCount = 0;
    
    if ([self.location length]==0) {
        if (!locationManager) {
            locationManager = [[OllaLocationManager alloc] init];
        }
        [locationManager startLocationCompleteBlock:^(NSString *location,NSError *error){
            if (error) {
                DDLogError(@"im login时获取地理位置失败：%@",error);
            }
            self.location = location;
//            DDLogInfo(@"im login 时获取的地理位置信息是：%@ (这里会不会调用多次,导致-login多次触发)",self.location);
            [self startLogin];
        }];

    }else{
        [self startLogin];//这样没法控制该线程的停止！,对于循环运行的任务，必须要控制其销毁
    }
}


- (void)startLogin{

    if (loginThread) {
        [loginThread cancel];
        loginThread = nil;
    }
    
    loginThread = [[NSThread alloc] initWithTarget:self selector:@selector(startLoginInternal) object:nil];
    [loginThread start];
    
}

//超时会导致
- (void)startLoginInternal{
    loginCount++;
    while(loginThread &&
          ![loginThread isCancelled] &&
          (self.sessionID<=0) &&
          ![self login]){
        DDLogError(@"%@ 登录出错或超时，重新登录%d",self,++loginCount);
        sleep(1);
    }
    
    DDLogInfo(@"登录线程取消，或登录成功就会到这里");
}


- (BOOL)login{
    
    NSString *jLocation = [@{@"location":([self.location length]==0)?@"":self.location} JSONString];
    NSString *loginMessage = [NSString stringWithFormat:@"login %@ %@ %@\n",self.uid,self.password,jLocation];
    [super writeln:loginMessage];
    
    for (int i=0; i<500; i++) {
        if (self.sessionID>0) {
            return YES;
        }else if(self.sessionID == 0){// 隔20ms检查一次
            usleep(20000);
        }else if(self.sessionID <0){// 登录出错，会自动relogin
            return NO;
        }
    }
    
    return NO;//超时
}


- (BOOL)checkLogined{
    return (self.sessionID>0);
}


- (void)onLoginSuccess{
    
    DDLogWarn(@"login success, sessionID = %ld",self.sessionID);
}

- (void)onLoginError:(NSError *)error{
    DDLogError(@"login error:%@ session=%ld",error,self.sessionID);
}


// 登出 ///////////////////////////////////////
// 重写连接断开
- (void)onDisconnect{
    [super onDisconnect];
    
    self.sessionID = 0;
    [self onLogout];
}

- (void)logout{
    NSString *message = [NSString stringWithFormat:@"logout"];
    [self writeln:message];
}

- (void)onLogout{
    DDLogWarn(@"logout");
}

// 主动stop时
- (void)stop{
    [super stop];
    
    self.uid = nil;
    self.password = nil;
    self.sessionID  = 0;
    if (loginThread) {
        [loginThread cancel];
        loginThread = nil;
        
        DDLogInfo(@"主动断开连接，登录线程取消");
    }
}

- (void)dealloc{

    [self stop];
}


@end



