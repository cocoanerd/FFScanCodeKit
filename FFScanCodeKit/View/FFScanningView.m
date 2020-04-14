//
//  FFScanningView.m
//  MamHao
//
//  Created by egg on 2017/4/20.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import "FFScanningView.h"
#import "FFScanWrapper.h"
#import "FFScanRelative.h"
#import "Masonry.h"

#import <Foundation/Foundation.h>

@interface FFScanningView () <UITextFieldDelegate, FFScanWrapperDelegate>
/** 顶部扫描框*/
@property (nonatomic, strong) UIImageView *scanningTopBackgroundImageView;
/** 中间扫描框*/
@property (nonatomic, strong) UIImageView *scanningMiddleBackgroundImageView;
/** 底部扫描框*/
@property (nonatomic, strong) UIImageView *scanningBottomBackgroundImageView;
/** 扫一扫标题*/
@property (nonatomic, strong) UILabel *scanningTitle;
/** 开灯按钮*/
@property (nonatomic, strong) UIButton *lightButton;
/** 提示文字*/
@property (nonatomic, strong) UILabel *labelBarcodeTitle;
/** 创建输入条形码按钮*/
@property (nonatomic, strong) UIButton *inputBarCodeButton;
/** 相册按钮*/
@property (nonatomic, strong) UIButton *chooseAssetButton;
/** 请输入条形码*/
@property (nonatomic, strong) UITextField *inputBarCodeTextField;
/** 扫描线*/
@property (nonatomic, strong) UIView *viewLine;
/** 返回按钮*/
@property (nonatomic, strong) UIButton *dismissBtn;
/** 关闭相机的时间*/
@property (nonatomic, assign) NSInteger closeCameraTime;
/** 关闭相机定时器*/
@property (nonatomic, strong) NSTimer *closeCameraTimer;
/** 扫描线定时器*/
@property (nonatomic, strong) NSTimer *scanningIndicatorLineAnimationTimer;
/** 是否是扫码模式 是：YES  否：NO*/
@property (nonatomic, assign) BOOL isScanningMode;

@end

@implementation FFScanningView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isScanningMode = YES;
        self.backgroundColor = [UIColor blackColor];
        [self setSubviews];
        [self addUIConstraints];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)setSubviews {
    [self addSubview:self.viewLine];
    [self addSubview:self.scanningTopBackgroundImageView];
    [self addSubview:self.scanningMiddleBackgroundImageView];
    [self addSubview:self.scanningBottomBackgroundImageView];
    [self addSubview:self.labelBarcodeTitle];
    [self addSubview:self.dismissBtn];
    [self addSubview:self.scanningTitle];
    [self addSubview:self.lightButton];
    [self addSubview:self.inputBarCodeButton];
    [self addSubview:self.chooseAssetButton];
    [self addSubview:self.inputBarCodeTextField];
}

- (void)addUIConstraints {
    [self.scanningTopBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(SCANFLOAT(150));
    }];
    [self.scanningMiddleBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.scanningTopBackgroundImageView.mas_bottom);
        make.height.mas_equalTo(SCANFLOAT(265 - 20));
    }];
    [self.scanningBottomBackgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(self.scanningMiddleBackgroundImageView.mas_bottom);
    }];
    [self.labelBarcodeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.scanningTopBackgroundImageView.mas_bottom).offset(- SCANFLOAT(6) - 40);
    }];
    [self.dismissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(ScanStatusBarHeight());
        make.width.height.mas_equalTo(40);
    }];
    [self.scanningTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(ScanStatusBarHeight());
        make.height.mas_equalTo(40);
    }];
    [self.lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.scanningBottomBackgroundImageView.mas_top).offset(32);
        make.width.height.mas_equalTo(SCANFLOAT(51));
    }];
    [self.inputBarCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SCANFLOAT(40));
        make.top.mas_equalTo(self.lightButton.mas_bottom).offset(32);
        make.width.mas_equalTo(SCANFLOAT(125));
        make.height.mas_equalTo(SCANFLOAT(40));
    }];
    [self.chooseAssetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-SCANFLOAT(40));
        make.top.mas_equalTo(self.inputBarCodeButton);
        make.width.mas_equalTo(SCANFLOAT(125));
        make.height.mas_equalTo(SCANFLOAT(40));
    }];
    [self.inputBarCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(self.scanningTopBackgroundImageView.mas_bottom).offset(-15 / 180.0 * 150);
        make.width.mas_equalTo(SCANFLOAT(265));
        make.height.mas_equalTo(38);
    }];
}


