//
//  Palette.m
//  ColorPallete
//
//  Created by Ishaan Singal on 9/7/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

#import "Palette.h"
@interface Palette ()
{
    CGPoint lastPoint;
    CGPoint currentPoint;
    NSMutableArray *points;
}
@end

@implementation Palette

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        lastPoint = CGPointMake(0, 0);
        currentPoint = CGPointMake(0, 0);
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drawStuff:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [panGesture setDelegate:self];
        [self addGestureRecognizer:panGesture];
        
        points = [[NSMutableArray alloc]init];
        
        self.drawingPenColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawStuff:(UIPanGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        lastPoint = [sender locationInView:self];
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        currentPoint = [sender locationInView:self];
        [points addObject:[NSValue valueWithCGPoint:lastPoint]];
        [points addObject:[NSValue valueWithCGPoint:currentPoint]];
        [self setNeedsDisplay];
       
        lastPoint = currentPoint;
    }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ref = UIGraphicsGetCurrentContext();
//    CGContextMoveToPoint(ref, lastPoint.x, lastPoint.y);
//    CGContextAddLineToPoint(ref, currentPoint.x, currentPoint.y);
    CGContextSetLineCap(ref, kCGLineCapRound);
    CGContextSetLineWidth(ref, 10);
    CGContextSetStrokeColorWithColor(ref, (self.drawingPenColor).CGColor);//(ref, 0, 0.5, 0, 1.0);
    CGContextSetLineJoin(ref, kCGLineJoinRound);

    CGPoint *allPoints = (CGPoint*)malloc(sizeof(CGPoint)*[points count]*2);
    for(int i=0;i<[points count];i++){
        allPoints[i] = [[points objectAtIndex:i]CGPointValue];
    }
    CGContextStrokeLineSegments(ref, allPoints, [points count]);
    free(allPoints);
}


@end
