//
//  FFScanningViewController.m
//  MamHao
//
//  Created by SmartMin on 15/5/19.
//  Copyright (c) 2015年 Mamhao. All rights reserved.
//

#import "FFScanningViewController.h"
#import "FFScanningPermissions.h"
#import "FFScanningView.h"
#import "FFScanWrapper.h"
#import "Masonry.h"

@interface FFScanningViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, FFScanningViewDelegate, FFScanningViewDataSource>

/** 自定义扫码界面*/
@property (nonatomic, strong) FFScanningView *scannerView;
/** 是否需要激活扫码器*/
@property (nonatomic, assign) BOOL needActivationScan;
    
@end

@implementation FFScanningViewController


#pragma mark - life circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scannerView.scanningIndicatorLineOffset = 0;
    self.scannerView.scanningIndicatorLineIsGoingUp = NO;
    [self.scannerView startLineAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needActivationScan) {
        [self startScan];
    }
    self.needActivationScan = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scannerView stopScan];
    [self.scannerView stopLineAnimation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.needActivationScan = YES;
    [self setSubviews];
}


#pragma mark - UI


- (void)setSubviews {
    [self.view addSubview:self.scannerView];
    [self.scannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - 开始扫码
- (void)startScan {
    [self.scannerView startScan];
}

#pragma mark - 获取图片

/// 打开相册
- (void)getImageFromPhotoLibrary {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark - FFScanningViewDelegate


- (void)scanningViewDismissHandle:(FFScanningView *)scanningView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scanningViewChooseAlAssetHandle:(FFScanningView *)scanningView {
    [self getImageFromPhotoLibrary];
}

- (void)scanningViewDirectionalWithCode:(NSString *)barCode {
    self.scannerView.isRedirect = NO;
    [self directionalWithCode:barCode];
}


#pragma mark - FFScanningViewDataSource
/// 扫描界面是否有效
- (BOOL)scanningViewIsVisible {
    return self.isViewLoaded && self.view.window;
}

#pragma mark - UIImagePickerControllerDelegate
// 相册选择图片回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image  = info[UIImagePickerControllerOriginalImage];
    self.needActivationScan = NO;
    self.scannerView.isRedirect = NO;
    // 读取选择的图片
    [self directionalWithCode:[self.scannerView.scanWrapper scanCodeFromImage:image]];
}


#pragma mark - 直接失败验证码

- (void)directionalWithCode:(NSString *)symbolString {
    // 扫码内容为空
    if (symbolString.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"照片中未发现二维码" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self startScan];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    if (self.scannerView.isRedirect) {
        return;
    }
    [self.scannerView stopScan];
    // 扫码界面不处理扫码内容
    if (self.scanResultBlock) {
        self.scanResultBlock(self, symbolString);
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - getters

- (FFScanningView *)scannerView {
    if (!_scannerView) {
        _scannerView = [[FFScanningView alloc] init];
        _scannerView.delegate = self;
    }
    return _scannerView;
}

@end
