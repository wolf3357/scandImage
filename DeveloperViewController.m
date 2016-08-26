//
//  DeveloperViewController.m
//  ScandImage
//
//  Created by apple on 16/8/26.
//  Copyright © 2016年 金人网络. All rights reserved.
//

#import "DeveloperViewController.h"

@interface DeveloperViewController()<UITextFieldDelegate>
{
    UITextField * _textfield;
    UIImageView * _imageView;
}

@end

@implementation DeveloperViewController

-(void)viewDidLoad{
    [super viewDidLoad];

    self.navigationController.title = @"生成二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    _textfield = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 300, 50)];
    _textfield.center = CGPointMake(self.view.frame.size.width/2, 150);
    _textfield.placeholder = @"请输入";
    _textfield.delegate = self;
    _textfield.font = [UIFont systemFontOfSize:15];
    _textfield.textColor = [UIColor blackColor];
    _textfield.clearButtonMode = UITextFieldViewModeAlways;
    _textfield.keyboardType = UIKeyboardTypeDefault;
    _textfield.borderStyle = UITextBorderStyleNone;
    _textfield.backgroundColor = [UIColor whiteColor];
    _textfield.textAlignment = NSTextAlignmentLeft;
    _textfield.secureTextEntry = NO;
    [self.view addSubview:_textfield];
    
    UIButton * developerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    developerBtn.center = CGPointMake(self.view.frame.size.width/2,200);
    [developerBtn setTitle:@"生成二维码" forState:(UIControlStateNormal)];
    [developerBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [developerBtn addTarget:self action:@selector(developerBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:developerBtn];
    
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    _imageView.center = CGPointMake(self.view.frame.size.width/2, 370);
    [self.view addSubview:_imageView];
}

-(void)developerBtn{
    [_textfield resignFirstResponder];
    NSString * str = _textfield.text;
    
    if (str) {
        
        // 1.创建滤镜
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        // 2.还原滤镜默认属性
        [filter setDefaults];
        
        // 3.设置需要生成二维码的数据到滤镜中
        // OC中要求设置的是一个二进制数据
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKeyPath:@"InputMessage"];
        
        // 4.从滤镜从取出生成好的二维码图片
        CIImage *ciImage = [filter outputImage];
        
        _imageView.layer.shadowOffset = CGSizeMake(0, 0.5);  // 设置阴影的偏移量
        _imageView.layer.shadowRadius = 1;  // 设置阴影的半径
        _imageView.layer.shadowColor = [UIColor blackColor].CGColor; // 设置阴影的颜色为黑色
        _imageView.layer.shadowOpacity = 0.3; // 设置阴影的不透明度
        
        _imageView.image = [self createNonInterpolatedUIImageFormCIImage:ciImage size: 500];
    }else{
        UIAlertView * alertviews = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入内容" delegate:self cancelButtonTitle:@"queding" otherButtonTitles:nil, nil];
        [alertviews show];
    }
}
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)ciImage size:(CGFloat)widthAndHeight
{
    CGRect extentRect = CGRectIntegral(ciImage.extent);
    CGFloat scale = MIN(widthAndHeight / CGRectGetWidth(extentRect), widthAndHeight / CGRectGetHeight(extentRect));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extentRect) * scale;
    size_t height = CGRectGetHeight(extentRect) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:ciImage fromRect:extentRect];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extentRect, bitmapImage);
    
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    //return [UIImage imageWithCGImage:scaledImage];
    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    return [self imageBlackToTransparent:newImage withRed:0.0 andGreen:0.0 andBlue:0.0];
}

#pragma mark - 图片透明度
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return[textField resignFirstResponder];
}

@end