#pragma mark - UItextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (self.inputBarCodeTextField == textField) {
        if ([toBeString length] > 0) {
            if (toBeString.length >= 30) {
                textField.text = [toBeString substringToIndex:30];
                textField.text = ScanFilterChineseiRegex(textField.text);
                return NO;
            }
            [self.chooseAssetButton setBackgroundColor:[UIColor whiteColor]];
            [self.chooseAssetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
            return YES;
        }
        else {
            [self.chooseAssetButton setBackgroundColor:[UIColor clearColor]];
            [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
            return YES;
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //过滤非汉字字符
    textField.text = ScanFilterChineseiRegex(textField.text);
    return NO;
}


- (void)textFieldChanged:(UITextField *)textField {
    
    UITextRange *selectedRange = textField.markedTextRange;
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) { //// 没有高亮选择的字
        //过滤非汉字字符
        textField.text = ScanFilterChineseiRegex(textField.text);
    }else { //有高亮文字
        //do nothing
    }
    [self updateChooseAssetButton];
}


#pragma mark - FFScanWrapperDelegate
- (void)scanWrapper:(FFScanWrapper *)scanWrapper scanResult:(NSString *)scanResult {
    // 扫码界面是否有效
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(scanningViewIsVisible)]) {
        if (![self.dataSource scanningViewIsVisible]) {
            return;
        }
    }
    // 处理扫描得到的结果内容
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanningViewDirectionalWithCode:)]) {
        [self.delegate scanningViewDirectionalWithCode:scanResult];
    }
}


#pragma mark - event rensponse
/// 取消输入框第一响应
- (void)tapOnceHideKeyBoard {
    if ([self.inputBarCodeTextField isFirstResponder]) {
        [self.inputBarCodeTextField resignFirstResponder];
    }
}

/// 点击返回按钮
- (void)dismissAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanningViewDismissHandle:)]) {
        [self.delegate scanningViewDismissHandle:self];
    }
}

/// 打开或关闭闪光灯
- (void)turnOnOrTurnOffTheLight {
    self.lightButton.selected = !self.lightButton.selected;
    [self.scanWrapper flashStatusChange:self.lightButton.selected];
}

/// 点击输入条形码
- (void)inputBarCodeClick {
    [self inputBarCodeAnimation];
    self.isScanningMode = !self.isScanningMode;
    
    if (self.isScanningMode) {
        self.viewLine.hidden = NO;
        [self startScan];
    }
    else {
        self.viewLine.hidden = YES;
        [self stopScan];
    }
}

/// 调起系统相册，选择照片事件
- (void)chooseAlAssetClick {
    if (self.isScanningMode) {
        // 调起系统相册
        if (self.delegate && [self.delegate respondsToSelector:@selector(scanningViewChooseAlAssetHandle:)]) {
            [self.delegate scanningViewChooseAlAssetHandle:self];
        }
        self.scanningIndicatorLineOffset = 0;
    }
    else {
        //输入条形码，点击确定按钮
        if (self.inputBarCodeTextField.text.length != 0) {
            [self.inputBarCodeTextField endEditing:YES];
            // 处理手动输入条形码内容
            if (self.delegate && [self.delegate respondsToSelector:@selector(scanningViewDirectionalWithCode:)]) {
                [self.delegate scanningViewDirectionalWithCode:self.inputBarCodeTextField.text];
            }
        } else {
            [FFScanRelative pleaseInputBarCodeAlert];
        }
    }
}

#pragma mark - Notification
- (void)applicationDidEnterBackground {
    self.lightButton.selected = NO;
}

