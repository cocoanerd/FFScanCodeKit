//
//  FFScanningViewController.h
//  MamHao
//
//  Created by SmartMin on 15/6/3.
//  Copyright (c) 2015年 Mamhao. All rights reserved.
//
// 【扫描二维码】
#import <UIKit/UIKit.h>

@class FFScanningViewController;

typedef void (^FFScanCodeKitHandleResultBlock) (FFScanningViewController* viewController, NSString *scanCode);

@interface FFScanningViewController : UIViewController

/// 扫码结果处理
@property (nonatomic, copy) FFScanCodeKitHandleResultBlock scanResultBlock;

/// 提供给外部使用，需要开始扫码
- (void)startScan;

@end
