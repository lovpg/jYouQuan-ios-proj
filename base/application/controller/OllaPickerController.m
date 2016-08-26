//
//  OllaPickerController.m
//  OllaFramework
//
//  Created by nonstriater on 14-7-10.
//  Copyright (c) 2014年 xiaoran. All rights reserved.
//

#import "OllaPickerController.h"

@implementation OllaPickerController

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_dataObjects count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    return [_dataObjects objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([self.delegate respondsToSelector:@selector( pickerController: didSelect:) ]) {
        [self.delegate pickerController:self didSelect:_dataObjects[row]];
    }
}


@end
