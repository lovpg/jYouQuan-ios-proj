//
//  LLUserGuideBrowser.m
//  Olla
//
//  Created by Pat on 15/9/9.
//  Copyright (c) 2015年 xiaoran. All rights reserved.
//

#import "LLUserGuideBrowser.h"

@interface LLUserGuideBrowser () <MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *images;

@end

@implementation LLUserGuideBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        NSMutableArray *images = [NSMutableArray array];
        
        for (int i=1; i<=15; i++) {
            NSString *imageName = [NSString stringWithFormat:@"olla_guide_%i.jpg", i];
            UIImage *image = [UIImage imageNamed:imageName];
            [images addObject:image];
        }
        
        self.images = images;
    }
    return self;
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.images.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    UIImage *image = self.images[index];
    return [MWPhoto photoWithImage:image];
}

@end
