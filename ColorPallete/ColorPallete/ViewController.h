//
//  ViewController.h
//  ColorPallete
//
//  Created by Ishaan Singal on 9/7/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Palette.h"
#import <QuartzCore/QuartzCore.h>
#import "InfColorPicker/InfColorPickerController.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, InfColorPickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *displayImageView;
@property InfColorPickerController *infController;
@property Palette *palette;
@property (strong, nonatomic) IBOutlet UIButton *colorSelectedButton;

- (IBAction)buttonPressed:(id)sender;

@end
