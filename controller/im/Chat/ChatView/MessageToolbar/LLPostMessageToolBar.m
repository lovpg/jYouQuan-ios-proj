//
//  LLPostMessageToolBar.m
//  Olla
//
//  Created by Pat on 15/5/22.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLPostMessageToolBar.h"


@interface LLPostMessageToolBar()<UITextViewDelegate, DXFaceDelegate>
{
    CGFloat _previousTextViewContentHeight;//上一次inputTextView的contentSize.height
}

@property (nonatomic) CGFloat version;

/**
 *  背景
 */
@property (strong, nonatomic) UIImageView *toolbarBackgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;

/**
 *  按钮、输入框、toolbarView
 */
@property (nonatomic, strong) UIControl *backgroundControl;

@property (strong, nonatomic) UIView *toolbarView;
@property (strong, nonatomic) UIButton *styleChangeButton;
@property (strong, nonatomic) UIButton *faceButton;
@property (strong, nonatomic) UIButton *photoButton;

@property (strong, nonatomic) UIView *photoToolBar;
@property (strong, nonatomic) UIButton *photoView;
@property (strong, nonatomic) UIButton *photoSendView;

/**
 *  底部扩展页面
 */
@property (nonatomic) BOOL isShowButtomView;
@property (strong, nonatomic) UIView *activityButtomView;//当前活跃的底部扩展页面

// 用于持有删除照片按钮
@property (strong, nonatomic) UIButton *deleteImageButton;

@end

@implementation LLPostMessageToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupConfigure];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    [super setFrame:frame];
}

- (void)setSelectedPhoto:(UIImage *)selectedPhoto {
    _selectedPhoto = selectedPhoto;
    [self.photoView setImage:selectedPhoto forState:UIControlStateNormal];
    
    if (selectedPhoto) {
        self.photoToolBar.hidden = NO;
        
        UIButton *deleteImageButton = [[UIButton alloc] initWithFrame:CGRectMake(self.photoView.originX + self.photoView.width - 8, self.photoView.originY - 8, 16, 16)];
        self.deleteImageButton = deleteImageButton;
        [deleteImageButton setImage:[UIImage imageNamed:@"group_bar_member_delete_button"]];
        [deleteImageButton addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.photoToolBar addSubview:deleteImageButton];
        
    } else {
        self.photoToolBar.hidden = YES;
        
        if (self.deleteImageButton) {
            [self.deleteImageButton removeFromSuperview];
        }
    }
    [self setNeedsLayout];
}

- (void)removePhoto:(UIButton *)sender {

    NSLog(@"remove");
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupSubviews];
    }
    
    [super willMoveToSuperview:newSuperview];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

#pragma mark - getter

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _backgroundImageView;
}

- (UIImageView *)toolbarBackgroundImageView
{
    if (_toolbarBackgroundImageView == nil) {
        _toolbarBackgroundImageView = [[UIImageView alloc] init];
        _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
        _toolbarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _toolbarBackgroundImageView;
}

- (UIView *)toolbarView
{
    if (_toolbarView == nil) {
        _toolbarView = [[UIView alloc] init];
        _toolbarView.backgroundColor = [UIColor clearColor];
    }
    
    return _toolbarView;
}

#pragma mark - setter

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setToolbarBackgroundImage:(UIImage *)toolbarBackgroundImage
{
    _toolbarBackgroundImage = toolbarBackgroundImage;
    self.toolbarBackgroundImageView.image = toolbarBackgroundImage;
}

- (void)setMaxTextInputViewHeight:(CGFloat)maxTextInputViewHeight
{
    if (maxTextInputViewHeight > kInputTextViewMaxHeight) {
        maxTextInputViewHeight = kInputTextViewMaxHeight;
    }
    _maxTextInputViewHeight = maxTextInputViewHeight;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    self.faceButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    self.backgroundControl.hidden = NO;
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:textView.text];
            self.inputTextView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

#pragma mark - DXFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    NSString *chatText = self.inputTextView.text;
    
    if (!isDelete && str.length > 0) {
        self.inputTextView.text = [NSString stringWithFormat:@"%@%@",chatText,str];
    }
    else {
        if (chatText.length >= 2)
        {
            NSString *subStr = [chatText substringFromIndex:chatText.length-2];
            if ([(DXFaceView *)self.faceView stringIsFace:subStr]) {
                self.inputTextView.text = [chatText substringToIndex:chatText.length-2];
                [self textViewDidChange:self.inputTextView];
                return;
            }
        }
        
        if (chatText.length > 0) {
            self.inputTextView.text = [chatText substringToIndex:chatText.length-1];
        }
    }
    
    [self textViewDidChange:self.inputTextView];
}
- (void)sendFace
{
    NSString *chatText = self.inputTextView.text;
    if (chatText.length > 0) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:chatText];
            self.inputTextView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];;
        }
    }
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

