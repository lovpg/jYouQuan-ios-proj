//
//  LLShareCommentCell.m
//  Olla
//
//  Created by Pat on 15/5/29.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLShareCommentCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
//#import "LLCommentAudioPlayAnimationButton.h"

@interface LLShareCommentCell () <TTTAttributedLabelDelegate> {
//    LLCommentAudioPlayAnimationButton *audioButton;
}

@end

@implementation LLShareCommentCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
//    audioButton = [[LLCommentAudioPlayAnimationButton alloc] init];
    
    self.messageLabel.delegate = self;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.linkAttributes = @{(id)kCTForegroundColorAttributeName:[UIColor blueColor], NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleNone]};
    self.messageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    self.avatorButton.cornerRadius = 14;
    self.imageButton.cornerRadius = 6;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"LLShareCommentCell" owner:self options:@{}];
    self = nibObjects[0];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (NSString *)reuseIdentifier {
    return @"LLShareComment";
}

#pragma mark - Long press to delete comment
- (IBAction)longPressToDeleteComment:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        // 判断是否吧主  ||  判断是否comment的主人
        if (([self.dataItem.user.uid isEqualToString:[[[LLUserService alloc] init] getMe].uid])) {
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyText)];
            UIMenuItem *translateItem = [[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(translate)];
            UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteComment)];
            menuController.menuItems = @[copyItem, translateItem, deleteItem];
        } else {
            UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyText)];
            UIMenuItem *translateItem = [[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(translate)];
            menuController.menuItems = @[copyItem, translateItem];
        }
        [self becomeFirstResponder];
        [menuController setTargetRect:self.bounds inView:self];
        [menuController setMenuVisible:YES animated:YES];
    }
    
    
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyText)) {
        return YES;
    } else if (action == @selector(translate)) {
        return YES;
    } else if (action == @selector(deleteComment)) {
        return YES;
    }
    return NO;
}

- (void)copyText {
    [[UIPasteboard generalPasteboard] setString:self.dataItem.content];
    [[UIApplication sharedApplication].keyWindow.rootViewController showHint:@"Copy to pasteboard"];
    [UIMenuController sharedMenuController].menuItems = nil;
}

- (void)translate {
//    [self routerEventWithName:LLGroupBarPostTranslateClickEvent
//                     userInfo:@{@"post":self.dataItem}];
}


- (void)deleteComment {
    
    [self.delegate deleteComment:self.dataItem.commentId];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString hasPrefix:@"@"]) {
        return;
    }
//    [self routerEventWithName:LLShareTextURLClickEvent userInfo:@{@"url":url}];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
//    [self routerEventWithName:LLShareTextPhoneNumberClickEvent userInfo:@{@"phoneNumber":phoneNumber}];
}


