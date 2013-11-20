//
//  LineWidthController.m
//  ColorPallete
//
//  Created by Ishaan Singal on 31/8/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "LineWidthController.h"

@interface LineWidthController ()
@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UISlider *widthSlider;

@end

@implementation LineWidthController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setValueLabel:nil];
    [self setWidthSlider:nil];
    [super viewDidUnload];
}
- (IBAction)sliderChanged:(id)sender {
    self.valueLabel.text = [NSString stringWithFormat:@"%d pixel tool size", (int)self.widthSlider.value];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //don't do this in viewDidLoad, it occurs before prepareForSegue under iOS 5
    self.widthSlider.value = self.lineWidth;
    [self sliderChanged:self.widthSlider];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.lineWidth = self.widthSlider.value;
    [self.delegate viewController:self didPickWidth:self.lineWidth];
    
}

@end
