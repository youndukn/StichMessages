//
//  SMImageProcessor.m
//  StichMessages
//
//  Created by Younduk Nam on 5/20/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMImageProcessor.h"


#include <opencv2/nonfree/features2d.hpp>

#include <opencv2/legacy/legacy.hpp>


@implementation SMImageProcessor


#pragma mark -- OpenCV

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image{
    cv::Mat cvMat = [self cvMatFromUIImage:image];
    cv::Mat grayMat;
    if ( cvMat.channels() == 1 ) {
        grayMat = cvMat;
    }
    else {
        grayMat = cv :: Mat( cvMat.rows,cvMat.cols, CV_8UC1 );
        cv::cvtColor( cvMat, grayMat, CV_BGR2GRAY );
    }
    return grayMat;
}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

/**
 *  Calculate the translation distance between two images
 *   @param    matImage1 - cvImage1 Grayscale
 *             matImage2 - cvImage2 Grayscale
 *             threshold - Threshold for Surface Feature Detection
 *   @return   CGPoint(x,y)
 *                   x = Frequency of the Maxinum Match Points
 *                   y = Tranlsation distance from Image 1 to 2
 **/

+ (CGPoint)detectFeatures:(cv::Mat)matImage1 :(cv::Mat)matImage2 :(float)threshold{
    
    cv::Mat img1 = matImage1;
    cv::Mat img2 = matImage2;
    cv::Mat img3;
   
    if(img1.empty() || img2.empty())
    {
        printf("Can't read one of the images\n");
        return CGPointMake(0, 0);
    }
    // do stuff...
    // detecting keypoints
    
    cv::SurfFeatureDetector detector(threshold);
    cv::vector<cv::KeyPoint> keypoints1, keypoints2;
    detector.detect(img1, keypoints1);
    detector.detect(img2, keypoints2);
    
    // computing descriptors
    cv::SurfDescriptorExtractor extractor;
    cv::Mat descriptors1, descriptors2;
    extractor.compute(img1, keypoints1, descriptors1);
    extractor.compute(img2, keypoints2, descriptors2);
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    cv::FlannBasedMatcher matcher;
    std::vector< cv::DMatch > matches;
    matcher.match(descriptors1, descriptors2, matches);
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist,
    //-- or a small arbitary value ( 0.02 ) in the event that min_dist is very
    //-- small)
    //-- PS.- radiusMatch can also be used here.
    std::vector< cv::DMatch > good_matches;
    
    for( int i = 0; i < descriptors1.rows; i++ )
    {
        
        int x = keypoints2[ matches[i].trainIdx ].pt.x;
        int y = keypoints2[ matches[i].trainIdx ].pt.y;
        
        int x2 = keypoints1[ matches[i].queryIdx ].pt.x;
        int y2 = keypoints1[ matches[i].queryIdx ].pt.y;
        float pixelDiatance = sqrt(pow(x-x2,2)+pow(y-y2, 2));
        if( matches[i].distance <= cv::max(3*min_dist, 0.06) && pixelDiatance > 50)
        {
            good_matches.push_back( matches[i]);
        }
    }
    
    //-- Localize the object
    std::vector<cv::Point2f> matchesPoints1, matchesPoints2;
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matches
        matchesPoints1.push_back( keypoints1[ good_matches[i].queryIdx ].pt );
        matchesPoints2.push_back( keypoints2[ good_matches[i].trainIdx ].pt );
    }
    
    CGPoint finalDistancePoint = [self calculateDistance:matchesPoints1 :matchesPoints2 :img1.rows];
    
    return finalDistancePoint;
}

