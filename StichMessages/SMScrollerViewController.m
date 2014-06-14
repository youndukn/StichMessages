//
//  SMScrollerViewController.m
//  StichMS
//
//  Created by Younduk Nam on 5/30/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMScrollerViewController.h"

//Views and Objects
#import "SMImageView.h"
#import "SMImage.h"


//Utilities
#import "SMUtility.h"
#import "SMConstants.h"

@interface SMScrollerViewController ()

//ResuableViews For Deqeuing
@property (nonatomic, strong) NSMutableArray *reusableViews;

//The Index Above and Bellow visible Views
@property (nonatomic, assign) int aboveVisibleIndex;
@property (nonatomic, assign) int bellowVisibleIndex;

//PrviousContentOffset to detect If ScrollView is Scrolling Up or Down
@property (nonatomic, assign) float previousContentOffset;

@end

@implementation SMScrollerViewController

//Protected
@synthesize images;

@synthesize mainScrollView;

@synthesize toolBarView;

//Private
@synthesize reusableViews;

@synthesize aboveVisibleIndex;
@synthesize bellowVisibleIndex;

@synthesize previousContentOffset;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialize Capacity
        images = [[NSMutableArray alloc] initWithCapacity:30];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Bar color to white for text Inside
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //Initialize mainScrollView
    mainScrollView = [[UIScrollView alloc] initWithFrame: self.view.frame];
    mainScrollView.delegate = self;
    mainScrollView.scrollEnabled = YES;
    [self.view addSubview:mainScrollView];
    
    //Initialize ToolBar
    CGRect toolBarRect = self.view.frame;
    toolBarRect.size.height = 40;
    toolBarRect.origin.y = self.view.frame.size.height-toolBarRect.size.height;
    toolBarView = [[UIView alloc] initWithFrame:toolBarRect];
    toolBarView.backgroundColor = [UIColor lightGrayColor];
    toolBarView.alpha = 0.8;
    [self.view addSubview:toolBarView];
    
    //Initialize Undo All
    float percentSize = 0.1;
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(toolBarRect.size.width - sideInset*percentSize-(toolBarRect.size.height-sideInset*percentSize*2)*2.5,
                                                                  sideInset*percentSize,
                                                                (toolBarRect.size.height-sideInset*percentSize*2)*2.5,
                                                                  toolBarRect.size.height-sideInset*percentSize*2)];
    
    [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangeColor]] forState:UIControlStateNormal];
    [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangePColor]] forState:UIControlStateSelected];
    [editButton setTitle:@"To Edit" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:editButton];
    
}

//Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose All the Views
    NSArray *views = [self.mainScrollView subviews];
    for(UIView *view in views){
        [view removeFromSuperview];
    }
    
    [reusableViews removeAllObjects];
    
}

#pragma mark -- For ChildClasses Classes

//Function to hold
- (void)smViewDidAppear:(SMImageView *)appearedView ForIndex:(int)index{
    //Holder Method for Sub Classes
}

- (void)editAction:(id)sender{
    
    UIButton *editButton = (UIButton *)sender;
    //Change the mode
    mainScrollView.scrollEnabled = !mainScrollView.scrollEnabled;
    
    //Edit Button Or Scroll Mode
    if(mainScrollView.scrollEnabled){
        
        //Scrolling Mode
        [editButton setTitle:@"To Edit" forState:UIControlStateNormal];
        [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangeColor]] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gChangePColor]] forState:UIControlStateSelected];
        
        //All the reusableViews has NO Interation
        for(UIView *view in self.reusableViews){
            view.userInteractionEnabled = NO;
        }
    }else{
        
        //Editing Mode
        [editButton setTitle:@"To Scroll" forState:UIControlStateNormal];
        [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitColor]] forState:UIControlStateNormal];
        [editButton setBackgroundImage:[SMUtility imageWithColor:[SMUtility gSubmitPColor]] forState:UIControlStateSelected];
        
        //All the reusableViews has YES Interation
        for(UIView *view in self.reusableViews){
            view.userInteractionEnabled = YES;
        }
    }
    
}

//Get the View At Index If it is visible
- (SMImageView *)smViewAtIndex:(int)index{
    for(SMImageView *view in reusableViews){
        if(view.tag == index)
            return view;
    }
    return nil;
}

//Reload the View When Something Changed
- (void)reloadSMViews{
    
    //Remove From SuperView
    for(UIView *view in [self.mainScrollView subviews]){
        [view removeFromSuperview];
        [reusableViews removeObject:view];
    }
    
    //Set the Content Size Accordingly
    if([images count]>0){
        self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width,
                                                     [self.images count]*((SMImage *)[self.images lastObject]).size.height/UIScreen.mainScreen.scale);
    }
    
    //Get the Visible Index and Set
    [self setAboveAndBellowVisibleIndex];
    for(int i = aboveVisibleIndex+1 ; i < bellowVisibleIndex ; i++){
        [self smViewDidAppear:[self dequeueReusableViewScrollDirection:YES] ForIndex:i];
    }

}


