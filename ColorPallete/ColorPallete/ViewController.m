//
//  ViewController.m
//  ColorPallete
//
//  Created by Ishaan Singal on 9/7/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    UIPopoverController *popover;
    CGPoint lastPoint;
    CGPoint currentPoint;
}
-(void)loadSavePopup;
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

//    UILongPressGestureRecognizer *longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drawStuff:)];
//    [longPressRecongizer setMinimumPressDuration:0.0];
//    [longPressRecongizer setDelegate:self];

    [self loadSavePopup];
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drawStuff:)];
//    [panGesture setMinimumNumberOfTouches:1];
//    [panGesture setMaximumNumberOfTouches:1];
//    [panGesture setDelegate:self];
//    [self.view addGestureRecognizer:longPressRecongizer];
//    [self.view bringSubviewToFront:self.colorSelectedButton];
}


- (void)loadSavePopup {
    NSString* alertMessage = @"Please enter the name of file to be saved";
    self.savePopup = [[UIAlertView alloc] initWithTitle:alertMessage
                                                message:@""
                                               delegate:nil
                                      cancelButtonTitle:@"Save"
                                      otherButtonTitles:@"Cancel", nil];
    self.savePopup.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self.savePopup setDelegate:self];
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
    
//    CGContextSetLineCap(currentContext, kCGLineCapRound);
    CGContextSetLineWidth(currentContext, 1.0);
    CGContextSetStrokeColorWithColor(currentContext, (self.colorSelectedButton.backgroundColor).CGColor);
//    CGContextSetAlpha(currentContext, 0.2f);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(currentContext, currentPoint.x, currentPoint.y);
    CGContextSetBlendMode(currentContext,kCGBlendModeNormal);
    CGContextStrokePath(currentContext);
    
    self.displayImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.displayImageView setAlpha:1];
    
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

        CGContextSetStrokeColorWithColor(currentContext, [UIColor colorWithRed:255 green:255 blue:0 alpha:0.4f].CGColor);
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

- (IBAction)savePressed:(id)sender {
    [self setPDFPage];
//    [self.savePopup show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //check if this alertview is the savePopup
    NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
    if (alertView == self.savePopup) {
        if([buttonTitle isEqualToString:@"Save"]) {
            [self testMethod];
            
            NSString* inputFileName = [[alertView textFieldAtIndex:0] text];
            inputFileName = [inputFileName stringByAppendingString:@".jpg"];
            
            NSData *data = UIImageJPEGRepresentation(self.displayImageView.image, 1.0);
//            NSData *data = UIImagePNGRepresentation(self.displayImageView.image);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:inputFileName];
            [fileManager createFileAtPath:fullPath contents:data attributes:nil];

//            // Create file manager
            NSError *error;

//            // Write out the contents of home directory to console
            NSLog(@"Documents directory: %@", [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error]);
        }
    }
}

- (void)setPDFPage
{
    NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:@"Component List" withExtension:@"pdf"];
    CGPDFDocumentRef PDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfURL);
    CGPDFPageRef PDFPage = CGPDFDocumentGetPage(PDFDocument, 1);

    // Determine the size of the PDF page.
    CGRect pageRect = CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox);
    CGFloat PDFScale = self.view.frame.size.width/pageRect.size.width;
    pageRect.size = CGSizeMake(pageRect.size.width * PDFScale, pageRect.size.height * PDFScale);
    
    
    /*
     Create a low resolution image representation of the PDF page to display before the TiledPDFView renders its content.
     */
    UIGraphicsBeginImageContext(pageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // First fill the background with white.
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    
    CGContextSaveGState(context);
    // Flip the context so that the PDF page is rendered right side up.
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Scale the context so that the PDF page is rendered at the correct size for the zoom level.
    CGContextScaleCTM(context, PDFScale, PDFScale);
    CGContextDrawPDFPage(context, PDFPage);
    CGContextRestoreGState(context);
    
//    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    self.displayImageView.image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
//    backgroundImageView.frame = pageRect;
//    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
//    self.displayImageView = backgroundImageView;    
}

-(void)testMethod {
    NSError *error;
    //Load original pdf data:

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,  YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *originalPdfPath = [documentsDirectory stringByAppendingPathComponent:@"Component List.pdf"];
    
    NSData *pdfData = [NSData dataWithContentsOfFile:originalPdfPath options:NSDataReadingUncached error:&error];
    
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    else
        NSLog(@"Data has loaded successfully.");
    
//    //If fails to create the new file, return    
    NSString *NewPdfPath = [documentsDirectory stringByAppendingPathComponent:@"Edited List.pdf"];

    if (![[NSFileManager defaultManager] createFileAtPath:NewPdfPath contents:pdfData attributes:nil])
    {
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:originalPdfPath];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL ((__bridge_retained CFURLRef) url);
    size_t count = CGPDFDocumentGetNumberOfPages(document);
    
    if (count == 0)
    {
        NSLog(@"PDF needs at least one page");
        return;
    }
    
//    CGRect pageRect = CGPDFPageGetBoxRect(_PDFPage, kCGPDFMediaBox);

    CGRect paperSize = CGRectMake(0, 0, 768, 1024);
    
    UIGraphicsBeginPDFContextToFile(NewPdfPath , paperSize, nil);
    // CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
    UIGraphicsBeginPDFPageWithInfo(paperSize, nil);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, 0, paperSize.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CGPDFPageRef page = CGPDFDocumentGetPage (document, 1); // grab page 1 of the PDF
    
    CGContextDrawPDFPage (currentContext, page); // draw page 1 into graphics context
    
    // flip context so annotations are right way up
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, -paperSize.size.height);
    
    //Render the layer of the annotations view in the context
    [self.displayImageView.layer renderInContext:currentContext];
    UIGraphicsEndPDFContext();
}

- (void)colorPickerControllerDidChangeColor:(InfColorPickerController *)controller {
    self.colorSelectedButton.backgroundColor = controller.resultColor;
    self.palette.drawingPenColor = self.colorSelectedButton.backgroundColor;    
}
@end
