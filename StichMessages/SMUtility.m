//
//  SMUtility.m
//  SafeMessage
//
//  Created by Younduk Nam on 4/2/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMUtility.h"

@implementation SMUtility

//Color
+ (UIColor *)gBackgroundColor{
    return [UIColor colorWithRed:3/255.0f green:7/255.0f blue:47/255.0f alpha:1];
}

+ (UIColor *)gMainLightColor{
    return [UIColor colorWithRed:40/255.0f green:160/255.0f blue:255/255.0f  alpha:1];
}

+ (UIColor *)gMainColor{
    return [UIColor colorWithRed:0.27 green:0.70 blue:0.85 alpha:1];
}

+ (UIColor *)gTitleColor{
    return [UIColor colorWithRed:208/255.0f green:208/255.0f blue:208/255.0f alpha:1];
}

+ (UIColor *)gOverlayColor{
    return [UIColor colorWithRed:102/255.0f green:51/255.0f blue:153/255.0f alpha:1];
}

+ (UIColor *)gSubmitColor{
    return [UIColor colorWithRed:112/255.0f  green:204/255.0f blue:131/255.0f alpha:1];
}

+ (UIColor *)gSubmitPColor{
    return [UIColor colorWithRed:112/255.0f/1.3f  green:244/255.0f/1.3f blue:131/255.0f/1.3f alpha:1];
}

+ (UIColor *)gCancelColor{
    return [UIColor colorWithRed:246/255.0f  green:110/255.0f blue:75/255.0f alpha:1];
}

+ (UIColor *)gCancelPColor{
    return [UIColor colorWithRed:246/255.0f/1.3f green:110/255.0f/1.3f  blue:75/255.0f/1.3f  alpha:1];
}

+ (UIColor *)gChangeColor{
    return [UIColor colorWithRed:246/255.0f  green:160/255.0f blue:110/255.0f alpha:1];
}

+ (UIColor *)gChangePColor{
    return [UIColor colorWithRed:246/255.0f/1.3f   green:160/255.0f/1.3f  blue:110/255.0f/1.3f  alpha:1];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (NSArray *)getFramesWithColumns:(int)columns Row:(int)rows
                            Width:(float)width Height:(float)height
                           SideRL:(float)sideRL MiddleRL:(float)middleRL
                           SideTB:(float)sideTB MiddleTB:(float)middleTB {
    
    float eWidth  = (width-(sideRL*2+middleRL*(columns-1)))/columns;
    float eHeight = (height-(sideTB*2+middleTB*(rows-1)))/rows;
    
    NSMutableArray *rectArray = [[NSMutableArray alloc] initWithCapacity:columns*rows];
    for(int i = 0; i < rows; i++){
        for(int j = 0; j < columns; j++){
            
            float originX = j*eWidth+sideRL+middleRL*j;
            float originY = i*eHeight+sideTB+middleTB*i;
            
            CGRect frame = CGRectMake(originX, originY, eWidth,eHeight);
            [rectArray addObject:[NSValue valueWithCGRect:frame]];
        }
    }
    return rectArray;
}

+ (CGRect)getViewRectWithImageRect:(CGRect)rect{
    rect.size.width /=UIScreen.mainScreen.scale;
    rect.size.height /=UIScreen.mainScreen.scale;
    rect.origin.x /=UIScreen.mainScreen.scale;
    rect.origin.y /=UIScreen.mainScreen.scale;
    return rect;
}


+ (CGRect)getImageRectWithViewRect:(CGRect)rect{
    rect.size.width *=UIScreen.mainScreen.scale;
    rect.size.height *=UIScreen.mainScreen.scale;
    rect.origin.x *=UIScreen.mainScreen.scale;
    rect.origin.y *=UIScreen.mainScreen.scale;
    return rect;
}



@end
