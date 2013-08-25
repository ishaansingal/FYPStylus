//
//  ViewController.m
//  ColorPallete
//
//  Created by Ishaan Singal on 9/7/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    UIPopoverController *popover;
    CGPoint lastPoint;
    CGPoint currentPoint;

}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.palette = [[Palette alloc]initWithFrame:CGRectMake(0, 0, 768, 1024)];
//    [self.view addSubview:self.palette];
//    [self.view sendSubviewToBack:self.palette];
    
    self.infController = [InfColorPickerController colorPickerViewController];
    [self.infController setDelegate:self];
    popover = [[UIPopoverController alloc]initWithContentViewController:self.infController];

    UILongPressGestureRecognizer *longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drawStuff:)];
    [longPressRecongizer setMinimumPressDuration:0.0];
    [longPressRecongizer setDelegate:self];

//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drawStuff:)];
//    [panGesture setMinimumNumberOfTouches:1];
//    [panGesture setMaximumNumberOfTouches:1];
//    [panGesture setDelegate:self];
//    [self.view addGestureRecognizer:longPressRecongizer];
//    [self.view bringSubviewToFront:self.colorSelectedButton];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self.view];

    CGSize screenSize = self.view.frame.size;
    UIGraphicsBeginImageContext(screenSize);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.displayImageView.image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    CGContextSetLineCap(currentContext, kCGLineCapRound);
    CGContextSetLineWidth(currentContext, 10.0);
    CGContextSetStrokeColorWithColor(currentContext, (self.colorSelectedButton.backgroundColor).CGColor);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(currentContext, currentPoint.x, currentPoint.y);
    CGContextSetBlendMode(currentContext,kCGBlendModeNormal);
    CGContextStrokePath(currentContext);
    
    self.displayImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //        [self.displayImageView setAlpha:1];
    
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)drawStuff:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        currentPoint = [sender locationInView:self.view];

        CGSize screenSize = self.view.frame.size;
        UIGraphicsBeginImageContext(screenSize);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        [self.displayImageView.image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        CGContextSetLineCap(currentContext, kCGLineCapRound);
        CGContextSetLineWidth(currentContext, 10.0);
        CGContextSetStrokeColorWithColor(currentContext, (self.colorSelectedButton.backgroundColor).CGColor);
        CGContextBeginPath(currentContext);
        CGContextMoveToPoint(currentContext, lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(currentContext, currentPoint.x, currentPoint.y);
        CGContextSetBlendMode(currentContext,kCGBlendModeNormal);
        CGContextStrokePath(currentContext);
        
        self.displayImageView.image = UIGraphicsGetImageFromCurrentImageContext();
//        [self.displayImageView setAlpha:1];

        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//}



- (IBAction)buttonPressed:(id)sender {
    if ([(UIButton*)sender isEqual:self.colorSelectedButton]) {
        [popover presentPopoverFromRect:self.colorSelectedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

    }
}

- (void)colorPickerControllerDidChangeColor:(InfColorPickerController *)controller {
    self.colorSelectedButton.backgroundColor = controller.resultColor;
    self.palette.drawingPenColor = self.colorSelectedButton.backgroundColor;    
}
@end
