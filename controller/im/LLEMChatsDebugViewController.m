//
//  LLEMChatsDebugViewController.m
//  Olla
//
//  Created by Pat on 15/4/8.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLEMChatsDebugViewController.h"

@implementation LLEMChatsDebugViewController

- (void)loadView {
    [super loadView];
    
    self.title = @"Debug";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"debug";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.textLabel.numberOfLines = 0;
        
    }
    
    cell.textLabel.frame = CGRectMake(0, 0, self.view.width, 64);
    
    NSMutableString *string = [NSMutableString string];
    LLEMChatsItem *chatsItem = self.dataSource[indexPath.row];
    [string appendFormat:@"好友uid:%@\n",chatsItem.userInfo.uid];
    [string appendFormat:@"好友nickname:%@\n",chatsItem.userInfo.nickname];
    [string appendFormat:@"环信uid:%@",chatsItem.conversation.chatter];
    cell.textLabel.text = string;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84.0f;
}

@end