- (void)setDataItem:(LLComment *)dataItem {
    _dataItem = dataItem;
   
    LLSimpleUser *user = dataItem.user;
    
    NSURL *url = [NSURL URLWithString:[LLAppHelper shareThumbImageURLWithString:dataItem.user.avatar]];
    [self.avatorButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
    
    self.nameLabel.text = user.nickname;
    self.genderView.gender = user.gender;
    self.countryView.region = user.region;
    
    CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(999, 20)];
    
    self.nameLabel.width = MIN(nameSize.width, 95.0f);
    
    self.genderView.left = self.nameLabel.right + 10;
    self.countryView.left = self.genderView.right + 10;
    
    self.timeLabel.timestamp = dataItem.posttime;
    
    NSString *textContent = dataItem.content;
    self.messageLabel.text = textContent;
    if (dataItem.objUsername.length > 0)
    {
        NSString *link = [NSString stringWithFormat:@"回复 %@", dataItem.objUsername];
        NSRange range = [textContent rangeOfString:link];
        [self.messageLabel addLinkToURL:[NSURL URLWithString:link] withRange:range];
    }
    
    if ([textContent isArabic]) {
        self.messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(210, 99999)];
    self.messageLabel.frame = CGRectMake(68, 38, 210, size.height + 8);
    
    // 显示@名字的颜色
    NSArray *contentWords = [dataItem.content componentsSeparatedByString:@" "];
    NSMutableArray *contentWordsNeedBlue = [[NSMutableArray alloc] init];
    // NSRange range = [searchText rangeOfString:@"(?:[^,])*\\." options:NSRegularExpressionSearch];
    [contentWordsNeedBlue removeAllObjects];
    for (NSString *word in contentWords)
    {
        if ([word hasPrefix:@"@"])
        {
            NSMutableDictionary *content = [NSMutableDictionary dictionary];
            content[@"name"] = word;
            NSRange range = [dataItem.content rangeOfString:word options:NSRegularExpressionSearch];
            content[@"location"] = @(range.location);
            content[@"length"] = @(range.length);
            [contentWordsNeedBlue addObject:content];
        }
    }
    
    NSMutableAttributedString *contentStr = [[NSMutableAttributedString alloc] initWithString:self.messageLabel.text];
    [contentStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.f] range:NSMakeRange(0, contentStr.length)];
    for (NSDictionary *strRangeDic in contentWordsNeedBlue)
    {
        [contentStr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange([[strRangeDic objectForKey:@"location"] integerValue], [[strRangeDic objectForKey:@"length"] integerValue])];
    }
    
    self.messageLabel.attributedText = contentStr;

    CGFloat start = 38.f;
    CGFloat bottomPadding = 12.f;
    CGFloat textHeight = textContent.trim.length > 0 ? size.height : 0;
    CGFloat height = textHeight+start+bottomPadding;
    
    if (dataItem.imageList.count > 0) {
        height += 60;
    }
    
    if (dataItem.imageList.count > 0) {
        self.imageButton.hidden = NO;
        if ([dataItem.imageList.firstObject isKindOfClass:[UIImage class]]) {
            UIImage *image = dataItem.imageList.firstObject;
            [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            NSString *urlString = [LLAppHelper shareThumbImageURLWithString:dataItem.imageList.firstObject];
            NSURL *imageURL = [NSURL URLWithString:urlString];
            [self.imageButton sd_setBackgroundImageWithURL:imageURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"headphoto_default"]];
        }
        self.imageButton.frame = CGRectMake(68, height - 60, 50, 50);
    } else {
        self.imageButton.hidden = YES;
    }
    
    // 如果包含语音
    if (dataItem.voice.length) {
        
        height += 30;
        
//        if ([audioButton.audioPlayer isPlaying]) {
//            [audioButton stop];
//            return;
//        }
        
//        audioButton.audioPath = dataItem.voice;
//        audioButton.frame = CGRectMake(68, 38, 100, 32);
//        [audioButton setImage:[UIImage imageNamed:@"record_bar"] forState:UIControlStateNormal];
//        [audioButton addTarget:self action:@selector(playRecord:) forControlEvents:UIControlEventTouchUpInside];
//        audioButton.borderColor = [UIColor whiteColor];
//        audioButton.borderWidth = 1.f;
       // [self addSubview:audioButton];
//        NSLog(@"comment voice:%@", audioButton.audioPath);
//        [audioButton play];
        
        self.voiceTimeLabel.hidden = NO;
        self.voiceTimeLabel.text = [NSString stringWithFormat:@"\"%@", dataItem.vlen];
       // self.voiceTimeLabel.originX = CGRectGetMaxX(audioButton.frame) + 5;
      //  self.voiceTimeLabel.originY = CGRectGetMaxY(audioButton.frame) - self.voiceTimeLabel.height;
    } else {
      //  [audioButton removeFromSuperview];
        self.voiceTimeLabel.hidden = YES;
    }
    
}

//- (void)playRecord:(LLCommentAudioPlayAnimationButton *)sender {
//
//    if ([audioButton.audioPlayer isPlaying]) {
//        [audioButton stop];
//        return ;
//    }
//    
//    [self routerEventWithName:@"LLCommentAudioPlayAnimationButtonClickEvent" userInfo:@{@"sender":sender}];
//    [audioButton play];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundButton.frame = CGRectMake(5, 0, self.width - 10, self.height);
    self.backgroundButton2.frame = self.bounds;
    self.timeLabel.right = self.width - 10;
    [self.backgroundButton setNeedsDisplay];
}

- (IBAction)avatorClick:(id)sender
{
    [self routerEventWithName:LLShareCommentAvatorClickEvent userInfo:@{@"user":self.dataItem.user}];
}

- (IBAction)imageButtonClick:(id)sender
{
    CGRect startRect = [self.contentView convertRect:self.imageButton.frame toView:[UIApplication sharedApplication].keyWindow];
    
    MJPhotoBrowser *photoBrowser = [[MJPhotoBrowser alloc] init];
    MJPhoto *photo = [[MJPhoto alloc] init];
    
    if ([self.dataItem.imageList.firstObject isKindOfClass:[UIImage class]]) {
        UIImage *image = self.dataItem.imageList.firstObject;
        photo.placeholder = image;
        photo.image = image;
    } else {
        NSURL *imageURL = [NSURL URLWithString:self.dataItem.imageList.firstObject];
        photo.url = imageURL;
    }
    
    photo.index = 0;
    photo.startFrame = startRect;
    photoBrowser.photos = @[photo];
    [photoBrowser show];
}

- (IBAction)backgroundButtonClick:(id)sender
{
    [self routerEventWithName:LLShareCommentBackgroundClickEvent userInfo:@{@"user":self.dataItem.user}];
}

@end