#pragma mark - private

/**
 *  设置初始属性
 */
- (void)setupConfigure
{
    self.version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    self.maxTextInputViewHeight = kInputTextViewMaxHeight;
    
    self.activityButtomView = nil;
    self.isShowButtomView = NO;
    self.backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:self.backgroundImageView];
    
  //  self.toolbarView.frame = CGRectMake(0, 0, self.frame.size.width, kVerticalPadding * 2 + kInputTextViewMinHeight);
    self.toolbarView.frame = CGRectMake(0, 0, self.frame.size.width, kVerticalPadding * 2 + kInputTextViewMinHeight);
    self.toolbarBackgroundImageView.frame = self.toolbarView.bounds;
    [self.toolbarView addSubview:self.toolbarBackgroundImageView];
    [self addSubview:self.toolbarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setupSubviews
{
    CGFloat allButtonWidth = 0.0;
    CGFloat textViewLeftMargin = 6.0;
    
    //转变输入样式
    self.styleChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
    self.styleChangeButton.tag = 1;
    self.styleChangeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    [self.styleChangeButton setImage:[UIImage imageNamed:@"keyboard_voice_n"] forState:UIControlStateNormal];
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateNormal];
//    [self.styleChangeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    allButtonWidth += CGRectGetMaxX(self.styleChangeButton.frame);
    textViewLeftMargin += CGRectGetMaxX(self.styleChangeButton.frame);
    
    self.photoView = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, 44, 44)];
    self.photoView.cornerRadius = 6;
    [self.photoView addTarget:self action:@selector(photoTap:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.photoSendView = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 70, 2, 60, 44)];
    [self.photoSendView setTitle:@"分享" forState:UIControlStateNormal];
    [self.photoSendView setTitleColor:RGB_DECIMAL(0, 91, 255) forState:UIControlStateNormal];
    [self.photoSendView addTarget:self action:@selector(photoSend:) forControlEvents:UIControlEventTouchUpInside];
    
    self.photoToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, -48, self.width, 48)];
    self.photoToolBar.backgroundColor = RGB_DECIMAL(247, 247, 247);
    self.photoToolBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    self.photoToolBar.hidden = YES;
    self.photoToolBar.multipleTouchEnabled = YES;
    
    [self.photoToolBar addSubview:self.photoView];
    [self.photoToolBar addSubview:self.photoSendView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    line.backgroundColor = RGB_DECIMAL(207, 207, 207);
    [self.photoToolBar addSubview:line];
    
    // *****
    //转变输入样式 (kHorizontalPadding, kVerticalPadding+6, kInputTextViewMinHeight-12, kInputTextViewMinHeight-12)
//    self.photoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kInputTextViewMinHeight - kHorizontalPadding+6, kVerticalPadding, kInputTextViewMinHeight - 3, kInputTextViewMinHeight - 3)];
    self.photoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kInputTextViewMinHeight - kHorizontalPadding+4, kVerticalPadding + 6, kInputTextViewMinHeight - 12, kInputTextViewMinHeight - 12)];
    self.photoButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.photoButton setImage:[UIImage imageNamed:@"reply_with_pic_add"] forState:UIControlStateNormal];
    [self.photoButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.photoButton.tag = 0;
    allButtonWidth += (self.width - CGRectGetMinX(self.photoButton.frame));
//    textViewLeftMargin += CGRectGetMaxX(self.photoButton.frame);
    // *****
    
    //表情
    self.faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kInputTextViewMinHeight * 2 - kHorizontalPadding+4, kVerticalPadding + 6, kInputTextViewMinHeight - 12, kInputTextViewMinHeight - 12)];
    self.faceButton.centerY = self.photoButton.centerY;
    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_faceSelected"] forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.faceButton.tag = 1;
    allButtonWidth += (CGRectGetMinX(self.photoButton.frame) - CGRectGetMinX(self.faceButton.frame));
    
    
    // 输入框的高度和宽度
    float space = textViewLeftMargin - CGRectGetMaxX(self.styleChangeButton.frame);
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? (allButtonWidth + space + 12) : (textViewLeftMargin * 2));
    // 初始化输入框
    self.inputTextView = [[XHMessageTextView  alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    self.inputTextView.contentMode = UIViewContentModeCenter;
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.placeHolder = nil;
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];
    
    // *****
    //录制
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:kTouchToRecord forState:UIControlStateNormal];
    [self.recordButton setTitle:kTouchToFinish forState:UIControlStateHighlighted];
    self.recordButton.hidden = YES;
    [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
//    self.recordButton.hidden = YES;
    // *****
    
    if (!self.faceView) {
        self.faceView = [[DXFaceView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), self.frame.size.width, 200)];
        [(DXFaceView *)self.faceView setDelegate:self];
        self.faceView.backgroundColor = RGBACOLOR(247, 247, 247, 1);
        self.faceView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    // *****
    if (!self.recordView) {
        self.recordView = [[DXRecordView alloc] initWithFrame:CGRectMake(90, 130, 140, 140)];
    }
    // *****
    
    [self.toolbarView addSubview:self.styleChangeButton];
    [self.toolbarView addSubview:self.photoToolBar];
    [self.toolbarView addSubview:self.photoButton];
    [self.toolbarView addSubview:self.faceButton];
    [self.toolbarView addSubview:self.inputTextView];
    [self.toolbarView addSubview:self.recordButton];
}