#pragma mark - animation
// 条形码动画
- (void)inputBarCodeAnimation {
    if (self.isScanningMode) {
        [self.scanningMiddleBackgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
        }];
        [self.inputBarCodeButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lightButton.mas_bottom).offset(-32);
        }];
    } else {
        [self.scanningMiddleBackgroundImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo((SCANFLOAT(265) - 20));
        }];
        [self.inputBarCodeButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lightButton.mas_bottom).offset(32);
        }];
    }
    [UIView animateWithDuration:.5f animations:^{
        [self layoutIfNeeded];
        if (self.isScanningMode) {
            self.inputBarCodeTextField.alpha = 1;
            self.lightButton.alpha = 0;
            self.labelBarcodeTitle.text = @"请输入商品条码";
            self.labelBarcodeTitle.textAlignment = NSTextAlignmentCenter;
            [self.inputBarCodeButton setTitle:@"切换到扫码" forState:UIControlStateNormal];
            [self.chooseAssetButton setTitle:@"确定" forState:UIControlStateNormal];
            
            if (self.inputBarCodeTextField.text.length) {
                [self.chooseAssetButton setBackgroundColor:[UIColor greenColor]];
                [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.chooseAssetButton.layer.borderColor = [UIColor greenColor].CGColor;
            }
            else {
                [self.chooseAssetButton setBackgroundColor:[UIColor clearColor]];
                [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
            }
        }
        else {
            self.labelBarcodeTitle.text = @"请将二维码/条形码放到框内";
            self.labelBarcodeTitle.textAlignment = NSTextAlignmentCenter;
            self.inputBarCodeTextField.alpha = 0;
            self.lightButton.alpha = 1;
            [self.inputBarCodeButton setTitle:@"输入条形码" forState:UIControlStateNormal];
            [self.chooseAssetButton setTitle:@"从相册中选" forState:UIControlStateNormal];
            [self.chooseAssetButton setBackgroundColor:[UIColor clearColor]];
            [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
            
            self.scanningIndicatorLineOffset = 0;
            self.scanningIndicatorLineIsGoingUp = NO;
        }
        CGRect frame = self.chooseAssetButton.frame;
        frame.origin.y = self.inputBarCodeButton.frame.origin.y;
        self.chooseAssetButton.frame = frame;
    } completion:^(BOOL finished) {
        if (self.isScanningMode) {
            self.inputBarCodeTextField.hidden = YES;
            self.lightButton.hidden = NO;
            if ([self.inputBarCodeTextField isFirstResponder]) {
                [self.inputBarCodeTextField resignFirstResponder];
            }
        }
        else {
            self.inputBarCodeTextField.hidden = NO;
            self.lightButton.hidden = YES;
            [self.inputBarCodeTextField becomeFirstResponder];
        }
    }];
}

/// 开始扫描线动画
- (void)beginLineAnimation {
    if (self.scanningIndicatorLineIsGoingUp == NO) {
        self.scanningIndicatorLineOffset++;
        [self.viewLine setFrame:CGRectMake((scan_screen_width() - SCANFLOAT(265)) * 0.5f + 10, CGRectGetMaxY(self.scanningTopBackgroundImageView.frame) + 2 * self.scanningIndicatorLineOffset, SCANFLOAT(265 - 20), 1)];
        if (2 * self.scanningIndicatorLineOffset >= self.scanningMiddleBackgroundImageView.bounds.size.height) {
            self.scanningIndicatorLineIsGoingUp = YES;
        }
    }
    else {
        self.scanningIndicatorLineOffset--;
        [self.viewLine setFrame:CGRectMake((scan_screen_width() - SCANFLOAT(265)) * 0.5f + 10, CGRectGetMaxY(self.scanningTopBackgroundImageView.frame) + 2 * self.scanningIndicatorLineOffset, SCANFLOAT(265 - 20), 1)];
        if (self.scanningIndicatorLineOffset == 0) {
            self.scanningIndicatorLineIsGoingUp = NO;
        }
    }
}


#pragma mark - private methods

/// 更新chooseAssetButton按钮样式
- (void)updateChooseAssetButton {
    if (self.inputBarCodeTextField.text.length > 0) {
        [self.chooseAssetButton setBackgroundColor:[UIColor greenColor]];
        [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.chooseAssetButton.layer.borderColor = [UIColor greenColor].CGColor;
    }
    else {
        [self.chooseAssetButton setBackgroundColor:[UIColor clearColor]];
        [self.chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}


#pragma mark - public methods
/// 开始扫描
- (void)startScan {
    if (!self.isScanningMode) {
        return;
    }
    
    self.isRedirect = NO;
    [self.scanWrapper starScan];
    
    if (!self.closeCameraTimer) {
        self.closeCameraTime = 60;
        self.closeCameraTimer = [NSTimer scheduledTimerWithTimeInterval:self.closeCameraTime target:self selector:@selector(closeCameraAnimation) userInfo:nil repeats:YES];
    }
}

/// 停止扫描
- (void)stopScan {
    self.isRedirect = YES;
    [self.scanWrapper stopScan];
    self.lightButton.selected = NO;
    
    if (self.closeCameraTimer) {
        [self.closeCameraTimer invalidate];
        self.closeCameraTimer = nil;
    }
}

/// 开始扫描线动画
- (void)startLineAnimation {
    self.scanningIndicatorLineAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(beginLineAnimation) userInfo:nil repeats:YES];
}

/// 停止扫描线动画
- (void)stopLineAnimation {
    if (self.scanningIndicatorLineAnimationTimer) {
        [self.scanningIndicatorLineAnimationTimer invalidate];
        self.scanningIndicatorLineAnimationTimer = nil;
    }
}

/// 关闭相机定时器
- (void)closeCameraAnimation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(scanningViewDismissHandle:)]) {
        [self.delegate scanningViewDismissHandle:self];
    }
}


#pragma mark - getters


- (FFScanWrapper *)scanWrapper {
    if (!_scanWrapper) {
        _scanWrapper = [[FFScanWrapper alloc] initWithVideoPreView:self];
        _scanWrapper.delegate = self;
    }
    return _scanWrapper;
}

- (UIView *)viewLine {
    if (!_viewLine) {
        _viewLine = [[UIView alloc] init];
        _viewLine.backgroundColor = [UIColor greenColor];
    }
    return _viewLine;
}

- (UIImageView *)scanningTopBackgroundImageView {
    if (!_scanningTopBackgroundImageView) {
        _scanningTopBackgroundImageView = [[UIImageView alloc] init];
        _scanningTopBackgroundImageView.image = ScanViewTopBackgroundImage();
    }
    return _scanningTopBackgroundImageView;
}

- (UIImageView *)scanningMiddleBackgroundImageView {
    if (!_scanningMiddleBackgroundImageView) {
        _scanningMiddleBackgroundImageView = [[UIImageView alloc] init];
        _scanningMiddleBackgroundImageView.image = ScanViewMiddleBackgroundImage();
    }
    return _scanningMiddleBackgroundImageView;
}

- (UIImageView *)scanningBottomBackgroundImageView {
    if (!_scanningBottomBackgroundImageView) {
        _scanningBottomBackgroundImageView = [[UIImageView alloc] init];
        _scanningBottomBackgroundImageView.userInteractionEnabled = YES;
        UIImage *stretchableImage = [ScanViewBottomBackgroundImage() stretchableImageWithLeftCapWidth:0 topCapHeight:ScanViewBottomBackgroundImage().size.height * 0.99];
        _scanningBottomBackgroundImageView.image = stretchableImage;
        UITapGestureRecognizer *tapForHideKeyBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnceHideKeyBoard)];
        [_scanningBottomBackgroundImageView addGestureRecognizer:tapForHideKeyBoard];
    }
    return _scanningBottomBackgroundImageView;
}