#pragma mark -- My Image Proccessor
+ (cv::vector<cv::Mat>)getSplittedImagesWithImage:(cv::Mat)imageMat NumbRow:(int)numbRow NumbCol:(int)numbCol{
    
    cv::vector<cv::Mat> seperatedImages;
    
    if(imageMat.rows == 0 || imageMat.cols == 0){
        
        NSLog(@"Image Not Found In Spliiter");
        return seperatedImages;
    }
    
    int sepeartedImageRow = imageMat.rows/numbRow;
    int sepeartedImageCol = imageMat.cols/numbCol;
    
    for(int k = 0; k < numbRow*numbCol; k++){
        
        cv::Mat sepeartedImageGray (sepeartedImageRow, sepeartedImageCol, CV_8UC1);
        cv::Mat sepeartedImageColor (sepeartedImageRow, sepeartedImageCol, CV_8UC4);
        
        int startRow = sepeartedImageRow*(k/numbCol);
        int endRow   = sepeartedImageRow*(k/numbCol+1);
        
        int startCol = sepeartedImageCol*(k%numbCol);
        int endCol   = sepeartedImageCol*(k%numbCol+1);
        
        
        if(endRow <= imageMat.rows && endCol <= imageMat.cols){
            for(int i = startRow; i <  endRow; i++){
                for(int j = startCol; j < endCol; j++){
                    
                    if (imageMat.elemSize() == 1) {
                        sepeartedImageGray.at<uchar>(i%sepeartedImageRow,j%sepeartedImageCol) = imageMat.at<uchar>(i,j);
                    } else {
                        
                        sepeartedImageColor.at<cv::Vec4b>(i%sepeartedImageRow,j%sepeartedImageCol) = imageMat.at<cv::Vec4b>(i,j);
                    }
                    
                }
            }
        }else{
            NSLog(@"Error In image Splitter");
        }
        
        if(imageMat.elemSize() == 1){
            seperatedImages.push_back(sepeartedImageGray);
            sepeartedImageColor.release();
        }else{
            seperatedImages.push_back(sepeartedImageColor);
            sepeartedImageGray.release();
        }
    }
    return seperatedImages;
}

+ (cv::vector<cv::Mat>)getSplittedImageWithImage:(cv::Mat)imageMat andDistance:(float)height{
    
    cv::vector<cv::Mat> seperatedImages;
    
    if(imageMat.rows == 0 || imageMat.cols == 0){
        
        NSLog(@"Image Not Found In Spliiter");
        return seperatedImages;
    }
    
    int sepeartedImageRow1 = height;
    int sepeartedImageRow2 = imageMat.rows-height;
    int sepeartedImageCol = imageMat.cols;
    
    cv::Mat sepeartedImageColor1 (sepeartedImageRow1, sepeartedImageCol, CV_8UC4);
    cv::Mat sepeartedImageColor2 (sepeartedImageRow2, sepeartedImageCol, CV_8UC4);
    
    for(int i = 0; i <  imageMat.rows; i++){
        for(int j = 0; j < sepeartedImageCol; j++){
            
            if(i < height){
                sepeartedImageColor1.at<cv::Vec4b>(i,j) = imageMat.at<cv::Vec4b>(i,j);
            }else{
                sepeartedImageColor2.at<cv::Vec4b>(i-height,j) = imageMat.at<cv::Vec4b>(i,j);
            }
            
        }
    }
    
    seperatedImages.push_back(sepeartedImageColor1);
    seperatedImages.push_back(sepeartedImageColor2);
    
    return seperatedImages;
    
}

