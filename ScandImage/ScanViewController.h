//
//  ScanViewController.h
//  ScandImage
//
//  Created by apple on 16/8/26.
//  Copyright © 2016年 金人网络. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ScanCompleteBlock)(NSString *url);

@interface ScanViewController : UIViewController

@property (nonatomic, copy, readonly) NSString *urlString;

- (instancetype)initWithScanCompleteHandler:(ScanCompleteBlock)scanCompleteBlock;

- (void)stopRunning;
@end
