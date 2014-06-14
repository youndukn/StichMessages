//
//  SMMainViewController.m
//  StichMessages
//
//  Created by Younduk Nam on 5/14/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMMainViewController.h"

//Controllers
#import "SMStichedImageViewController.h"

//Views and Objects
#import "SMImageView.h"
#import "SMImage.h"

//ImageProcessor
#import "SMImageProcessor.h"

//Utilities
#import "ELCImagePickerController.h"
#import "MBProgressHUD.h"

#import "SMUtility.h"
#import "SMConstants.h"

#import <MobileCoreServices/MobileCoreServices.h>

@interface SMMainViewController ()

//Holder For StitchedImageViewController
@property (nonatomic, strong) SMStichedImageViewController *stitchedImageViewController;

//Top Image for Navigation Bar
@property (nonatomic, strong) UIImage *topImage;

//Distance from center is imageview center and deletebutton center in the beginning of the touch
@property (nonatomic, assign) float distanceFromCenter;

@end

@implementation SMMainViewController

@synthesize stitchedImageViewController;

@synthesize topImage;
@synthesize distanceFromCenter;


#pragma mark -ViewController

//View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Title or instruction
    self.title = @"Add Pictures";
    
    //Leftbar to Picture
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Pic" style:UIBarButtonItemStylePlain target:self action: @selector(presentAlbumnPicker:)];
    
    // Right bar for Logout
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Stitch It" style:UIBarButtonItemStylePlain target:self action: @selector(doneAction:)];
    
}


#pragma mark - SMScrollerViewController

//This gets called when the view is appeared
- (void)smViewDidAppear:(SMImageView *)appearedView ForIndex:(int)index{
    
    //Get the Image
    SMImage *image = [self.images objectAtIndex:index];
    
    //Set Frame and Initializer
    //ScrollerViewController Notify if the view is newly created by setting tag to -1
    if(appearedView.tag == SMImageViewIndexInitialized){
        
        //To show the overlay
        appearedView.alpha = 0.5f;
        
        appearedView.layer.borderColor = [SMUtility gChangeColor].CGColor;
        appearedView.layer.borderWidth = 2;
        
        appearedView.showDeleteButton = YES;
        appearedView.delegate = self;
        
    }
    
    appearedView.frame = CGRectMake(0.0f,image.originY,image.size.width/UIScreen.mainScreen.scale,image.size.height/UIScreen.mainScreen.scale);
    appearedView.tag = index;
    appearedView.image = image;
    
    //Set DeleteView if not available
    if(!appearedView.deleteButton){
        
        UIButton *deleteButton = [[UIButton alloc] init];
        
        [deleteButton setImage:[UIImage imageNamed:@"delete_w.png"] forState:UIControlStateNormal];
        
        [deleteButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gCancelColor]] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gCancelColor]] forState:UIControlStateSelected];
        
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [deleteButton addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    
        [self.mainScrollView addSubview:deleteButton];
        
        appearedView.deleteButton = deleteButton;
        
    }
    
    //Set Frame For Delete Button
    float percentSize = 0.8;
    
    [appearedView.deleteButton setFrame:CGRectMake(self.view.frame.size.width - sideInset*(1-percentSize)/2 - sideInset*percentSize,
                                      image.originY+sideInset*(1-percentSize)/2,
                                      sideInset*percentSize,
                                      sideInset*percentSize)];

}

#pragma mark - CameraView

//Present Albumn Picker
-(void)presentAlbumnPicker:(id)sender{
    
    // Create the image picker
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.maximumImagesCount = 10; //Set the maximum number of images to select, defaults to 4
    imagePicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    imagePicker.imagePickerDelegate = self;
    
    //Present modally
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerDelegate
//Image Picker Controller
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    //Dismiss View Before
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    //Show the progress Bar
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    [hud setLabelText:@"Processing"];
    [hud setDimBackground:NO];
    
    //Title or instruction
    self.title = @"Correct Arrangement";
    
    //Perform Processing
    [self performSelector:@selector(performImageProcessing:) withObject:info afterDelay:0.2];

}

//When Albumn is cancelled
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- SMImageViewDelegate

//Touches Touched for SMProcessingImage View
-(void)touchesForView:(SMImageView *)imageView Began:(NSSet *)touches withEvent:(UIEvent *)event{
    //Touch Locations
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.mainScrollView];
    
    //Bring the touched view to front
    [self.mainScrollView bringSubviewToFront:imageView];
    
    //Find the beginTouchPoint
    distanceFromCenter = imageView.center.y-touchLocation.y;
    
    //Alpha for the imageView
    imageView.alpha = 0.8f;

}

