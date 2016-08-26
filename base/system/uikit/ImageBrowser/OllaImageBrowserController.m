//
//  OllaImageBrowserController.m
//  OllaFramework
//
//  Created by nonstriater on 14-8-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaImageBrowserController.h"
#import "MWPhotoBrowser.h"

@interface OllaImageBrowserController ()<MWPhotoBrowserDelegate>{

    MWPhotoBrowser *photoBrowser;
    NSMutableArray *selectingImages;
}

@end

@implementation OllaImageBrowserController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    //左边是返回
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    
    //网络图片浏览（share可以用）
    [photoBrowser setCurrentPhotoIndex:0];
    self.viewControllers = @[photoBrowser];
    
    selectingImages = [NSMutableArray arrayWithArray:self.images];
    
}

- (void)setCurrentIndex:(NSUInteger)currentIndex{

    _currentIndex = currentIndex;
    [photoBrowser setCurrentPhotoIndex:currentIndex];
    
    [photoBrowser reloadData];
    
}

- (void)reloadData{
    [photoBrowser reloadData];
}


// //////////////////////////////////////////////////////

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser{
    return [self.images count];
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    return [self.images objectAtIndex:index];
}

-(id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index{
    return [self.thumbImages objectAtIndex:index];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
