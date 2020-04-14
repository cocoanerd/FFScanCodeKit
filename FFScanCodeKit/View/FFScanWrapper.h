//
//  FFScanWrapper.h
//  MamHao
//
//  Created by egg on 2017/5/18.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFScanWrapper;

@protocol FFScanWrapperDelegate <NSObject>

/**
 扫码成功回调

 @param scanWrapper 扫描仪
 @param scanResult 扫描结果
 */
- (void)scanWrapper:(FFScanWrapper *)scanWrapper scanResult:(NSString *)scanResult;

@end

@interface FFScanWrapper : NSObject

@property (nonatomic, weak) id<FFScanWrapperDelegate> delegate;

/**
 初始化方法

 @param videoPreView 扫描仪要添加到的界面
 @return FFScanWrapper
 */
- (instancetype)initWithVideoPreView:(UIView *)videoPreView;

/**
 开始扫描
 */
- (void)starScan;

/**
 停止扫描
 */
- (void)stopScan;

/**
 修改闪光灯状态

 @param isOpen YES：打开 NO：关闭
 */
- (void)flashStatusChange:(BOOL)isOpen;

/**
 扫描图片中的二维码、条形码
 */
- (NSString *)scanCodeFromImage:(UIImage *)image;
- (NSString *)scanCodeFromCGImageRef:(CGImageRef)imageRef;


/**
 生成二维码
 */
+ (UIImage *)createQRBarcodeWithString:(NSString *)dataString withSize:(CGSize)size;
/**
 生成条形码
 */
+ (UIImage *)createShapeBarcodeWithString:(NSString *)dataString withSize:(CGSize)size;

@end
