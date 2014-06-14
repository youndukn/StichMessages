    //
//  SMStichedImageViewController.m
//  StichMessages
//
//  Created by Younduk Nam on 5/24/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMStichedImageViewController.h"

//Views and Objects
#import "SMImageView.h"
#import "SMImage.h"

//Image Processor
#import "SMImageProcessor.h"

//Utilities
#import "MBProgressHUD.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "SMUtility.h"
#import "SMConstants.h"

@interface SMStichedImageViewController ()

@property (nonatomic, strong) NSMutableArray *blurViews;
@property (nonatomic, strong) UIView *currentMask;

@property (nonatomic, assign) BOOL neverRecursiveAsk;

@property (strong, atomic) ALAssetsLibrary* library;

@end

@implementation SMStichedImageViewController

@synthesize stichedImage;

@synthesize blurViews;
@synthesize currentMask;

@synthesize neverRecursiveAsk;

@synthesize library;


- (id)init{
    self = [super init];
    if (self) {
        
        //blurView Initialization
        blurViews = [[NSMutableArray alloc] initWithCapacity:30];
        
        //Library For Saving Image To Albumn
        self.library = [[ALAssetsLibrary alloc] init];
        
        //Remove Swipe From Left To back Button
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
    }
    return self;
    
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        // Custom initialization
        if(image) [self setStichedImage:image];
        else NSLog(@"Set Image");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Click To Edit To Edit";
    
    //Save Image Button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save It"
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                            action:@selector(doneAction:)];
    
    
    //Global Bool Value to check if the percent want recursive Search
    neverRecursiveAsk = NO;
    
    //Set Remove All Button
    UIButton *removeAllBlursButton = [[UIButton alloc] init];
    
    float percentSize = 0.1;
    
    [removeAllBlursButton setFrame:CGRectMake(sideInset*percentSize,
                                sideInset*percentSize,
                                toolBarView.frame.size.height-sideInset*percentSize*2,
                                toolBarView.frame.size.height-sideInset*percentSize*2)];
    
    removeAllBlursButton.tintColor = [UIColor whiteColor];
    [removeAllBlursButton setImage:[UIImage imageNamed:@"repeat_w.png"] forState:UIControlStateNormal];
    
    [removeAllBlursButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitColor]] forState:UIControlStateNormal];
    [removeAllBlursButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitPColor]] forState:UIControlStateSelected];
    [removeAllBlursButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removeAllBlursButton addTarget:self action:@selector(backToUnblur:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBarView addSubview:removeAllBlursButton];
    
    [self reloadSMViews];
    
}

//Remove All ImageViews From Objects
- (void)viewWillDisappear:(BOOL)animated{
    [blurViews removeAllObjects];
    [images removeAllObjects];
    currentMask = nil;
    stichedImage = nil;
}

#pragma makr -- SMScrollerViewController

//View Did Appear Initialize
- (void)smViewDidAppear:(SMImageView *)appearedView ForIndex:(int)index{
    //Get the Image
    SMImage *image = [self.images objectAtIndex:index];
    
    //Set Frame
    if(appearedView.tag == SMImageViewIndexInitialized){
        
        appearedView.frame = CGRectMake(0.0f,image.originY,image.size.width/UIScreen.mainScreen.scale,image.size.height/UIScreen.mainScreen.scale);
        appearedView.showDeleteButton = YES;
        appearedView.layer.borderColor = [SMUtility gChangeColor].CGColor;
        appearedView.layer.borderWidth = 2;
        appearedView.delegate = self;
        
    }
    
    appearedView.frame = CGRectMake(0.0f,image.originY,image.size.width/UIScreen.mainScreen.scale,image.size.height/UIScreen.mainScreen.scale);
    appearedView.tag = index;
    appearedView.image = image;
    
}


#pragma mark -- SMImageViewDelegate

