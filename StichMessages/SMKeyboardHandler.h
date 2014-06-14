//
//  SMKeyboardHandler.h
//  Version1
//
//  Created by Younduk Nam on 5/23/13.
//  Copyright (c) 2013 Younduk Nam. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SMKeyboardHandlerDelegate;

@interface SMKeyboardHandler : NSObject

- (id)init;

// Put 'weak' instead of 'assign' if you use ARC
@property(nonatomic, weak) id<SMKeyboardHandlerDelegate> delegate;
@property(nonatomic) CGRect frame;


@end

@protocol SMKeyboardHandlerDelegate

- (void)keyboardSizeChanged:(CGSize)delta;

@end