//Touches Moved for SMProcessing Image View
-(void)touchesForView:(SMImageView *)imageView Moved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Touches location
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.mainScrollView];
    
    //Center of the image
    CGPoint imageViewCenter = imageView.center;
    
    //Get the Delete Button
    UIButton *deleteButton = imageView.deleteButton;
    
    //DeleteButtonCenter
    CGPoint deleteButtonCenter = deleteButton.center;
    
    //The difference Between imageViewCenter and deleteButtonCenter
    float diffImageLabel = imageViewCenter.y - deleteButtonCenter.y;
    
    //Change the Location of the  ImageView
    imageViewCenter.y = (distanceFromCenter + touchLocation.y);
    imageView.center = imageViewCenter;
    
    //Change the location of the DeleteButton
    deleteButtonCenter.y = (imageViewCenter.y -diffImageLabel);
    deleteButton.center = deleteButtonCenter;
    
}

//Touches Ended
-(void)touchesForView:(SMImageView *)imageView Ended:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Change the image origin from imageView
    SMImage *theImage = (SMImage *)[self.images objectAtIndex:imageView.tag];
    theImage.originY = imageView.frame.origin.y;
    
    //Change the image Arrangement
    [self rearrangeImage:theImage WithIndex:(int)imageView.tag];
    imageView.alpha = 0.5f;
    
    //Reload the currently showing imageview
    [self reloadSMViews];
}

//Touches Cancaled
-(void)touchesForView:(SMImageView *)imageView Cancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Change the image origin from imageView
    SMImage *theImage = (SMImage *)[self.images objectAtIndex:imageView.tag];
    theImage.originY = imageView.frame.origin.y;
    
    //Change the image Arrangement
    [self rearrangeImage:theImage WithIndex:(int)imageView.tag];
    imageView.alpha = 0.5f;
    
    //Reload the currently showing imageview
    [self reloadSMViews];
}

#pragma mark -- Rearrange the images With Action

//Re-Arrange View In Order When View gets before other image Recursive Calls
// 0 1 2 3 4 to 0 3 1 2 4 then assign tags to 0 1 2 3 4
- (void)rearrangeImage:(SMImage *)image WithIndex:(int)currentIndex{
    
    //If Current Index is greater then 0 check upper image
    if(currentIndex > 0){
        
        SMImage *upperImage = [self.images objectAtIndex:currentIndex-1];
        if(upperImage.originY > image.originY){
            
            [self.images removeObjectAtIndex:currentIndex];
            currentIndex -= 1;
            [self.images insertObject:image atIndex:currentIndex];
            
            [self rearrangeImage:image WithIndex:currentIndex];
        
        }
    
    //IF current Index is less then number of images
    }else if(currentIndex < [images count]-1){
        SMImage *lowerImage = [self.images objectAtIndex:currentIndex+1];
        if(lowerImage.originY < image.originY){
            
            [self.images removeObjectAtIndex:currentIndex];
            
            currentIndex += 1;
            [self.images insertObject:image atIndex:currentIndex];
            
            [self rearrangeImage:image WithIndex:currentIndex];
            
        }
    }
    
}

//Remove Image And Up One Tag for bellow images
- (void)removeImage:(id)sender{
    
    UIButton *removeButton = (UIButton *)sender;
    
    //The button Click is not between 0 and [images count] then return
    if (removeButton.tag >= [images count] && removeButton.tag < 0) {
        NSLog(@"Tag Not Right");
        return;
    }
    
    //Find image by the tag number
    SMImage *removingImage = (SMImage *)[self.images objectAtIndex:removeButton.tag];
    int imageOriginY = removingImage.originY;
    
    //If the remove image index is greater then 0 then set the originY to upper image
    if(removeButton.tag>0){
        SMImage *upperImage = ((SMImage *)[self.images objectAtIndex:removeButton.tag-1]);
        imageOriginY = upperImage.originY+upperImage.size.height/UIScreen.mainScreen.scale;
    }
    
    //Move the bellow images to up
    for(int i = (int)removeButton.tag+1; i < [images count]; i++){
        
        SMImage *recursiveImage = (SMImage *)[self.images objectAtIndex:i];
        
        if(i == removeButton.tag+1){
            imageOriginY = recursiveImage.originY - imageOriginY;
        }
        
        recursiveImage.originY -= imageOriginY;
        
    }
    
    //Finally remove the image
    [self.images removeObjectAtIndex:removeButton.tag];
    
    //Reload the view
    [self reloadSMViews];
}

