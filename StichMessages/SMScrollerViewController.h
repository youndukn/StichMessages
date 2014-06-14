//
//  SMScrollerViewController.h
//  StichMS
//
//  Created by Younduk Nam on 5/30/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMImageView.h"

typedef enum {
	SMImageViewIndexInitialized = -1
} SMImageViewIndex;

@interface SMScrollerViewController : UIViewController <UIScrollViewDelegate>{
    @protected
        NSMutableArray *images;
        UIScrollView *mainScrollView;
        UIView *toolBarView;
}

//Images to hold Like Objects
@property (nonatomic, strong) NSMutableArray *images;

//mainScrollView Like TableView
@property (nonatomic, strong) UIScrollView *mainScrollView;

//Bottom Tool Bar For Editing Controll
@property (nonatomic, readonly) UIView *toolBarView;

//SMView Did Appear to the Scroll View Set Necessary Action
- (void)smViewDidAppear:(SMImageView *)appearedView ForIndex:(int)index;

//SMViewAt Index If the index it not visible it return nil
- (SMImageView *)smViewAtIndex:(int)index;

//Reload SMView to regenerate views
- (void)reloadSMViews;

@end
