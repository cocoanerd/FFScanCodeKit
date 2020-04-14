//
//  FFScanRelative.h
//  FFScanCodeKit
//
//  Created by FF on 2020/4/13.
//

#import <Foundation/Foundation.h>

@interface FFScanRelative : NSObject

/// 屏幕宽度
extern CGFloat scan_screen_width(void);
/// 屏幕高度
extern CGFloat scan_screen_height(void);

/// 比例
/// @param floatValue value
extern CGFloat SCANFLOAT(CGFloat floatValue);

/// 状态栏高度
extern CGFloat ScanStatusBarHeight(void);

/// 图片资源
extern UIImage* ScanViewTopBackgroundImage(void);
extern UIImage* ScanViewMiddleBackgroundImage(void);
extern UIImage* ScanViewBottomBackgroundImage(void);
extern UIImage* ScanViewDismissBtnImage(void);
extern UIImage* ScanViewLightOnBtnImage(void);
extern UIImage* ScanViewLightOffBtnImage(void);


/// 过滤非汉字字符
/// @param str 源字符串
extern NSString * ScanFilterChineseiRegex(NSString *str);

/// 打开相机权限弹窗
+(void)openCameraPermissionAlert;

/// 扫描界面初始化失败弹窗
+(void)videoPreViewInitFailedAlert;

/// 请输入条形码弹窗
+(void)pleaseInputBarCodeAlert;

@end
