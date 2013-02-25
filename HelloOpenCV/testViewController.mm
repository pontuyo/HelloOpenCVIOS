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

@synthesize canvas;
@synthesize touchPoint;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *image = [UIImage imageNamed:@"climbing.jpg"];
    UIImage *resizeImage = [self resizeImage:image rect:CGRectMake(0,0,320,480)];
    
    touchPoint = CGPoint();
    
    cv::Mat srcMat = [self cvMatFromUIImage:resizeImage];
    cv::Mat greyMat;
    cv::cvtColor(srcMat, greyMat, CV_BGR2GRAY);
    resizeImage = nil;
    resizeImage = [self UIImageFromCVMat:greyMat];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.center = self.view.center;
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleBottomMargin | [UIViewAutoresizingFlexibleTopMargin;
    [imageView setFrame:CGRectMake(0.0, 0.0, resizeImage.size.width, resizeImage.size.height)];

    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = resizeImage;
    imageView.alpha = 0.5f;

                                                                                                                                                         
    [self.view addSubview:imageView];
    
    canvas = [[UIImageView alloc] initWithImage:nil];
    //canvas.backgroundColor= [UIColor whiteColor];
    canvas.frame = self.view.frame;
    [self.view addSubview:canvas];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 画面に指をタッチしたとき
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // タッチ開始座標をインスタンス変数touchPointに保持
    UITouch *touch = [touches anyObject];
    touchPoint = [touch locationInView:canvas];

}

// 画面に指がタッチされた状態で動かしているとき
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // 現在のタッチ座標をローカル変数currentPointに保持
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:canvas];
    
    // 描画領域をcanvasの大きさで生成
    UIGraphicsBeginImageContext(canvas.frame.size);
    
    // canvasにセットされている画像（UIImage）を描画
    [canvas.image drawInRect:
     CGRectMake(0, 0, canvas.frame.size.width, canvas.frame.size.height)];
    
    // 線の角を丸くする
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    // 線の太さを指定
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0);
    
    // 線の色を指定（RGB）
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 0.0, 1.0);
    
    // 線の描画開始座標をセット
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), touchPoint.x, touchPoint.y);
    
    // 線の描画終了座標をセット
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    
    // 描画の開始～終了座標まで線を引く
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    // 描画領域を画像（UIImage）としてcanvasにセット
    canvas.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 描画領域のクリア
    UIGraphicsEndImageContext();
    
    // 現在のタッチ座標を次の開始座標にセット
    touchPoint = currentPoint;
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

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
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
                                        cvMat.step[0],                              //bytesPerRow
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

@end