- (void)setupBackgrondControl {
    if (self.superview && !self.backgroundControl) {
        _backgroundControl = [[UIControl alloc] initWithFrame:self.superview.bounds];
        [_backgroundControl addTarget:self action:@selector(backgroundClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.superview insertSubview:_backgroundControl belowSubview:self];
    }
}

- (void)backgroundClick:(id)sender {
    [self endEditing:YES];
}

- (void)photoTap:(id)sender {
    self.selectedPhoto = nil;
}

- (void)photoSend:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
        [self.delegate didSendText:self.inputTextView.text];
        self.inputTextView.text = @"";
        [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
    }
}

#pragma mark - change frame

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    }
    else{
        self.backgroundControl.hidden = NO;
        self.isShowButtomView = YES;
    }
    
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:toHeight];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        //一定要把self.activityButtomView置为空
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self willShowBottomHeight:0];
    }
    else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < kInputTextViewMinHeight) {
        toHeight = kInputTextViewMinHeight;
    }
    if (toHeight > self.maxTextInputViewHeight) {
        toHeight = self.maxTextInputViewHeight;
    }
    
    if (toHeight != _previousTextViewContentHeight)
    {
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        if (self.version < 7.0) {
            [self.inputTextView setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:YES];
        }
        _previousTextViewContentHeight = toHeight;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [self.delegate didChangeFrameToHeight:self.frame.size.height];
        }
    }
    
    if (toHeight < kInputTextViewMaxHeight) {
        CGPoint offset = CGPointMake(0, 0);
        [self.inputTextView setContentOffset:offset animated:NO];
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    if (self.version >= 7.0)
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

#pragma mark - action

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSInteger tag = button.tag;
    
    switch (tag) {
        case 0://切换状态
        {
            [self endEditing:YES];
            if ([self.delegate respondsToSelector:@selector(photoButtonClick)]) {
                [self.delegate photoButtonClick];
            }

        }
            break;
        case 1://表情
        {
            if (button.selected) {
                [self.inputTextView resignFirstResponder];
                [self willShowBottomView:self.faceView];
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recordButton.hidden = YES;
                    self.inputTextView.hidden = NO;
                } completion:^(BOOL finished) {
                    
                }];
                
                if (self.styleChangeButton.selected) {
                    self.recordButton.hidden = YES;
                    self.inputTextView.hidden = NO;
                    self.styleChangeButton.selected = NO;
                    
                    // 将按钮变回原状
                    self.styleChangeButton.originX -= 6;
                    self.styleChangeButton.originY -= 6;
                    // kInputTextViewMinHeight, kInputTextViewMinHeight
                    self.styleChangeButton.width = kInputTextViewMinHeight;
                    self.styleChangeButton.height = kInputTextViewMinHeight;
                }
                
            } else {
                [self willShowBottomView:nil];
                
            }
        }
            break;
        case 2:// 语音按钮事件
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                self.photoButton.selected = NO;
                //录音状态下，不显示底部扩展页面
                [self willShowBottomView:nil];
                
                //将inputTextView内容置空，以使toolbarView回到最小高度
                self.inputTextView.text = @"";
                [self textViewDidChange:self.inputTextView];
                [self.inputTextView resignFirstResponder];
                
                // 调整变成键盘icon时按钮的大小
