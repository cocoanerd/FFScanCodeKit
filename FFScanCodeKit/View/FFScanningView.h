//
//  FFScanningView.h
//  MamHao
//
//  Created by egg on 2017/4/20.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FFScanningView;
@class FFScanWrapper;

@protocol FFScanningViewDelegate <NSObject>

/**
 点击返回按钮回调

 @param scanningView FFScanningView
 */
- (void)scanningViewDismissHandle:(FFScanningView *)scanningView;

/**
 打开相册

 @param scanningView FFScanningView
 */
- (void)scanningViewChooseAlAssetHandle:(FFScanningView *)scanningView;

/**
 获得扫描内容

 @param barCode FFScanningView
 */
- (void)scanningViewDirectionalWithCode:(NSString *)barCode;

@end

@protocol FFScanningViewDataSource <NSObject>

/**
 扫码界面是否有效

 @return YES:有效 NO:无效
 */
- (BOOL)scanningViewIsVisible;

@end

@interface FFScanningView : UIView

@property (nonatomic, weak) id<FFScanningViewDelegate> delegate;
@property (nonatomic, weak) id<FFScanningViewDataSource> dataSource;

/** 扫描线偏移量*/
@property (nonatomic, assign) NSInteger scanningIndicatorLineOffset;
/** 扫描线向上移动*/
@property (nonatomic, assign) BOOL scanningIndicatorLineIsGoingUp;
/** 防止重复跳转*/
@property (nonatomic, assign) BOOL isRedirect;
/** 扫码界面*/
@property (nonatomic, strong) FFScanWrapper *scanWrapper;

/** 开始扫描*/
- (void)startScan;
/** 停止扫描*/
- (void)stopScan;

/** 扫描线开始动画*/
- (void)startLineAnimation;
/** 扫描线停止动画*/
- (void)stopLineAnimation;

@end
