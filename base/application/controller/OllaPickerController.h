//
//  OllaPickerController.h
//  OllaFramework
//
//  Created by nonstriater on 14-7-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaController.h"

@interface OllaPickerController : OllaController<UIPickerViewDelegate,UIPickerViewDataSource>{
}

@property(nonatomic,weak) IBOutlet UIPickerView *pickerView;
@property(nonatomic,strong) NSArray *dataObjects;


@end

@protocol OllaPickerControllerDelegate <NSObject>

- (void)pickerController:(OllaPickerController *)controller didSelect:(NSString *)title;

@end