#pragma mark -- UIScrollViewController

//Check Scrolling Direction and Make the View appear
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(previousContentOffset > scrollView.contentOffset.y &&
       [self getYforAboveVisibleIndex] >= scrollView.contentOffset.y){
        
        //Scrolling Up
        [self smViewDidAppear:[self dequeueReusableViewScrollDirection:NO] ForIndex:aboveVisibleIndex];
        [self setAboveAndBellowVisibleIndex];
    }else if(previousContentOffset < scrollView.contentOffset.y &&
             [self getYforBellowVisibleIndex] <= scrollView.contentOffset.y+scrollView.frame.size.height){
        
        //Scrolling Down
        [self smViewDidAppear:[self dequeueReusableViewScrollDirection:YES] ForIndex:bellowVisibleIndex];
        [self setAboveAndBellowVisibleIndex];
    }
    
    previousContentOffset = scrollView.contentOffset.y;
    
}

#pragma mark -- SMScrollerController

//Deqeue Resuable View In the Scroll Direction
- (SMImageView *) dequeueReusableViewScrollDirection:(BOOL)bellowDirection{
    
    //Initialize
    if(!reusableViews){
        reusableViews = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    //Check the Visibility
    BOOL isVisible = YES;
    
    //bellowDirection is YES for ScrollView Going Down
    //Therefore removable Index is most top one
    int reusableRemovingIndex = (bellowDirection) ? 0: (int)[reusableViews count]-1;
    
    //imageView
    SMImageView *imageView = imageView = [[SMImageView alloc] init];
    imageView.tag = SMImageViewIndexInitialized;
    
    if([reusableViews count] == 0){
        
        //Add Object for Empty Array
        [reusableViews addObject:imageView];
        
    }else{
        
        //If the Removing Object is not visible Remove that view and Added to the new view
        isVisible = [self isVisible:(SMImage *)(((SMImageView *)
                                     [reusableViews objectAtIndex:reusableRemovingIndex]).image)];
        
        //If it is not visible replace the imageView at Removaing Image
        if(!isVisible){
            
            imageView = [reusableViews objectAtIndex:reusableRemovingIndex];
            [reusableViews removeObjectAtIndex:reusableRemovingIndex];
            
        }
        
        //Insert Above or Bellow the Array
        int reusableAddingIndex  = (bellowDirection) ? (int)[reusableViews count] : 0;
        [reusableViews insertObject:imageView atIndex:reusableAddingIndex];
        
    }
    
    //User Interaction Enable
    imageView.userInteractionEnabled = (mainScrollView.scrollEnabled) ? NO : YES;
    
    //MainScrollView Index
    [self.mainScrollView addSubview:imageView];
    return imageView;

}

//Check If the image is visible or not
- (BOOL)isVisible:(SMImage *)image{
    
    if((image.originY >= mainScrollView.contentOffset.y &&
       image.originY <= mainScrollView.contentOffset.y+mainScrollView.frame.size.height) ||
       (image.originY+image.size.height/UIScreen.mainScreen.scale >= mainScrollView.contentOffset.y &&
        image.originY+image.size.height/UIScreen.mainScreen.scale <= mainScrollView.contentOffset.y+mainScrollView.frame.size.height)
       ){
        return YES;
    }
    return NO;
}

//Get Y for above index
- (float)getYforAboveVisibleIndex{
    if(aboveVisibleIndex<0 || [images count]==0){
        return -INFINITY;
    }
    SMImage *image = [images objectAtIndex:aboveVisibleIndex];
    return image.originY+image.size.height/UIScreen.mainScreen.scale;
}

//Get Y for bellow index
- (float)getYforBellowVisibleIndex{
    if(bellowVisibleIndex>=[images count] || [images count]==0){
        return INFINITY;
    }
    return ((SMImage *)[images objectAtIndex:bellowVisibleIndex]).originY;
}

//Initializer for Above and Bellow Index
- (void)setAboveAndBellowVisibleIndex{
    
    //Initialize
    aboveVisibleIndex = 0;
    bellowVisibleIndex = 0;
    
    for(int i = 0; i < [images count]; i++){
        SMImage *image = [images objectAtIndex:i];
        if(image.originY+image.size.height/UIScreen.mainScreen.scale >= mainScrollView.contentOffset.y){
            aboveVisibleIndex = i-1;
            break;
        }
    }
    
    for(int i = 0; i < [images count]; i++){
        SMImage *image = [images objectAtIndex:i];
        if(image.originY < mainScrollView.contentOffset.y+mainScrollView.frame.size.height){
            bellowVisibleIndex = i+1;
        }
    }
    
}


@end
