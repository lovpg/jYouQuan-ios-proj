 //
//  OllaShell.m
//  OllaFramework
//
//  Created by nonstriater on 14-6-19.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLBaseShell.h"
#import "IOllaService.h"
#import "IBaseUIViewController.h"
#import "system.h"

//  OllaServiceContainer ///////////////////////////////////////////

@protocol IOllaServiceContainer <NSObject>

@property(nonatomic, strong, readonly) id instance;
@property(nonatomic, strong) id config;
@property(nonatomic, strong) id<IOllaServiceContext>context;

-(BOOL) hasTaskType:(Protocol *) taskType;

-(void) addTaskType:(Protocol *) taskType;


@end

@interface OllaServiceContainer : NSObject<IOllaServiceContainer>{
    
    NSMutableSet *_taskTypes;
    Class _instanceClass;
}



- (id)initWithInstanceClass:(Class)instanceClass;


@end

@implementation OllaServiceContainer

@synthesize instance = _instance;
@synthesize config = _config;
@synthesize context = _context;


- (id)initWithInstanceClass:(Class)instanceClass{
    if (self=[super init]) {
        _instanceClass = instanceClass;
    }
    return self;
}

- (id)instance{
    if (!_instance)
    {
        _instance = [[_instanceClass alloc] init];
        [_instance setContext:(id)_context];
        [_instance setConfig:_config];
    }
    
    return _instance;
}

-(BOOL) hasTaskType:(Protocol *) taskType{

    for (NSValue *tt in _taskTypes) {
        Protocol *p = (Protocol *)[tt pointerValue];
        if (p == taskType || protocol_conformsToProtocol( taskType, p)) {
            return YES;
        }
        
    }
    return NO;
}

-(void) addTaskType:(Protocol *) taskType{

    if (!_taskTypes) {
        _taskTypes = [[NSMutableSet alloc] init];
    }
    [_taskTypes addObject:[NSValue valueWithPointer:(__bridge const void *)(taskType)]];
}


@end


//  OllaShell ///////////////////////////////////////////

@interface LLBaseShell ()
{

    id _rootViewController;
    NSMutableArray *_viewControllers;
    NSMutableArray *_serviceContainers;
    NSBundle *_bundle;
}


@property(nonatomic,strong) NSMutableArray *platformKeys;

@end

#define UIPlatform_iPhone5_iOS7   @"iPhone5_iOS7"
#define UIPlatform_iPhone_iOS7    @"iPhone_iOS7"
#define UIPlatform_iPad_iOS7      @"iPad_iOS7"
#define UIPlatform_iPhone5        @"iPhone5"
#define UIPlatform_iPhone         @"iPhone"
#define UIPlatform_iPad           @"iPad"

#define UIPlatform_iOS6           @"iOS6"


@implementation LLBaseShell

@synthesize currentViewController=_currentViewController;
@synthesize uid=_uid;
@synthesize token = _token;
@synthesize sessionID = _sessionID;
@synthesize username = _username;


@synthesize config = _config;


