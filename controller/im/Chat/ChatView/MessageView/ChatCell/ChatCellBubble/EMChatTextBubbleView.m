/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <CoreText/CoreText.h>
#import "EMChatTextBubbleView.h"

NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";
NSString *const kRouterEventVoipTapEventName = @"kRouterEventVoipTapEventName";

@interface EMChatTextBubbleView ()
{
    NSDataDetector *_detector;
    NSArray *_urlMatches;
    UIImageView *_iconView;
}

@end

@implementation EMChatTextBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        [self addSubview:_textLabel];
        
        _iconView = [[UIImageView alloc] init];
        [self addSubview:_iconView];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.model.message.ext objectForKey:@"ollacall"]) {
        if (self.model.isSender) {
            _iconView.image = [UIImage imageNamed:@"olla_call_white"];
        } else {
            _iconView.image = [UIImage imageNamed:@"olla_call"];
        }
        _iconView.hidden = NO;
    } else {
        _iconView.hidden = YES;
    }
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_PADDING);
    if (self.model.isSender) {
        self.textLabel.textColor = [UIColor blackColor];
        frame.origin.x = BUBBLE_VIEW_PADDING;
    }else{
        self.textLabel.textColor = [UIColor blackColor];
        frame.origin.x = BUBBLE_VIEW_PADDING + BUBBLE_ARROW_WIDTH;
    }
    
    frame.origin.y = BUBBLE_VIEW_PADDING;
    [self.textLabel setFrame:frame];
    
    _iconView.frame = CGRectMake(frame.origin.x, frame.origin.y + 2, 18, 18);
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSString *content = self.model.content;
    
    if ([self.model.message.ext objectForKey:@"ollacall"]) {
        content = [NSString stringWithFormat:@"      %@", content];
    }
    
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
    CGSize retSize;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:[[self class] lineSpacing]];//调整行间距
        
        retSize = [content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{
                                                             NSFontAttributeName:[[self class] textLabelFont],
                                                             NSParagraphStyleAttributeName:paragraphStyle
                                                             }
                                                   context:nil].size;
    }else{
        retSize = [content sizeWithFont:[[self class] textLabelFont] constrainedToSize:textBlockMinSize lineBreakMode:[[self class] textLabelLineBreakModel]];
        retSize = CGSizeMake(retSize.width, retSize.height + 36);
    }
    
    CGFloat height = 40;
    if (2*BUBBLE_VIEW_PADDING + retSize.height > height) {
        height = 2*BUBBLE_VIEW_PADDING + retSize.height;
    }
    
    if (retSize.width < 20) {
        retSize.width = 20;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_PADDING*2 + BUBBLE_VIEW_PADDING, height);
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    NSString *content = self.model.content;
    
    if ([self.model.message.ext objectForKey:@"ollacall"]) {
        content = [NSString stringWithFormat:@"      %@", content];
    }
    
    
    _urlMatches = [_detector matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                    initWithString:content];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:[[self class] lineSpacing]];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [content length])];
    if ([content isArabic]) {
        paragraphStyle.alignment = NSTextAlignmentRight;
    } else {
        paragraphStyle.alignment = NSTextAlignmentLeft;
    }
    
    [_textLabel setAttributedText:attributedString];
    [self highlightLinksWithIndex:NSNotFound];
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_textLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _textLabel.attributedText = attributedString;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [self.textLabel.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.textLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.textLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.textLabel.font range:NSMakeRange(0, [self.textLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.textLabel.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.textLabel.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.textLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.textLabel.numberOfLines > 0 ? MIN(self.textLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

#pragma mark - public

-(void)bubbleViewPressed:(id)sender
{
    // VOIP CALL 信息特殊处理
    if ([self.model.message.ext objectForKey:@"ollacall"]) {
        [self routerEventWithName:kRouterEventVoipTapEventName userInfo:nil];
        return;
    }
    
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:_textLabel];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                
                [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{KMESSAGEKEY:self.model, @"url":match.URL}];
                break;
            }
        }
    }
}

+(CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
    CGSize size;
    static float systemVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    });
    if (systemVersion >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:[[self class] lineSpacing]];//调整行间距
        size = [object.content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{
                                                      NSFontAttributeName:[[self class] textLabelFont],
                                                      NSParagraphStyleAttributeName:paragraphStyle
                                                      }
                                            context:nil].size;
    }else{
        size = [object.content sizeWithFont:[self textLabelFont]
                          constrainedToSize:textBlockMinSize
                              lineBreakMode:[self textLabelLineBreakModel]];
        size = CGSizeMake(size.width, size.height + 36);
    }
    return 2 * BUBBLE_VIEW_PADDING + size.height + 5;
}

+(UIFont *)textLabelFont
{
    return [UIFont systemFontOfSize:LABEL_FONT_SIZE];
}

+(CGFloat)lineSpacing{
    return LABEL_LINESPACE;
}

+(NSLineBreakMode)textLabelLineBreakModel
{
    return NSLineBreakByCharWrapping;
}


@end
