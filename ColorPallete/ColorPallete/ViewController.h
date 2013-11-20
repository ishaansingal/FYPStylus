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

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, InfColorPickerControllerDelegate,UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *displayImageView;
@property InfColorPickerController *infController;
@property(strong, nonatomic) UIAlertView *savePopup;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *colorSelectButton;
@property (strong, nonatomic) IBOutlet UIView *sideView;
@property (strong, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;

- (IBAction)savePressed:(id)sender;
- (IBAction)loadPressed:(id)sender;
- (IBAction)colorButtonPressed:(id)sender;
- (IBAction)sidebarPressed:(id)sender;
- (IBAction)titleButtonPressed:(id)sender;

@end