//Touches Touched for SMProcessingImage View
-(void)touchesForView:(SMImageView *)imageView Began:(NSSet *)touches withEvent:(UIEvent *)event{
    //Touch Locations
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.mainScrollView];
    
    //Add Sub View
    currentMask =  [[UIView alloc] initWithFrame:CGRectMake(touchLocation.x-10, touchLocation.y-30, 10, 26)];
    currentMask.backgroundColor = [SMUtility gOverlayColor];
    currentMask.alpha = 0.9;
    currentMask.layer.cornerRadius = 3;
    [mainScrollView addSubview:currentMask];
    
}

//Touches Moved for SMProcessing Image View
-(void)touchesForView:(SMImageView *)imageView Moved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    //Touches location
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.mainScrollView];
    
    //Change The current Mask Accordingly
    currentMask.frame = CGRectMake(currentMask.frame.origin.x,
                                   touchLocation.y-30,
                                   touchLocation.x-currentMask.frame.origin.x,
                                   currentMask.frame.size.height);

}

//Touches Ended
-(void)touchesForView:(SMImageView *)imageView Ended:(NSSet *)touches withEvent:(UIEvent *)event{
    [self blurTheRect];
}

//Touches Cancaled
-(void)touchesForView:(SMImageView *)imageView Cancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self blurTheRect];
}

#pragma mark -- Bluring Actions

//User Ended The Touch to Blur
- (void)blurTheRect{
    
    if(neverRecursiveAsk){
        
        //If user dont want Recursive Search
        [self addBlurViewsFromMasks:@[currentMask]];
        currentMask = nil;
    }else{
        
        //Ask for Recursive Search
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Blurring Options"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Don't Ask This Again"
                                              otherButtonTitles:@"Blur This Spot", @"Add Blurs to Reoccuring Words", nil];
        alert.tag = SMStitchedImageViewControllerAlertVeiwIndexRecursive;
        [alert show];
    }
    
}

//Alert to show if user want recursive search or just blur one spot
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //Currently only action is Recursive Search
    if(alertView.tag == SMStitchedImageViewControllerAlertVeiwIndexRecursive){
        
        //Show Processing
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"Processing"];
        [hud setDimBackground:NO];
        
        //Perform With Delay
        [self performSelector:@selector(blurringAction:) withObject:[NSNumber numberWithInteger:buttonIndex] afterDelay:0.2];
        
    }
}

//Blurring Action
-(void)blurringAction:(id)sender{
    
    //Blur Rect With currentMask
    NSArray *blurRects = @[currentMask];
    
    //Check The Button Index
    if([((NSNumber *)sender) intValue] == 0){
        neverRecursiveAsk = YES;
    }else if([((NSNumber *)sender) intValue] == 2){
        blurRects= [SMImageProcessor findSameLocalizedImagesRects:[images objectAtIndex:0] :[SMUtility getImageRectWithViewRect:currentMask.frame]];
    }
    
    
    [self addBlurViewsFromMasks:blurRects];
    
    [currentMask removeFromSuperview];
    currentMask = nil;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

//Add Blur View From Masks
- (void)addBlurViewsFromMasks:(NSArray *)masks{
    
    //Blurring Masks
    for(int i = 0 ; i < [masks count]; i++){
        CGRect rect;
        if([[masks objectAtIndex:i] isKindOfClass:[UIView class]]){
            rect = ((UIView *)[masks objectAtIndex:i]).frame;
        }else{
            rect = [[masks objectAtIndex:i] CGRectValue];
        }
        [self addBlursOverImage:[images objectAtIndex:0] WithRect:rect];
    }
    
}

//Add Blur Views On Top of that ImageImage
- (void)addBlursOverImage:(SMImage *)image WithRect:(CGRect)rect{
    rect = [SMUtility getImageRectWithViewRect:rect];
    
    UIImage *localBlurImage = [SMImageProcessor getLcoalBlurImage:[images objectAtIndex:0] :rect];
    
    rect = [SMUtility getViewRectWithImageRect:rect];
    
    SMImageView *blurView = [[SMImageView alloc] initWithFrame:rect];
    
    blurView.showDeleteButton = YES;
    blurView.layer.borderColor = [SMUtility gChangeColor].CGColor;
    blurView.layer.borderWidth = 1;
    [blurView setTag:[blurViews count]];
    blurView.image = localBlurImage;
    blurView.tag = [blurViews count];
    [blurViews addObject:blurView];
    
    int deleteOriginX = rect.origin.x+rect.size.width;
    
    if(rect.origin.x+rect.size.width/2 > self.view.frame.size.width/2){
        deleteOriginX =rect.origin.x-sideInset;
    }
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(deleteOriginX,
                                                                        rect.origin.y+rect.size.height/2-sideInset/2,
                                                                        sideInset,
                                                                        sideInset)];
    
    deleteButton.tintColor = [UIColor whiteColor];
    [deleteButton setImage:[UIImage imageNamed:@"delete_w.png"] forState:UIControlStateNormal];
    
    [deleteButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gCancelColor]] forState:UIControlStateNormal];
    [deleteButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gCancelColor]] forState:UIControlStateSelected];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(removeBlur:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:deleteButton];
    [blurView setDeleteButton:deleteButton];
    
    [self.mainScrollView addSubview:blurView];
}

