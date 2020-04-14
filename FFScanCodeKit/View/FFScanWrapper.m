//
//  FFScanWrapper.m
//  MamHao
//
//  Created by egg on 2017/5/18.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import "FFScanWrapper.h"
#import "FFScanningPermissions.h"
#import "FFScanRelative.h"
#import <AVFoundation/AVFoundation.h>
#import "ZBarSDK.h"

@interface FFScanWrapper () <AVCaptureVideoDataOutputSampleBufferDelegate>

/** 防止扫码结果多次返回*/
@property (nonatomic, assign) BOOL isNeedScanResult;
/** ZBar用于识别图片中的码*/
@property (nonatomic, strong) ZBarReaderController *reader;
/** 原生用于识别图片中的码*/
@property (nonatomic, strong) CIDetector* detector;
/** 记录当前时间*/
@property (nonatomic, assign) NSTimeInterval currentTimeInterval;
/** 视频捕捉设备*/
@property (nonatomic, strong) AVCaptureDevice *device;
/** 输入流*/
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出流*/
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
/** 输入设备和输出设备之间的数据传递*/
@property (nonatomic, strong) AVCaptureSession * session;
/** 预览图层，显示摄像头捕捉到的画面*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation FFScanWrapper

- (instancetype)initWithVideoPreView:(UIView *)videoPreView {
    self = [super init];
    if (self) {
        self.isNeedScanResult = YES;
        // 判断是否授予相机相册权限
        if (![FFScanningPermissions isGetCameraPermission]) {
            [FFScanRelative openCameraPermissionAlert];
        } else {
            [self addScanWrapperToVideoPreView:videoPreView];
        }
    }
    return self;
}

- (void)addScanWrapperToVideoPreView:(UIView*)videoPreView {
    NSError *error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!self.input) {
        [FFScanRelative videoPreViewInitFailedAlert];
    } else {
        if ([self.session canAddInput:self.input]) {
            [self.session addInput:self.input];
        }
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
        // 用当前的output 初始化connection
        AVCaptureConnection *connection =[self.output connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [videoPreView.layer insertSublayer:self.previewLayer atIndex:0];
        [self.input.device lockForConfiguration:nil];
        // 自动对焦
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        // 自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        }
        //自动曝光
        if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        [self.input.device unlockForConfiguration];
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (self.isNeedScanResult) {        // 防止连续处理图片
        NSTimeInterval newTimeInterval = [[NSDate date] timeIntervalSince1970];
        if (newTimeInterval - self.currentTimeInterval < 1) {
            return;
        }
        self.currentTimeInterval = newTimeInterval;
        
        NSString *barCode = [self codeStrFromSampleBuffer:sampleBuffer];
        if (barCode.length != 0 && self.delegate && [self.delegate respondsToSelector:@selector(scanWrapper:scanResult:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isNeedScanResult = NO;
                [self.delegate scanWrapper:self scanResult:barCode];
            });
        }
    }
}

- (NSString *)codeStrFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 裁剪图片增加识别效率
    CGImageRef finalImageRef = [self scaledImage:quartzImage width:width height:height];
    NSString *codeStr = [self scanCodeFromCGImageRef:finalImageRef];
    
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    CGImageRelease(finalImageRef);
    
    return (codeStr);
}


#pragma mark - private methods


- (void)starScan {
    self.isNeedScanResult = YES;
    if (self.input && !self.session.isRunning) {
        [self.session startRunning];
    }
}

- (void)stopScan {
    self.isNeedScanResult = NO;
    if ( self.input && self.session.isRunning ) {
        [self.session stopRunning];
    }
}

- (void)flashStatusChange:(BOOL)isOpen {
    if ([self.input.device hasTorch]) {
        [self.input.device lockForConfiguration:nil];
        self.input.device.torchMode = isOpen ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        [self.input.device unlockForConfiguration];
    }
}

- (CGImageRef)scaledImage:(CGImageRef)imageRef width:(CGFloat)width height:(CGFloat)height {
    CGRect clickRect;
    if (width / scan_screen_width() > height / scan_screen_height()) {
        UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
        CGFloat safeBottomMargin = 0;
        if (@available(iOS 11.0, *)) {
            safeBottomMargin = keyWindow.safeAreaInsets.bottom;
        }
        CGFloat scanBoardWidth = scan_screen_width() - SCANFLOAT(50) * 2 + safeBottomMargin;
        // 1、计短边(高)调整成屏幕长度时另一边的长度
        CGFloat relativeWidth = width * scan_screen_height() / height;
        // 2、计算 左、上 多余距离
        CGFloat newLeft = (relativeWidth - scanBoardWidth) / 2.0 * width / scan_screen_width();
        CGFloat newTop = fabs(height * (150*(325 / 359.0) / scan_screen_height()));      // 顶部间距
        CGFloat newWidth = width - newLeft * 2;
        // 3、计算要裁剪的区域
        clickRect = CGRectMake(newLeft, newTop, newWidth, newWidth);
    } else {
        // 1、计短边(宽)调整成屏幕长度时另一边的长度
        CGFloat relativeHeight = height * scan_screen_width() / width;
        // 2、计算 左、上 多余距离
        CGFloat newLeft = fabs(SCANFLOAT(50) * width / scan_screen_width());
        CGFloat newTop = fabs((relativeHeight - scan_screen_height())) / 2.0 * width / scan_screen_height() + (height * (150*(325 / 359.0) / scan_screen_height()));      // 顶部间距
        CGFloat newWidth = width - newLeft * 2;
        // 3、计算要裁剪的区域
        clickRect = CGRectMake(newLeft, newTop, newWidth, newWidth);
    }
    
    return CGImageCreateWithImageInRect(imageRef, clickRect);
}


#pragma mark - getters


- (ZBarReaderController *)reader {
    if (!_reader) {
        _reader = [[ZBarReaderController alloc] init];
    }
    return _reader;
}

- (CIDetector *)detector {
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    }
    return _detector;
}

- (AVCaptureDevice *)device {
    if (!_device) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

- (AVCaptureVideoDataOutput *)output {
    if (!_output) {
        _output = [[AVCaptureVideoDataOutput alloc] init];
        // 抛弃延迟的帧
        _output.alwaysDiscardsLateVideoFrames = YES;
        _output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        // 开启摄像头采集图像输出的子线程
        dispatch_queue_t outputQueue = dispatch_get_main_queue();// dispatch_queue_create("com.scan.video.sample_queu", DISPATCH_QUEUE_SERIAL);
        // 设置子线程执行代理方法
        [_output setSampleBufferDelegate:self queue:outputQueue];
    }
    return _output;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = CGRectMake(0, 0, scan_screen_width(), scan_screen_height());
    }
    return _previewLayer;
}

#pragma mark - Public Methods

- (NSString *)scanCodeFromImage:(UIImage *)image {
    return [self scanCodeFromCGImageRef:image.CGImage];
}

- (NSString *)scanCodeFromCGImageRef:(CGImageRef)imageRef {
    CGImageRef chooseImageWithRef = imageRef;
    ZBarSymbol *symbol = nil;
    for (symbol in [self.reader scanImage:chooseImageWithRef]) {
        break;
    }
    if (symbol.data.length != 0) {
        return symbol.data;
    } else {
        if ([UIDevice currentDevice].systemVersion.floatValue > 7.99) {
            // 扫描获取的特征组
            NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:imageRef]];
            if (features.count != 0) {
                // 获取扫描结果
                CIQRCodeFeature *feature = [features objectAtIndex:0];
                NSString *scannedResult = feature.messageString;
                return scannedResult;
            }
        }
    }
    return nil;
}

#pragma mark - class Methods

//生成二维码
+ (UIImage *)createQRBarcodeWithString:(NSString *)dataString withSize:(CGSize)size {
    if ([UIDevice currentDevice].systemVersion.floatValue > 7.99) {
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        return [self resizeCodeImage:filter.outputImage withSize:size];
    }
    return nil;
}

//生成条形码
+ (UIImage *)createShapeBarcodeWithString:(NSString *)dataString withSize:(CGSize)size {
    if ([UIDevice currentDevice].systemVersion.floatValue > 7.99) {
        NSData *data = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return [self resizeCodeImage:filter.outputImage withSize:size];
    }
    return nil;
}

/**
 *  调整生成的图片的大小、增加条形码清晰度
 *
 *  @param image CIImage对象
 *  @param size  需要的UIImage的宽度
 *
 *  @return size大小的UIImage对象
 */
+ (UIImage *)resizeCodeImage:(CIImage *)image withSize:(CGSize)size {
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
        
        // 1. 创建bitmap
        size_t width = CGRectGetWidth(extent) * scale;
        size_t height = CGRectGetHeight(extent) * scale;
        CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
        CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
        CGContextScaleCTM(bitmapRef, scale, scale);
        CGContextDrawImage(bitmapRef, extent, bitmapImage);
        
        // 2.保存bitmap图片
        CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
        CGContextRelease(bitmapRef);
        CGImageRelease(bitmapImage);
        return [UIImage imageWithCGImage:scaledImage];
    } else {
        return nil;
    }
}

@end
