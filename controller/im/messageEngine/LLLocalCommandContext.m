//
//  LLLocalCommandContext.m
//  Olla
//
//  Created by null on 14-9-28.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "LLLocalCommandContext.h"
#import "LLAppHelper.h"

@implementation LLLocalCommandContext

- (void)onReciveCommand:(NSString *)command option:(NSString *)option{

    if ([command isEqualToString:@"evn"]) {
        
        if ([option isEqualToString:@"test"]) {
            
            [UIAlertView showWithTitle:nil message:@"r u sure to convert to \"test evn\",this will result in logout! " cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Sure"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
                
                if (tapIndex ==1) {
                    [LLAppHelper resetHTTPSTestEnv];
                }
                
            }];
            
        }else if([option isEqualToString:@"prod"]){
        
            [UIAlertView showWithTitle:nil message:@"r u sure to convert to \"prod evn\",this will result in logout!" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Sure"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
                
                if (tapIndex ==1) {
                    [LLAppHelper resetHTTPSProdEnv];
                }
                
            }];
            
        }else if([option isEqualToString:@"http"]){
            
            [UIAlertView showWithTitle:nil message:@"r u sure to convert to \"http evn\"" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Sure"] tapBlock:^(UIAlertView *alertView,NSInteger tapIndex){
            
                if (tapIndex ==1) {
                    [LLAppHelper resetHTTPEnv];
                }
                
            }];
            
        }else{
            DDLogInfo(@"unknown options:%@ %@",command ,option);
        }
        
        
    }else if([command isEqualToString:@"upload"]){
    
    
    }

}


@end