- (UILabel *)labelBarcodeTitle {
    if (!_labelBarcodeTitle) {
        _labelBarcodeTitle = [[UILabel alloc] init];
        _labelBarcodeTitle.font = [UIFont systemFontOfSize:14];
        _labelBarcodeTitle.textColor = [UIColor whiteColor];
        [_labelBarcodeTitle setText:@"请将二维码/条形码放到框内"];
    }
    return _labelBarcodeTitle;
}

- (UIButton *)dismissBtn {
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.tintColor = [UIColor whiteColor];
        [_dismissBtn setImage:[ScanViewDismissBtnImage() imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_dismissBtn addTarget:self action:@selector(dismissAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissBtn;
}

- (UILabel *)scanningTitle {
    if (!_scanningTitle) {
        _scanningTitle = [[UILabel alloc] init];
        _scanningTitle.text = @"扫一扫";
        _scanningTitle.font = [UIFont boldSystemFontOfSize:16.];
        _scanningTitle.textColor = [UIColor whiteColor];
        _scanningTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _scanningTitle;
}

- (UIButton *)lightButton {
    if (!_lightButton) {
        _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lightButton setImage:ScanViewLightOffBtnImage() forState:UIControlStateNormal];
        [_lightButton setImage:ScanViewLightOnBtnImage() forState:UIControlStateSelected];
        [_lightButton addTarget:self action:@selector(turnOnOrTurnOffTheLight) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightButton;
}

- (UIButton *)inputBarCodeButton {
    if (!_inputBarCodeButton) {
        _inputBarCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inputBarCodeButton addTarget:self action:@selector(inputBarCodeClick) forControlEvents:UIControlEventTouchUpInside];
        [_inputBarCodeButton setTitle:@"输入条形码" forState:UIControlStateNormal];
        _inputBarCodeButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _inputBarCodeButton.layer.borderWidth = 1.0f;
        _inputBarCodeButton.layer.cornerRadius = SCANFLOAT(20);
        _inputBarCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_inputBarCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _inputBarCodeButton;
}

- (UIButton *)chooseAssetButton {
    if (!_chooseAssetButton) {
        _chooseAssetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chooseAssetButton addTarget:self action:@selector(chooseAlAssetClick) forControlEvents:UIControlEventTouchUpInside];
        [_chooseAssetButton setTitle:@"从相册中选" forState:UIControlStateNormal];
        _chooseAssetButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _chooseAssetButton.layer.borderWidth = 1.0f;
        _chooseAssetButton.layer.cornerRadius = SCANFLOAT(20);
        _chooseAssetButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_chooseAssetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _chooseAssetButton;
}

- (UITextField *)inputBarCodeTextField {
    if (!_inputBarCodeTextField) {
        _inputBarCodeTextField = [[UITextField alloc] init];
        _inputBarCodeTextField.backgroundColor = [UIColor whiteColor];
        _inputBarCodeTextField.placeholder = @"请输入条形码";
        _inputBarCodeTextField.delegate = self;
        _inputBarCodeTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_inputBarCodeTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        _inputBarCodeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _inputBarCodeTextField.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
        _inputBarCodeTextField.hidden = YES;
        _inputBarCodeTextField.textColor = [UIColor blackColor];
    }
    return _inputBarCodeTextField;
}

@end
