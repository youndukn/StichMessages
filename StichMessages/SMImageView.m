//
//  SMImageView.m
//  StichMessages
//
//  Created by Younduk Nam on 5/23/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMImageView.h"

@interface SMImageView ()

@property (nonatomic, assign) float distanceFromCenter;

@end

@implementation SMImageView

@synthesize deleteButton;
@synthesize showDeleteButton;

@synthesize distanceFromCenter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialy DeleteButton is Not showing
        showDeleteButton = NO;
    }
    return self;
}

#pragma mark -- Setting Up
//Sync Tag With Delete Button
- (void)setTag:(NSInteger)_tagTemp{
    //Set Tag
    [super setTag:_tagTemp];
    
    //Set DeleteButon tag if exist
    if(showDeleteButton == YES && deleteButton) deleteButton.tag = _tagTemp;
}

//Set DeleteButton If it is allowed
- (void)setDeleteButton:(UIButton *)_deleteButton{
    
    //Set DeleteButton First
    deleteButton = _deleteButton;
    
    //Set DeleteButton Tag
    if(showDeleteButton == YES) deleteButton.tag = self.tag;
    
}

//Remove Both View and DeleteView
- (void)removeFromSuperview{
    
    //Remove Delete Button From SuperView First
    if(deleteButton) [deleteButton removeFromSuperview];
    
    //Remove Self From SuperView
    [super removeFromSuperview];
    
}


#pragma mark - Touches Protocol 
//Began Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate touchesForView:self Began:touches withEvent:event];
}

//Touches Moved
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate touchesForView:self Moved:touches withEvent:event];
}

//Touches Ended
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate touchesForView:self Ended:touches withEvent:event];
}

//Touches Cancelled
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate touchesForView:self Cancelled:touches withEvent:event];
}

@end
