//
//  LineWidthController.h
//  ColorPallete
//
//  Created by Ishaan Singal on 31/8/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LineWidthController;

@protocol LineWidthControllerDelegate

- (void)viewController:(LineWidthController*)viewController didPickWidth:(int)lineWidth;

@end

@interface LineWidthController : UIViewController

@property (weak) id <LineWidthControllerDelegate> delegate;
@property int lineWidth;

- (IBAction)sliderChanged:(id)sender;

@end
