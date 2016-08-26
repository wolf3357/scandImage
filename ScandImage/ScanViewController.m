//
//  ScanViewController.m
//  ScandImage
//
//  Created by apple on 16/8/26.
//  Copyright © 2016年 金人网络. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRView.h"
#import "QRUtil.h"
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,QRViewDelegate>
@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) QRView *qrView;

@property (nonatomic, copy) ScanCompleteBlock scanCompleteBlock;

@property (nonatomic, copy, readwrite) NSString *urlString;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫描二维码";
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
    [button setImage:[UIImage imageNamed:@"top_icon_back"] forState:(UIControlStateNormal)];
    [button setImage:[UIImage imageNamed:@"top_icon_back_on"] forState:(UIControlStateHighlighted)];
    [button addTarget:self action:@selector(leftBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    
    
    [self defaultConfig];       //初始化配置,主要是二维码的配置
    [self configUI];
    [self updateLayout];
    
}
-(void)leftBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)defaultConfig {
    [self startRunning];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (![_session isRunning]) {
        
        [self startRunning];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self stopRunning];
}

- (void)configUI {
    
    [self.view addSubview:self.qrView];
    
}

- (void)updateLayout {
    
    
    
    _qrView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - self.qrView.transparentArea.width) / 2,
                                 (screenHeight - self.qrView.transparentArea.height) / 2,
                                 self.qrView.transparentArea.width,
                                 self.qrView.transparentArea.height);
    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight-32/screenWidth,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
}



#pragma mark - Public Method
-(instancetype)initWithScanCompleteHandler:(ScanCompleteBlock)scanCompleteBlock {
    
    self = [super init];
    if (self) {
        _scanCompleteBlock = scanCompleteBlock;
    }
    return self;
}

- (void)startRunning {
    
    
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    AVCaptureConnection *outputConnection = [_output connectionWithMediaType:AVMediaTypeVideo];
    outputConnection.videoOrientation = [QRUtil videoOrientationFromCurrentDeviceOrientation];
    
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResize;
    _preview.frame =[QRUtil screenBounds];
    [self.view.layer insertSublayer:_preview atIndex:0];
    
    _preview.connection.videoOrientation = [QRUtil videoOrientationFromCurrentDeviceOrientation];
    
    [_session startRunning];
}

- (void)stopRunning {
    
    [_preview removeFromSuperlayer];
    [_session stopRunning];
    
}

#pragma mark QRViewDelegate
-(void)scanTypeConfig:(QRItem *)item {
    
    if (item.type == QRItemTypeQRCode) {
        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
        
    } else if (item.type == QRItemTypeOther) {
        
        _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code,
                                        AVMetadataObjectTypeQRCode];
    }
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue = @"";
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    self.urlString = stringValue;
    
    NSLog(@" 扫描后的url是:%@",stringValue);
    
    if (self.scanCompleteBlock) {
        self.scanCompleteBlock(stringValue);
    }
}


#pragma mark - Getter and Setter


-(QRView *)qrView {
    CGFloat fwidth =[UIScreen mainScreen].bounds.size.width/3*2;
    if (!_qrView) {
        
        CGRect screenRect = [QRUtil screenBounds];
        _qrView = [[QRView alloc] initWithFrame:screenRect];
        _qrView.transparentArea = CGSizeMake(fwidth, fwidth);
        
        _qrView.backgroundColor = [UIColor clearColor];
        _qrView.delegate = self;
    }
    return _qrView;
}
@end