+ (cv::Mat)getAppendImageAtBottomFrom:(cv::Mat)imageMat1 With:(cv::Mat)imageMat2{
    
    int combinedImageRow = imageMat1.rows+imageMat2.rows;
    int combinedImageCol = imageMat1.cols;
    
    cv::Mat combinedImageGray(combinedImageRow,combinedImageCol,CV_8UC1);
    cv::Mat combinedImageColor(combinedImageRow,combinedImageCol,CV_8UC4);
    
    if(imageMat1.rows == 0 || imageMat1.cols == 0){
        
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    if(imageMat2.rows == 0 || imageMat2.cols == 0){
        
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    
    if(imageMat1.cols != imageMat2.cols){
        
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    
    
    for(int i = 0; i <  imageMat1.rows; i++){
        for(int j = 0; j < imageMat1.cols; j++){
            
            if (imageMat1.elemSize() == 1) {
                combinedImageGray.at<uchar>(i,j) = imageMat1.at<uchar>(i,j);
            } else {
                combinedImageColor.at<cv::Vec4b>(i,j) = imageMat1.at<cv::Vec4b>(i,j);
            }
            
        }
    }
    
    for(int i = 0; i <  imageMat2.rows; i++){
        for(int j = 0; j < imageMat1.cols; j++){
            
            if (imageMat2.elemSize() == 1) {
                combinedImageGray.at<uchar>(i+imageMat1.rows,j) = imageMat2.at<uchar>(i,j);
            } else {
                combinedImageColor.at<cv::Vec4b>(i+imageMat1.rows,j) = imageMat2.at<cv::Vec4b>(i,j);
            }
            
        }
    }
    if (imageMat2.elemSize() == 1) {
        return combinedImageGray;
    } else {
        return combinedImageColor;
    }
    
}

+ (cv::Mat)getAppendImageAtBottomFrom:(cv::Mat)imageMat1 With:(cv::Mat)imageMat2 With:(int)distance{
    cv::Mat tempImage;
    if(distance < 0){
        distance = abs(distance);
        tempImage = imageMat1;
        imageMat1 = imageMat2;
        imageMat2 = tempImage;
    }
    
    int combinedImageRow = imageMat2.rows+distance;
    int combinedImageCol = imageMat1.cols;
    
    cv::Mat combinedImageGray(combinedImageRow,combinedImageCol,CV_8UC1);
    cv::Mat combinedImageColor(combinedImageRow,combinedImageCol,CV_8UC4);
    
    if(imageMat1.rows == 0 || imageMat1.cols == 0){
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    if(imageMat2.rows == 0 || imageMat2.cols == 0){
        
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    
    if(imageMat1.cols != imageMat2.cols){
        NSLog(@"Image Not Found In Spliiter");
        return combinedImageGray;
    }
    
    for(int i = 0; i <  imageMat1.rows; i++){
        for(int j = 0; j < imageMat1.cols; j++){
            
            if (imageMat1.elemSize() == 1) {
                combinedImageGray.at<uchar>(i,j) = imageMat1.at<uchar>(i,j);
            } else {
                combinedImageColor.at<cv::Vec4b>(i,j) = imageMat1.at<cv::Vec4b>(i,j);
            }
            
        }
    }
    
    for(int i = 0; i <  imageMat2.rows; i++){
        for(int j = 0; j < imageMat1.cols; j++){
            
            if (imageMat2.elemSize() == 1) {
                combinedImageGray.at<uchar>(i+distance,j) = imageMat2.at<uchar>(i,j);
            } else {
                combinedImageColor.at<cv::Vec4b>(i+distance,j) = imageMat2.at<cv::Vec4b>(i,j);
            }
            
        }
    }
    if (imageMat2.elemSize() == 1) {
        return combinedImageGray;
    } else {
        return combinedImageColor;
    }
    
}

/**
 *  Sperate image into meaningful parts only
 *   @param    points1 - First Image Match Points
 *             points2 - Second Image Match Points (should have same length as points1)
 *             size    - Image Size Bigger of Two Image
 *   @return   Tranlsation distance from Image 1 to 2
 **/

+ (cv::vector<cv::Mat>)getLocalizedImages:(cv::Mat)_image{
    
    cv::vector<cv::Mat> seperatedImages;
    
    
    if(_image.empty())
    {
        printf("Can't read one of the images\n");
        return seperatedImages;
    }
    
    // detecting keypoints
    cv::SurfFeatureDetector detector(3000);
    cv::vector<cv::KeyPoint> keypoints1;
    detector.detect(_image, keypoints1);
    
    std::vector<cv::KeyPoint>::iterator it;
    
    size_t height= _image.rows;
    
    NSInteger ySize[height];
    
    for(int i = 0; i < height; i++ ){
        ySize[i] = 0;
    }
    
    while (!keypoints1.empty()) {
        cv::KeyPoint pointElement= keypoints1.back();
        keypoints1.pop_back();
        int y = pointElement.pt.y;
        if(y>0 && y<height){
            ySize[y] += 1;
        }
        
    }
    
    cv::vector<cv::Point> startEndPoints;
    
    for(int i = 0; i <  _image.rows; i++){
        if(ySize[i]>0){
            int zeroNumber = 0;
            for(int k = i; k < _image.rows; k++){
                if(ySize[k]==0){
                    zeroNumber++;
                }
                
                if(zeroNumber > 6 && i+20 < k){
                    startEndPoints.push_back({i, k});
                    i = k;
                    break;
                }
                
            }
        }
    }
    
    while (!startEndPoints.empty()) {
        
        cv::Point pointElement= startEndPoints.back();
        startEndPoints.pop_back();
        
        int startPoint = pointElement.x;
        int endPoint = pointElement.y;
        
        cv::Mat sepeartedImageGray (endPoint - startPoint, _image.cols, CV_8UC1);
        
        for(int i = startPoint; i <  endPoint; i++){
            for(int j = 0; j < _image.cols; j++){
                int startI =i-pointElement.x;
                sepeartedImageGray.at<uchar>(startI,j) = _image.at<uchar>(i,j);
                
            }
        }
        
        seperatedImages.push_back(sepeartedImageGray);
        
    }
    
    return seperatedImages;
    
}

/**
 *  Calculate the translation distance between two images
 *   @param    points1 - First Image Match Points
 *             points2 - Second Image Match Points (should have same length as points1)
 *             size    - Image Size Bigger of Two Image
 *   @return   CGPoint(x,y)
 x = Frequency of the Maxinum Match Points
 y = Tranlsation distance from Image 1 to 2
 **/
+ (CGPoint)calculateDistance:(std::vector<cv::Point2f>)points1 :(std::vector<cv::Point2f>)points2 :(size_t)size{
    
    //Initialize Array
    NSInteger yDistance[size];
    NSInteger yDistanceN[size];
    
    for(int i = 0; i < size; i++ ){
        yDistance[i] = 0;
        yDistanceN[i] = 0;
    }
    
    for(std::vector<int>::size_type i = 0; i != points1.size(); i++) {
        int localDistanceY = points1[i].y-points2[i].y;
        if(localDistanceY > 0) yDistance[localDistanceY] += 1;
        else yDistanceN[abs(localDistanceY)] += 1;
    }
    
    //Find Most Frequent Image
    NSInteger max = 0;
    int finalDistance = 0;
    for(int i = 0; i < size; i++){
        if(yDistance[i] > max){
            max = yDistance[i];
            finalDistance = i;
        }
        if(yDistanceN[i] > max){
            max = yDistanceN[i];
            finalDistance = -i;
        }
    }
    // Must be greater than 10% of the points
    if(max <= 0.10*points1.size()){
        finalDistance = 0;
        NSLog(@"Not Enough Match Features");
    }
    
    return CGPointMake(max, finalDistance);
    
}

/**
 *  Calculate the translation distance between two images
 *   @param    image - Image to take out top and bottom
 *   @return   Vecotr Image that contain only the main image
 **/
+ (cv::vector<cv::Mat>)getMainContent:(cv::Mat)image{
    
    int topInset = 130.0f;
    int bottomInset = 100.0f;
    
    if(image.rows < 230.0f){
        NSLog(@"Not Right Image Used");
        return image;
    }
    
    cv::Mat topImage(topInset,image.cols,CV_8UC4);
    cv::Mat mainImage(image.rows-topInset-bottomInset,image.cols,CV_8UC4);
    
    for(int i = 0; i < topInset; i++){
        for(int j = 0; j < image.cols; j++){
            topImage.at<cv::Vec4b>(i,j) = image.at<cv::Vec4b>(i,j);
        }
    }
    
    for(int i = topInset; i < image.rows-bottomInset; i++){
        for(int j = 0; j < image.cols; j++){
            mainImage.at<cv::Vec4b>(i-topInset,j) = image.at<cv::Vec4b>(i,j);
        }
    }
    
    
    cv::vector<cv::Mat> imageVector;
    imageVector.push_back(topImage);
    imageVector.push_back(mainImage);
    
    return imageVector;
}

/**
 *  Calculate the translation distance between two images
 *   @param    image - Image to take out top and bottom
 *   @return   Image that contain only the main image
 **/
+ (cv::Mat)getMainContentWithNavigation:(cv::Mat)image{
    
    int topInset = 0.0f;
    int bottomInset = 100.0f;
    
    cv::Mat newImage(image.rows-topInset-bottomInset,image.cols,CV_8UC4);
    
    for(int i = topInset; i < image.rows-bottomInset; i++){
        for(int j = 0; j < image.cols; j++){
            newImage.at<cv::Vec4b>(i-topInset,j) = image.at<cv::Vec4b>(i,j);
        }
    }
    
    return newImage;
}

//Metallic grey gradient background
+ (CAGradientLayer*) greyGradient:(CAGradientLayer*)layer {
    
    UIColor *colorOne = [UIColor colorWithWhite:0.9 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.85 alpha:1.0];
    UIColor *colorThree     = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.7 alpha:1.0];
    UIColor *colorFour = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.4 alpha:1.0];
    
    NSArray *colors =  [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.02];
    NSNumber *stopThree     = [NSNumber numberWithFloat:0.99];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
    layer.colors = colors;
    layer.locations = locations;
    
    return layer;
    
}

+(CGRect)regionDividing:(UIImage *)image :(CGPoint) point{
    
    cv::Mat imageMat = [SMImageProcessor cvMatGrayFromUIImage:image];
    
    // detecting keypoints
    cv::FastFeatureDetector detector(100);
    cv::vector<cv::KeyPoint> keypoints1;
    detector.detect(imageMat, keypoints1);

    int textHeight = 23;
    
    cv::vector<cv::KeyPoint> keypointFocused;
    
    int leftMinX = imageMat.cols;
    int rightMaxX = 0;
    
    int leftBorder = 0;
    int rightBorder = imageMat.cols;
    
    keypointFocused = keypoints1;
    
    size_t sizeOfKeypoint = 0;
    
    do {
        
        float leftDistAverage = 0;
        float rightDistAverage = 0;
        
        int leftCounter = 1;
        int rightCounter = 1;
        
        while (!keypoints1.empty()){
            cv::KeyPoint keyPoint = keypoints1.back();
            
            if(keyPoint.pt.y >= point.y-0.75*textHeight && keyPoint.pt.y < point.y+0.75*textHeight ){
                if(keyPoint.pt.x < point.x && keyPoint.pt.x > leftBorder){
                    leftCounter ++;
                    if(keyPoint.pt.x < leftMinX) leftMinX = keyPoint.pt.x;
                    leftDistAverage += abs(point.x-keyPoint.pt.x);
                    keypointFocused.push_back(keyPoint);

                }else if(keyPoint.pt.x >= point.x && keyPoint.pt.x < rightBorder){
                    rightCounter ++;
                    if(keyPoint.pt.x > rightMaxX)rightMaxX = keyPoint.pt.x;
                    rightDistAverage += abs(point.x-keyPoint.pt.x);
                    keypointFocused.push_back(keyPoint);

                }
                
            }
            keypoints1.pop_back();
        }
        
        keypoints1 = keypointFocused;
        keypointFocused.clear();
        
        leftDistAverage /= leftCounter;
        rightDistAverage /= rightCounter;
    
        if(leftDistAverage > rightDistAverage*1.25) {
            leftBorder = point.x - (leftDistAverage+rightDistAverage)*1.25;
            rightBorder = point.x + (leftDistAverage+rightDistAverage)*1.25;
            
        }else if (rightDistAverage > leftDistAverage*1.25){
            rightBorder =point.x + (leftDistAverage+rightDistAverage)*1.25;
            leftBorder = point.x - (leftDistAverage+rightDistAverage)*1.25;
            
        }else{
            break;
        }
        
        if(sizeOfKeypoint == keypoints1.size()) break;
        
        sizeOfKeypoint = keypoints1.size();
        
    } while (rightBorder*0.90 > leftBorder || leftBorder*0.90 < rightBorder);
    
    int originX = leftBorder/UIScreen.mainScreen.scale-8;
    int originY = (point.y-textHeight/1.1)/UIScreen.mainScreen.scale;
    int width = rightBorder/UIScreen.mainScreen.scale+8-originX;
    int height =  (point.y+textHeight/1.1  )/UIScreen.mainScreen.scale-originY;
    
    return CGRectMake(originX,originY,width,height);
    
}

+ (UIImage *)applyBlur:(UIImage *)image :(CGRect)rect{
    
    //
    rect.origin.x = fmax(0,rect.origin.x);
    rect.origin.y = fmax(0,rect.origin.y);
    rect.size.width = fmin(image.size.width-rect.origin.x, rect.size.width);
    rect.size.height = fmin(image.size.height-rect.origin.y, rect.size.height);
    
    cv::Mat imageMat = [SMImageProcessor cvMatFromUIImage:image];
    
    cv::Mat imageTemp (rect.size.height,rect.size.width,CV_8UC4);
    
    for(int i = rect.origin.y; i < rect.origin.y+ rect.size.height; i++){
        for(int j = rect.origin.x; j < rect.origin.x+ rect.size.width; j++){
            
            imageTemp.at<cv::Vec4b>(i-rect.origin.y,j-rect.origin.x) = imageMat.at<cv::Vec4b>(i,j);
            
        }
    }
    
    cv::GaussianBlur(imageTemp, imageTemp, cv::Size(21,11), 10);
    
    for(int i = rect.origin.y; i < rect.origin.y+ rect.size.height; i++){
        for(int j = rect.origin.x; j < rect.origin.x+ rect.size.width; j++){
            
            imageMat.at<cv::Vec4b>(i,j) = imageTemp.at<cv::Vec4b>(i-rect.origin.y,j-rect.origin.x);
            
        }
    }
    
    return [SMImageProcessor UIImageFromCVMat:imageMat];
}

+ (UIImage *)applyBlur:(UIImage *)image WithBluredImages:(NSArray *)blurImages Rects:(NSArray *)rects{
    
    if([blurImages count] != [rects count]){
        NSLog(@"Must be same");
        return image;
    }
    
    cv::Mat imageMat = [SMImageProcessor cvMatFromUIImage:image];
    
    //
    for(int i = 0; i < [blurImages count]; i++){
        UIImage *blurImage = [blurImages objectAtIndex:i];
        CGRect rect = [[rects objectAtIndex:i] CGRectValue];
        
        rect.origin.x = fmax(0,rect.origin.x);
        rect.origin.y = fmax(0,rect.origin.y);
        rect.size.width = fmin(image.size.width-rect.origin.x, rect.size.width);
        rect.size.height = fmin(image.size.height-rect.origin.y, rect.size.height);
        
        
        cv::Mat imageTemp = [SMImageProcessor cvMatFromUIImage:blurImage];
        
        for(int i = rect.origin.y; i < rect.origin.y+ rect.size.height; i++){
            for(int j = rect.origin.x; j < rect.origin.x+ rect.size.width; j++){
                
                imageMat.at<cv::Vec4b>(i,j) = imageTemp.at<cv::Vec4b>(i-rect.origin.y,j-rect.origin.x);
                
            }
        }
        
    }
    
    return [SMImageProcessor UIImageFromCVMat:imageMat];
}


+ (UIImage *)getLcoalBlurImage:(UIImage *)image :(CGRect)rect{
    
    //
    rect.origin.x = fmax(0,rect.origin.x);
    rect.origin.y = fmax(0,rect.origin.y);
    rect.size.width = fmin(image.size.width-rect.origin.x, rect.size.width);
    rect.size.height = fmin(image.size.height-rect.origin.y, rect.size.height);
    
    cv::Mat imageMat = [SMImageProcessor cvMatFromUIImage:image];
    
    cv::Mat imageTemp (rect.size.height,rect.size.width,CV_8UC4);
    
    for(int i = rect.origin.y; i < rect.origin.y+ rect.size.height; i++){
        for(int j = rect.origin.x; j < rect.origin.x+ rect.size.width; j++){
            
            imageTemp.at<cv::Vec4b>(i-rect.origin.y,j-rect.origin.x) = imageMat.at<cv::Vec4b>(i,j);
            
        }
    }
    
    cv::GaussianBlur(imageTemp, imageTemp, cv::Size(21,11), 10);
    
    return [SMImageProcessor UIImageFromCVMat:imageTemp];
}

+ (NSArray *)findSameLocalizedImagesRects:(UIImage *)image :(CGRect)rect{
    
    //
    rect.origin.x = fmax(0,rect.origin.x);
    rect.origin.y = fmax(0,rect.origin.y);
    rect.size.width = fmin(image.size.width-rect.origin.x, rect.size.width);
    rect.size.height = fmin(image.size.height-rect.origin.y, rect.size.height);
    
    cv::Mat imageMat = [SMImageProcessor cvMatFromUIImage:image];
    
    cv::Mat imageTemp (rect.size.height,rect.size.width,CV_8UC4);
    
    for(int i = rect.origin.y; i < rect.origin.y+ rect.size.height; i++){
        for(int j = rect.origin.x; j < rect.origin.x+ rect.size.width; j++){
            
            imageTemp.at<cv::Vec4b>(i-rect.origin.y,j-rect.origin.x) = imageMat.at<cv::Vec4b>(i,j);
            
        }
    }
    
    cv::Mat img1 = imageMat;
    cv::Mat img2 = imageTemp;
    cv::Mat img3;
    
    if(img1.empty() || img2.empty())
    {
        printf("Can't read one of the images\n");
        return nil;
    }
    // do stuff...
    // detecting keypoints
    
    cv::SurfFeatureDetector detector(3000);
    cv::vector<cv::KeyPoint> keypoints1, keypoints2;
    detector.detect(img1, keypoints1);
    detector.detect(img2, keypoints2);
    
    if(keypoints2.size() == 0 || keypoints1.size() == 0){
        printf("Can't find feature");
        return nil;
    }
    
    // computing descriptors
    cv::SurfDescriptorExtractor extractor;
    cv::Mat descriptors1, descriptors2;
    extractor.compute(img1, keypoints1, descriptors1);
    extractor.compute(img2, keypoints2, descriptors2);
   
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    cv::FlannBasedMatcher matcher;
    std::vector< cv::DMatch > matches;
    matcher.match(descriptors1, descriptors2, matches);
    
    double max_dist = 0; double min_dist = 100;
    
    //-- Quick calculation of max and min distances between keypoints
    for( int i = 0; i < descriptors1.rows; i++ )
    { double dist = matches[i].distance;
        if( dist < min_dist ) min_dist = dist;
        if( dist > max_dist ) max_dist = dist;
    }
    
    //-- Draw only "good" matches (i.e. whose distance is less than 2*min_dist,
    //-- or a small arbitary value ( 0.02 ) in the event that min_dist is very
    //-- small)
    //-- PS.- radiusMatch can also be used here.
    std::vector< cv::DMatch > good_matches;
    
    NSMutableDictionary *distanceCounter = [[NSMutableDictionary alloc] initWithCapacity:descriptors1.rows];
    NSMutableArray *trainIdCounter = [[NSMutableArray alloc] initWithCapacity:keypoints2.size()];
    
    for( int i = 0; i < descriptors1.rows; i++ )
    {if( matches[i].distance <= cv::max(3*min_dist, 0.05))
        {
            int x2 = keypoints1[ matches[i].queryIdx ].pt.x;
            int y2 = keypoints1[ matches[i].queryIdx ].pt.y;
            
            int x = keypoints2[ matches[i].trainIdx ].pt.x;
            int y = keypoints2[ matches[i].trainIdx ].pt.y;
            
            int pixelDistance = sqrt(pow(x-x2,2)+pow(y-y2, 2));
            
            BOOL present = NO;
            for(int j = 0; j < [trainIdCounter count]; j++){
                if([[trainIdCounter objectAtIndex:j] intValue]==matches[i].trainIdx){
                    present = YES;
                }
            }
            if(!present)
                [trainIdCounter addObject:[NSNumber numberWithInt:matches[i].trainIdx]];
            
            NSNumber *number = [distanceCounter objectForKey:[NSString stringWithFormat:@"%d",pixelDistance]];
            if (!number) number = [NSNumber numberWithInt:0];
            [distanceCounter setObject:[NSNumber numberWithInt:[number intValue]+1] forKey:[NSString stringWithFormat:@"%d",pixelDistance]];
            
            good_matches.push_back( matches[i]);}
    }
    
    NSMutableArray *rectArray = [[NSMutableArray alloc] initWithCapacity:30];
    
    for( int i = 0; i < good_matches.size(); i++ )
    {
        //-- Get the keypoints from the good matche
        int x2 = keypoints1[ good_matches[i].queryIdx ].pt.x;
        int y2 = keypoints1[ good_matches[i].queryIdx ].pt.y;
        
        int x = keypoints2[ good_matches[i].trainIdx ].pt.x;
        int y = keypoints2[ good_matches[i].trainIdx ].pt.y;
        
        int pixelDistance = sqrt(pow(x-x2,2)+pow(y-y2, 2));
        
        if([[distanceCounter objectForKey:[NSString stringWithFormat:@"%d",pixelDistance]] intValue] > [trainIdCounter count]*0.8){
            
            BOOL present = NO;
            for (int j = 0; j < [rectArray count]; j++) {
                CGRect currentRect = [((NSValue *)[rectArray objectAtIndex:j]) CGRectValue];
                
                if(currentRect.origin.x-10/UIScreen.mainScreen.scale < (x2-x)/UIScreen.mainScreen.scale &&
                   currentRect.origin.x+10/UIScreen.mainScreen.scale > (x2-x)/UIScreen.mainScreen.scale &&
                   currentRect.origin.y-10/UIScreen.mainScreen.scale < (y2-y)/UIScreen.mainScreen.scale &&
                   currentRect.origin.y+10/UIScreen.mainScreen.scale > (y2-y)/UIScreen.mainScreen.scale){
                    present = YES;
                }
                
            }
            if(!present) [rectArray addObject:[NSValue valueWithCGRect:CGRectMake((x2-x)/UIScreen.mainScreen.scale,
                                                                                  (y2-y)/UIScreen.mainScreen.scale,
                                                                                  rect.size.width/UIScreen.mainScreen.scale,
                                                                                  rect.size.height/UIScreen.mainScreen.scale)]];
        }
        
    }
    
    return rectArray;
}

@end
