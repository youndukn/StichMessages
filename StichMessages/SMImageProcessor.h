//
//  SMImageProcessor.h
//  StichMessages
//
//  Created by Younduk Nam on 5/20/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMImageProcessor : NSObject

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (CGPoint)detectFeatures:(cv::Mat)matImage1 :(cv::Mat)matImage2 :(float)threshold;

+ (cv::vector<cv::Mat>)getSplittedImagesWithImage:(cv::Mat)imageMat NumbRow:(int)numbRow NumbCol:(int)numbCol;
+ (cv::vector<cv::Mat>)getSplittedImageWithImage:(cv::Mat)imageMat andDistance:(float)rowPoint;
+ (cv::Mat)getAppendImageAtBottomFrom:(cv::Mat)imageMat1 With:(cv::Mat)imageMat2;
+ (cv::Mat)getAppendImageAtBottomFrom:(cv::Mat)imageMat1 With:(cv::Mat)imageMat2 With:(int)distance;

+ (cv::vector<cv::Mat>)getLocalizedImages:(cv::Mat)_image;
+ (CGPoint)calculateDistance:(std::vector<cv::Point2f>)points1 :(std::vector<cv::Point2f>)points2 :(size_t)size;
+ (cv::vector<cv::Mat>)getMainContent:(cv::Mat)image;

+ (CAGradientLayer*) greyGradient:(CAGradientLayer*)layer;

+ (CGRect)regionDividing:(UIImage *)image :(CGPoint) point;
+ (UIImage *)applyBlur:(UIImage *)image :(CGRect)rect;
+ (UIImage *)applyBlur:(UIImage *)image WithBluredImages:(NSArray *)blurImages Rects:(NSArray *)rects;
+ (UIImage *)getLcoalBlurImage:(UIImage *)image :(CGRect)rect;
+ (NSArray *)findSameLocalizedImagesRects:(UIImage *)image :(CGRect)rect;

@end
