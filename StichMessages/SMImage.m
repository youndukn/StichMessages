//
//  SMImage.m
//  StichMS
//
//  Created by Younduk Nam on 6/1/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMImage.h"

@implementation SMImage

@synthesize originY;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialy DeleteButton is Not showing
        originY = 0;
    }
    return self;
}

@end