//                CGPoint originPoint = CGPointMake(self.styleChangeButton.originX, self.styleChangeButton.originY);
                self.styleChangeButton.originX += 6;
                self.styleChangeButton.originY += 6;
                self.styleChangeButton.width = self.faceButton.width;
                self.styleChangeButton.height = self.faceButton.height;
                
            } else{
                //键盘也算一种底部扩展页面
                [self.inputTextView becomeFirstResponder];
                // 将按钮变回原状
                self.styleChangeButton.originX -= 6;
                self.styleChangeButton.originY -= 6;
                // kInputTextViewMinHeight, kInputTextViewMinHeight
                self.styleChangeButton.width = kInputTextViewMinHeight;
                self.styleChangeButton.height = kInputTextViewMinHeight;
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.recordButton.hidden = !button.selected;
                self.inputTextView.hidden = button.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didStyleChangeToRecord:)]) {
                [self.delegate didStyleChangeToRecord:button.selected];
            }
        }
            
        default:
            break;
    }
}

#pragma mark - record button click
- (void)recordButtonTouchDown
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchDown];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didStartRecordingVoiceAction:)]) {
        [_delegate didStartRecordingVoiceAction:self.recordView];
    }
}

- (void)recordButtonTouchUpOutside
{
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelRecordingVoiceAction:)])
    {
        [_delegate didCancelRecordingVoiceAction:self.recordView];
    }
    
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpOutside];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)recordButtonTouchUpInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonTouchUpInside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction:)])
    {
        [self.delegate didFinishRecoingVoiceAction:self.recordView];
    }
    
    [self.recordView removeFromSuperview];
}

- (void)recordDragOutside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragOutside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction:)])
    {
        [self.delegate didDragOutsideAction:self.recordView];
    }
}

- (void)recordDragInside
{
    if ([self.recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)self.recordView recordButtonDragInside];
    }
    
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction:)])
    {
        [self.delegate didDragInsideAction:self.recordView];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.selectedPhoto) {
        if (point.y >= -48) {
            CGPoint convertPoint = CGPointMake(point.x, point.y + 48);
            if (CGRectContainsPoint(self.photoView.frame, convertPoint)) {
                return self.photoView;
            }
            if (CGRectContainsPoint(self.photoSendView.frame, convertPoint)) {
                return self.photoSendView;
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (self.selectedPhoto) {
        if (point.y >= -48) {
            CGPoint convertPoint = CGPointMake(point.x, point.y + 48);
            if (CGRectContainsPoint(self.photoView.frame, convertPoint)) {
                return YES;
            }
            if (CGRectContainsPoint(self.photoSendView.frame, convertPoint)) {
                return YES;
            }
        }
    }
    
    return [super pointInside:point withEvent:event];
}

#pragma mark - public

/**
 *  停止编辑
 */
- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    self.backgroundControl.hidden = YES;
    self.faceButton.selected = NO;
    [self willShowBottomView:nil];
    
    return result;
}

+ (CGFloat)defaultHeight
{
    return kVerticalPadding * 2 + kInputTextViewMinHeight;
}

/**
 *  取消触摸录音键
 */
- (void)cancelTouchRecord
{
    //    self.recordButton.selected = NO;
    //    self.recordButton.highlighted = NO;
    if ([_recordView isKindOfClass:[DXRecordView class]]) {
        [(DXRecordView *)_recordView recordButtonTouchUpInside];
        [_recordView removeFromSuperview];
    }
}

@end
