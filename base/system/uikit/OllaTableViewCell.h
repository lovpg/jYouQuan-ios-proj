//
//  OllaTableViewCell.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-2.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OllaDataBindContainer.h"

@interface OllaTableViewCell : UITableViewCell

@property(nonatomic,strong) IBOutlet OllaDataBindContainer *dataBindContainer;
@property(nonatomic,strong) id dataItem;
@property(nonatomic,weak) IBOutlet id delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier nibName:(NSString *)nibName;


- (IBAction)doAction:(id)sender;
- (IBAction)doAction:(id)sender event:(UIEvent *)event;


@end


@protocol OllaTableViewCellDelegate
@optional
- (void)tableViewCell:(OllaTableViewCell *)cell doAction:(id)sender event:(UIEvent *)event;
@end

