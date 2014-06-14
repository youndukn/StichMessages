//
//  SMImageView.h
//  StichMessages
//
//  Created by Younduk Nam on 5/23/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMImageViewDelegate;

@interface SMImageView : UIImageView

//Delegate
@property (nonatomic, weak) id <SMImageViewDelegate> delegate;

//DeleteButton For Deleting SMImageView
@property (nonatomic, strong) UIButton *deleteButton;

//BOOL to determine if DeleteButton should show or not
@property (nonatomic, assign) BOOL showDeleteButton;

@end

//Touch Protocol to Delegates
@protocol SMImageViewDelegate <NSObject>

-(void)touchesForView:(SMImageView *)imageView Began:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesForView:(SMImageView *)imageView Moved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesForView:(SMImageView *)imageView Ended:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesForView:(SMImageView *)imageView Cancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
