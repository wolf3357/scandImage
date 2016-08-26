//
//  ViewController.m
//  ScandImage
//
//  Created by apple on 16/8/26.
//  Copyright © 2016年 金人网络. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanViewController.h"
#import "DeveloperViewController.h"
@interface ViewController ()
@property (nonatomic,strong)UILabel * label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * scandBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    scandBtn.center = CGPointMake(self.view.frame.size.width/3,100);
    [scandBtn setTitle:@"扫描二维码" forState:(UIControlStateNormal)];
    [scandBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [scandBtn addTarget:self action:@selector(click) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:scandBtn];
    
    UIButton * developerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    developerBtn.center = CGPointMake(self.view.frame.size.width/3*2,100);
    [developerBtn setTitle:@"生成二维码" forState:(UIControlStateNormal)];
    [developerBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [developerBtn addTarget:self action:@selector(developerBtn) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:developerBtn];
    
    
    
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    self.label.center = CGPointMake(self.view.frame.size.width/2, 200);
    self.label.font= [UIFont systemFontOfSize:14];
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.textColor = [UIColor grayColor];
    self.label.numberOfLines = 0;
    [self.view addSubview:self.label];
    
}
-(void)developerBtn{
    [self.navigationController pushViewController:[DeveloperViewController new] animated:YES];
}


-(void)click{
    NSLog(@"qqq");
    if ([self validateCamera] && [self canUseCamera]) {
        
        [self showQRViewController];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有摄像头或摄像头不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

//扫描而二维码
-(BOOL)canUseCamera {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(BOOL)validateCamera {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


- (void)showQRViewController {
    
    ScanViewController *qrVC = [[ScanViewController alloc] initWithScanCompleteHandler:^(NSString *url) {
        NSLog(@"%@",url);
        self.label.text = url;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.navigationController pushViewController:qrVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