#pragma mark -- ()

//Set Stitched Image And Added To the images
- (void)setStichedImage:(UIImage *)_stichedImage{
    
    stichedImage = _stichedImage;
    if(images){
        [self.images addObject: [[SMImage alloc] initWithCGImage:_stichedImage.CGImage]];
    }
    
}

//Removal All Blur Views
- (void)backToUnblur:(id)sender{
    
    neverRecursiveAsk = NO;
    
    for (int i = 0; i<[blurViews count]; i++) {
        SMImageView *view = [blurViews objectAtIndex:i];
        [view removeFromSuperview];
        [view setTag:i];
    }
    [blurViews removeAllObjects];
    
}

//Remove Blur View With Tag
- (void)removeBlur:(id)sender{
    
    int tagNumber = (int)((UIButton *)sender).tag;
    SMImageView *view = [blurViews objectAtIndex:tagNumber];
    [view removeFromSuperview];
    [view.deleteButton removeFromSuperview];
    [blurViews removeObject:view];
    
    for (int i = 0; i<[blurViews count]; i++) {
        SMImageView *currentView = [blurViews objectAtIndex:i];
        [currentView setTag:i];
    }
}

//When user Press Done Button
- (void)doneAction:(id)sender{
    
    NSArray *colorArray = [[NSArray alloc] initWithObjects:[SMUtility gMainColor],[SMUtility gChangeColor],[SMUtility gOverlayColor],[SMUtility gSubmitColor], nil];
    
    UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    label.backgroundColor = [colorArray objectAtIndex: arc4random() % 4];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:5];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    
     NSString        *dateString = [formatter stringFromDate:[NSDate date]];

    label.text = dateString;
    
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, label.opaque, 0.0);
    [label.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * numberImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    NSMutableArray *blurImages = [[NSMutableArray alloc] initWithCapacity:[blurViews count]];
    NSMutableArray *blurRects = [[NSMutableArray alloc] initWithCapacity:[blurViews count]];
    
    
    for (SMImageView *blurView in blurViews) {
        [blurImages addObject:blurView.image];
        [blurRects addObject:[NSValue valueWithCGRect:[SMUtility getImageRectWithViewRect:blurView.frame]]];
    }
    
    UIImage *blurredImage =[SMImageProcessor applyBlur:[images objectAtIndex:0] WithBluredImages:blurImages Rects:blurRects];
    
    
    [self.library saveImage:numberImage toAlbum:@"StitchMS Albumn" withCompletionBlock:^(NSError *error) {
        if (error!=nil) {
            NSLog(@"Big error: %@", [error description]);
            UIImageWriteToSavedPhotosAlbum(blurredImage, nil, nil, nil);
            
        }else{
            [self.library saveImage:blurredImage toAlbum:@"StitchMS Albumn" withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                    NSLog(@"Big error: %@", [error description]);
                }
            }];
        }
    }];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Picture is saved" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
}

@end