//Image Process When the image is picked
- (void)performImageProcessing:(NSArray *)info{
    
    //If thre is no image Picked
    if([info count]==0){
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        return;
    }
    
    
    //Counts Image Before Adding
    int initImageCount = (int)[images count];
    
    //The Last Image End Point
    SMImage *lastImage = (SMImage *)[images lastObject];
    int finalOriginY = lastImage.originY+lastImage.size.height/UIScreen.mainScreen.scale;
    
    //Add Images
    for(int i = 0; i < [info count];i++){
        
        //Image From Picker
        UIImage *imageTemp = [[info objectAtIndex:i] objectForKey:UIImagePickerControllerOriginalImage];
        
        //Divide Image into Top Main and Bottom
        cv::vector< cv::Mat > topAndMainImage  = [SMImageProcessor getMainContent:[SMImageProcessor cvMatFromUIImage:imageTemp]];
        
        //Save the top image for later Stiching
        if(initImageCount == 0 && i == 0){
            //topAndMainImage front() is the Top image
            topImage = [SMImageProcessor UIImageFromCVMat: topAndMainImage.front()];
        }
        
        //topAndMainImage back() is the Main image
        SMImage *mainImage = [[SMImage alloc] initWithCGImage:[SMImageProcessor UIImageFromCVMat:topAndMainImage.back()].CGImage];
        
        //Just append the image after i
        mainImage.originY = finalOriginY+i*mainImage.size.height/UIScreen.mainScreen.scale;
        
        //Add the image to images
        [images addObject:mainImage];
    }
    
    //Start Image From the previous image and compare. If there was no image before Dont compare
    int starter = (initImageCount-1 < 0) ? 0: initImageCount-1;
    
    //Start from starter until the the last image
    for(int i = starter; i < [images count]-1; i++){
        
        SMImage *leadImage = [images objectAtIndex:i];
        SMImage *followImage = [images objectAtIndex:i+1];
        
        cv::Mat leadImageMat = [SMImageProcessor cvMatGrayFromUIImage:leadImage];
        cv::Mat followImageMat = [SMImageProcessor cvMatGrayFromUIImage:followImage];
        
        //Divide the image into left and right
        cv::vector<cv::Mat>leadImageMatDiv=[SMImageProcessor getSplittedImagesWithImage:leadImageMat NumbRow:1 NumbCol:2];
        cv::vector<cv::Mat>followImageMatDiv=[SMImageProcessor getSplittedImagesWithImage:followImageMat NumbRow:1 NumbCol:2];
        
        //Compare Left
        CGPoint leftPoint = [SMImageProcessor detectFeatures:leadImageMatDiv.front() :followImageMatDiv.front() :4000];
        CGPoint rightPoint = [SMImageProcessor detectFeatures:leadImageMatDiv.back()  :followImageMatDiv.back()  :4000];
        
        //X in the points is Frequency and Y in the points is Distance
        int leftFreq = leftPoint.x;
        int rightFreq = rightPoint.x;
        int leftDist = leftPoint.y;
        int rightDist = rightPoint.y;
        
        int distanceFinal = leadImage.size.height;
        
        if(leftDist== 0 && rightDist == 0){
            //NotFound
        }else if(leftDist == rightDist){
            distanceFinal = leftDist;
        }if(abs(leftFreq) > abs(rightFreq)){
            //distance1 better
            distanceFinal = leftDist;
        }else if(abs(leftFreq) < abs(rightFreq)){
            //distance1 better
            distanceFinal = rightDist;
        }
        
        //Final distance is converted to view friendly
        distanceFinal = distanceFinal/UIScreen.mainScreen.scale;
        
        //If the final distance is greater than 0 set
        if(distanceFinal>0){
            
            float tempPointY = leadImage.originY;
            tempPointY += distanceFinal;
            followImage.originY = tempPointY;
            
        }
        
    }

    //End Progress Bar
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    
    //Reload View
    [self reloadSMViews];
    
}


#pragma mark -- ()

- (void)doneAction:(id)sender{
    
    //If the images is not there return
    if([images count]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Image to Stitch" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    //First image is the lead image
    SMImage *firstImage = [images objectAtIndex:0];
    int beginY = firstImage.originY;
    
    //Append from top to bottom
    cv::Mat currentImage =  [SMImageProcessor cvMatFromUIImage:firstImage];
    for(int i = 1; i < [images count];i++){
        SMImage *nextImage = [images objectAtIndex:i];
        cv::Mat nextImageMat = [SMImageProcessor cvMatFromUIImage:nextImage];
        
        currentImage = [SMImageProcessor getAppendImageAtBottomFrom:currentImage With:nextImageMat With:(nextImage.originY - beginY)*UIScreen.mainScreen.scale];
    }
    
    cv::Mat topImageMat = [SMImageProcessor cvMatFromUIImage:topImage];
    currentImage = [SMImageProcessor getAppendImageAtBottomFrom:topImageMat With:currentImage With:topImageMat.rows];
    
    //Present the stitchedImageController with the image
    if(!stitchedImageViewController){
        stitchedImageViewController = [[SMStichedImageViewController alloc] init];
    }
    [stitchedImageViewController setStichedImage:[SMImageProcessor UIImageFromCVMat:currentImage]];
    [self.navigationController pushViewController:stitchedImageViewController animated:YES];
}

@end