- (id)initWithConfig:(id)config bundle:(NSBundle *)bundle{

    if (self = [super init]) {
        _config = config;
        _bundle = bundle;
        
        if (!_bundle) {
            _bundle = [NSBundle mainBundle];
        }
        
        NSArray *items = [config valueForKey:@"services"];
        if ([items isKindOfClass:[NSArray class]]) {
            
            for (id serviceItem in items) {
                
                if (![serviceItem isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                
                NSString *serviceClass = [serviceItem valueForKey:@"class"];
                if (!serviceClass || ![serviceClass isKindOfClass:[NSString class]]) {
                    continue;
                }
                Class class = NSClassFromString(serviceClass);
                if (!class && ![class conformsToProtocol:@protocol(IOllaService)]) {
                    continue;
                }
                
                
                OllaServiceContainer *container = [[OllaServiceContainer alloc] initWithInstanceClass:class];
                [container setContext:self];
                [container setConfig:serviceItem];
                
                NSArray *taskTypes = [serviceItem valueForKey:@"taskTypes"];
                if ([taskTypes isKindOfClass:[NSArray class]]) {
                    for (NSString *taskType in taskTypes) {
                        Protocol *taskProtocol = NSProtocolFromString(taskType);
                        if (taskProtocol) {
                            [container addTaskType:taskProtocol];
                        }
                    }
                }
                
                // 表示开机即要启动的服务，配置instance为YES
                if ([serviceItem booleanValueForKey:@"instance"]) {
                    [container instance];
                }
                
                if (!_serviceContainers) {
                    _serviceContainers = [[NSMutableArray alloc] init];
                }
                [_serviceContainers addObject:container];
                
            }
        }
        
    }
    
    return self;
}

//  eg: url  ===>  root:///root/tab  or  nav:///root/main
- (id)rootViewController{

    return [self rootViewControllerWithURLKey:@"url"];
}


- (id)rootViewControllerWithURLKey:(NSString *)key{

    NSString *url = [self.config valueForKey:key];
    if (url)
    {
        _rootViewController = [self getViewController:[NSURL URLWithString:url] basePath:@"/"];
        [_rootViewController loadURL:[NSURL URLWithString:url] basePath:@"/" animated:NO];
    }
    
//    if (!_rootViewController) {
//        NSString *url=[self.config valueForKey:key];
//        if (url) {
//            _rootViewController = [self getViewController:[NSURL URLWithString:url] basePath:@"/"];
//            [_rootViewController loadURL:[NSURL URLWithString:url] basePath:@"/" animated:NO];
//        }
//    }
    
    return _rootViewController;

}


// eg: ui ==> array()
- (id)getViewController:(NSURL *)url basePath:(NSString *)basePath{

    NSString *path = [url firstPathComponentRelativeTo:basePath];
    id config = [[self.config valueForKey:@"ui"] valueForKey:path];
    if (config) {
        
        
        id platform = nil;
        for (NSString *key in self.platformKeys) {
            platform = [config valueForKey:key];
            if (platform) {
                break;
            }
        }
        
        if (!platform) {//使用iOS7 UI
            platform = config;
        }
        
        
        id<IBaseUIViewController> viewController = nil;
        NSString *className = [platform valueForKey:@"class"];
        if (className)
        {
            Class clazz = NSClassFromString(className);
            if ([clazz conformsToProtocol:@protocol(IBaseUIViewController)]) {
                NSString *nibName = [platform objectForKey:@"nib"];
                if (nibName && [clazz isSubclassOfClass:[UIViewController class]]) {
                    viewController = [[clazz alloc] initWithNibName:nibName bundle:nil];
                } else if(!nibName){
                    viewController = [[clazz alloc] init];
                }
            }
        }
        
        if (viewController) {
            viewController.context = self;
            // 在url后面加一个"/",这样在使用openurl的时候，可以正常使用 urlString:relativetourl:self.url
            // 这样，返回上一级必须是"..",而不能是“.”;这是一个坑！！
//            if (![[url absoluteString] hasSuffix:@"/"]) {
//                viewController.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/",[url absoluteString]]];
//            }else{
//                viewController.url = url;
//            }
            viewController.url= url;
            viewController.alias = path;
            viewController.scheme = [url scheme];// navigation导航
            viewController.config = config;
        }
        
        return viewController;
    }
    
    return nil;
}


- (NSMutableArray *)platformKeys{
    
    if (!_platformKeys) {
        
        _platformKeys = [NSMutableArray array];
        UIDevice *device = [UIDevice currentDevice];
        double systemVersion = [[device systemVersion] doubleValue];
        if ([device userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (systemVersion<7.0) {
                [_platformKeys addObject:UIPlatform_iOS6];
            }

        }else{//ipad
            
        }
        
        
    }
    
    return _platformKeys;
}




-(BOOL)handle:(Protocol *)taskType task:(id<IOllaTask>)task priority:(NSInteger)priority{

    for(id container in _serviceContainers){
        if([container hasTaskType:taskType]){
            id service = [container instance];
            if([service handle:taskType task:task priority:priority]){
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)cancelHandle:(Protocol *)taskType task:(id<IOllaTask>)task{

    for (id container in _serviceContainers) {
        if ([container hasTaskType:taskType]) {
            id service = [container instance];
            if ([service cancelHandle:taskType task:task]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)cancelHandleForSource:(id)source{

    for (id container in _serviceContainers) {
        id service = [container instance];
        if ([service cancelHandleForSource:source]) {
            return YES;
        }
    }
    return NO;
}



@end
