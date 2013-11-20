//
//  ViewController.m
//  ColorPallete
//
//  Created by Ishaan Singal on 9/7/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

///Users/ishaansingal/Library/Application Support/iPhone Simulator/6.1/Applications/CEAC91A8-B0C9-45D9-B4C3-F77736F13226


#import "ViewController.h"
#import "LineWidthController.h"

@interface ViewController () <LineWidthControllerDelegate>
{
        CGPoint pts[5]; // we now need to keep track of the four points of a Bezier segment and the first control point of the next segment
        uint ctr;

    UIPopoverController *popover;
    CGPoint lastPoint;
    CGPoint currentPoint;
}
@property int lineWidth;
@property (copy) NSString* drawingTitle;
-(void)configureSavePopup;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.palette = [[Palette alloc]initWithFrame:CGRectMake(0, 0, 768, 1024)];
//    [self.view addSubview:self.palette];
//    [self.view sendSubviewToBack:self.palette];
    
//    self.infController = [InfColorPickerController colorPickerViewController];
//    [self.infController setDelegate:self];
//    popover = [[UIPopoverController alloc]initWithContentViewController:self.infController];

//    UILongPressGestureRecognizer *longPressRecongizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(drawStuff:)];
//    [longPressRecongizer setMinimumPressDuration:0.0];
//    [longPressRecongizer setDelegate:self];

    [self updateDrawingTitle];
    [self updateSettings];
//    [self configureSavePopup];
}

-(void)updateSettings {
    self.lineWidth = 10;
}

- (void)configureSavePopup {
    NSString* alertMessage = @"Please enter the name of file to be saved";
    self.savePopup = [[UIAlertView alloc] initWithTitle:alertMessage
                                                message:@""
                                               delegate:nil
                                      cancelButtonTitle:@"Save"
                                      otherButtonTitles:@"Cancel", nil];
    self.savePopup.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [self.savePopup setDelegate:self];
}

- (BOOL)shouldTrackTouch:(UITouch*)touch {
    
    //don't track when showing map view

    CGPoint touchLocation = [touch locationInView:self.displayImageView];
    if ((touchLocation.y < 0) || (touchLocation.y > self.displayImageView.frame.size.height)) {
        return NO;
    }
    
    return YES;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.displayImageView];
    pts[0] = lastPoint;
    ctr = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    currentPoint = [touch locationInView:self.displayImageView];

    ctr++;
    pts[ctr] = currentPoint;
    if (ctr == 4)
    {
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
        
    
        CGSize screenSize = self.displayImageView.frame.size;
        UIGraphicsBeginImageContext(screenSize);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        [self.displayImageView.image drawInRect:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        CGContextSetLineCap(currentContext, kCGLineCapRound);
        CGContextSetLineWidth(currentContext, self.lineWidth);
        CGContextSetStrokeColorWithColor(currentContext, (self.colorSelectButton.tintColor).CGColor);
        //    CGContextSetAlpha(currentContext, 0.4f);
        //    CGContextBeginPath(currentContext);
        CGContextMoveToPoint(currentContext, pts[0].x, pts[0].y);
        //    CGContextAddLineToPoint(currentContext, currentPoint.x, currentPoint.y);
        CGContextAddCurveToPoint(currentContext, pts[1].x, pts[1].y,pts[2].x, pts[2].y, pts[3].x, pts[3].y);
        CGContextSetBlendMode(currentContext,kCGBlendModeNormal);
        CGContextStrokePath(currentContext);
        
        self.displayImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.displayImageView setAlpha: 0.4f];
        
        UIGraphicsEndImageContext();
        lastPoint = currentPoint;
        
        pts[0] = pts[3];
        pts[1] = pts[4];
        ctr = 1;

    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ctr = 0;
}


- (IBAction)savePressed:(id)sender {
//    [self testMethod];
    [self.savePopup show];
}

- (IBAction)loadPressed:(id)sender {
    [self setPDFPage];
}

