//
//  LLShareDataController.h
//  Olla
//
//  Created by nonstriater on 14-7-17.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaImageLimitGridView.h"
#import "LLShareBaseDataController.h"


// 主要用来做好相对布局，以后这个问题解决，就可以不用这个自定义view了
@interface LLShareTableViewCell : OllaTableViewCell{
    
    IBOutlet UIButton *shareBgImageView;
    IBOutlet UIImageView *shareBgTureImageView;
    
    IBOutlet TTTAttributedLabel *shareTextLabel;
    IBOutlet OllaImageLimitGridView *imageGroupView;
    IBOutlet UIView *interactiveView;
    
    IBOutlet UIView *locationView;
    IBOutlet UILabel *locationLabel;
    
    //相对布局
    IBOutlet UILabel *nicknameLabel;
    IBOutlet UIImageView *genderImageView;
    IBOutlet UIImageView *countryImageView;
    
    IBOutlet UIButton *groupBarButton;
    IBOutlet UILabel *timeLabel;
    
    //要设置选中背景的拉升图片
    IBOutlet OllaButton *likeButton;
    IBOutlet UIImageView *likeImageView;
    IBOutlet UILabel *likeNumLabel;
    IBOutlet UIButton *commentButton;
    IBOutlet UILabel *commentLabel;
    IBOutlet UIButton *reportButton;
    
}

@property(nonatomic,assign) BOOL displayLocation;
@property(nonatomic,assign) BOOL needSelectionBackgroundImage;
@property(nonatomic,assign) BOOL showAllContent;


- (void)decreaseLikeNum;
- (void)increaseLikeNum;
- (void)increaseCommentNum;

- (IBAction)groupBarButtonClick:(id)sender;

@end



@interface LLShareDataController : LLShareBaseDataController

@property(nonatomic,assign) BOOL displayLocation;//
@property(nonatomic,assign) BOOL showAllContent;

- (CGFloat)cellHeightForDataItem:(id)dataItem;

- (LLShareTableViewCell *)cellWithShareId:(NSString *)shareId;



@end








