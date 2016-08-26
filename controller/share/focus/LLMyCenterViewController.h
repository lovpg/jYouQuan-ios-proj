//
//  LLMyCenterViewController.h
//  Olla
//
//  Created by nonstriater on 14-6-22.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLCoreViewController.h"
#import "LLMyFriendsZoneDataController.h"
//#import "LLAudioPlayAnimationButton.h"
#import "LLUser.h"

@interface LLMyCenterViewController : LLBaseViewController<OllaTableDataControllerDelegate>{
//    
//    IBOutlet LLAudioPlayAnimationButton *audioButton;
    
}

@property(nonatomic,strong) IBOutlet LLMyFriendsZoneDataController *tableController;
@property(nonatomic,strong) LLUser *user;

@property (nonatomic, strong) IBOutlet UIButton *crownButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton2;

- (IBAction)doComment:(id)sender;
- (IBAction)replaceCover:(id)sender;
- (IBAction)doRecord:(id)sender;
- (IBAction)playRecord:(id)sender;
- (IBAction)crown:(id)sender;

@end