- (IBAction)colorButtonPressed:(id)sender {
    [popover presentPopoverFromBarButtonItem:(UIBarButtonItem*)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (IBAction)sidebarPressed:(id)sender {
    if (self.sideView.hidden == NO) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect sideFrame = self.sideView.frame;
        CGRect displayViewFrame = self.displayImageView.frame;
        
        if (sideFrame.origin.x >= 0) {
            sideFrame.origin.x = -self.sideView.frame.size.width;
        }
        else {
            sideFrame.origin.x = 0;
        }
        self.sideView.frame = sideFrame;
        
        displayViewFrame.origin.x = sideFrame.origin.x + sideFrame.size.width;
        displayViewFrame.size.width = 1024 - displayViewFrame.origin.x;
        self.displayImageView.frame = displayViewFrame;
        [UIView commitAnimations];
    }
}

- (void)updateDrawingTitle {
    if (self.titleTextField.text.length > 0) {
        [self.titleButton setTitle:self.titleTextField.text forState:UIControlStateNormal];
    } else {
        [self.titleButton setTitle:@"Tap to add title" forState:UIControlStateNormal];
    }
    
}

- (IBAction)titleButtonPressed:(id)sender {
    self.titleButton.hidden = YES;
    self.titleTextField.text = self.drawingTitle;
    self.titleTextField.hidden = NO;
    [self.titleTextField becomeFirstResponder];
}


- (void)textFieldDidEndEditing:(UITextField*)textField {

    self.drawingTitle = self.titleTextField.text;
    [self updateDrawingTitle];
    self.titleTextField.hidden = YES;
    self.titleButton.hidden = NO;
//
}

//UITextField Done button
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [self.titleTextField resignFirstResponder];
    return YES;
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
//    CGFloat PDFScale = self.view.frame.size.width/pageRect.size.width;
//    pageRect.size = CGSizeMake(pageRect.size.width * PDFScale, pageRect.size.height * PDFScale);
    
    
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
//    CGContextScaleCTM(context, PDFScale, PDFScale);
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

    NSString *NewPdfPath = [documentsDirectory stringByAppendingPathComponent:@"Edited List.pdf"];

//    if (![[NSFileManager defaultManager] createFileAtPath:NewPdfPath contents:pdfData attributes:nil])
//    {
//        return;
//    }
    
//    NSURL *url = [NSURL fileURLWithPath:originalPdfPath];
//    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL ((__bridge_retained CFURLRef) url);
//    size_t count = CGPDFDocumentGetNumberOfPages(document);
    
//  CGRect pageRect = CGPDFPageGetBoxRect(_PDFPage, kCGPDFMediaBox);

    CGRect paperSize = CGRectMake(0, 0, 768, 1024);

    UIGraphicsBeginPDFPageWithInfo(paperSize, nil);
    
    UIGraphicsBeginPDFContextToFile(NewPdfPath , paperSize, nil);
    // CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
    UIGraphicsBeginPDFPageWithInfo(paperSize, nil);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, 0, paperSize.size.height);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
//    CGPDFPageRef page = CGPDFDocumentGetPage (document, 1); // grab page 1 of the PDF
    
//    CGContextDrawPDFPage (currentContext, page); // draw page 1 into graphics context
    
    // flip context so annotations are right way up
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, -paperSize.size.height);
    
    //Render the layer of the annotations view in the context
    [self.displayImageView.layer renderInContext:currentContext];
    UIGraphicsEndPDFContext();
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LineWidthController *viewController = (LineWidthController*)segue.destinationViewController;
    viewController.lineWidth = self.lineWidth;
    viewController.delegate = self;
}

- (void)colorPickerControllerDidChangeColor:(InfColorPickerController *)controller {
    self.colorSelectButton.tintColor = controller.resultColor;
}

-(void)viewController:(LineWidthController *)viewController didPickWidth:(int)lineWidth {
    self.lineWidth = viewController.lineWidth;
}


#pragma mark - rotation for ios 5
// Override to allow orientations other than the default portrait orientation.
// Rotation for v. 5.1.1
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        return YES;
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        return YES;
    
    return NO;
}

// Rotation 6.0
// Tell the system It should autorotate
- (BOOL) shouldAutorotate {
    return YES;
}

//// Tell the system which initial orientation we want to have
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

// Tell the system what we support
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleButton:nil];
    [self setTitleTextField:nil];
    [super viewDidUnload];
}
@end
