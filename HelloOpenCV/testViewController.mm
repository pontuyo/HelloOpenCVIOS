//
//  testViewController.m
//  HelloOpenCV
//
//  Created by pontuyo on 2013/02/03.
//  Copyright (c) 2013年 pontuyo. All rights reserved.
//

#import "testViewController.h"

@interface testViewController ()

@end

@implementation testViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"climbing.jpg"];
    UIImage *resizeImage = [self resizeImage:image rect:CGRectMake(0,0,320,480)];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.center = self.view.center;
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleBottomMargin | [UIViewAutoresizingFlexibleTopMargin;
    [imageView setFrame:CGRectMake(0.0, 0.0, resizeImage.size.width, resizeImage.size.height)];

    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = resizeImage;

                                                                                                                                                         
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)resizeImage:(UIImage *)img rect:(CGRect)rect{
    
    UIGraphicsBeginImageContext(rect.size);
    
    [img drawInRect:rect];
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
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
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}



@end
