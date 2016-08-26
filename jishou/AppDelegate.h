//
//  AppDelegate.h
//  leshi
//
//  Created by Reco on 16/6/30.
//  Copyright © 2016年 广州市乐施信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LLIMContext.h"
#import "LLShell.h"

@interface AppDelegate : LLShell
{
    
}
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong) LLIMContext *messageManager;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)messageManagerStart;
- (void)messageManagerStop;


@property float autoSizeScaleX;
@property float autoSizeScaleY;


+ (void)storyBoradAutoLay:(UIView *)allView;
+ (CGRect)getFrame : (CGRect) orign;
- (void)logout;

@end

