//
//  FFScanRelative.m
//  FFScanCodeKit
//
//  Created by FF on 2020/4/13.
//

#import "FFScanRelative.h"

@implementation FFScanRelative

CGFloat scan_screen_width()
{
    return ([[UIScreen mainScreen] bounds].size.width);
}

CGFloat scan_screen_height()
{
    return ([[UIScreen mainScreen] bounds].size.height);
}

CGFloat SCANFLOAT(CGFloat floatValue)
{
    CGFloat currentScreenWidth = scan_screen_width();
    CGFloat standardScreenWidth = 375.0f;
    return floorf(floatValue / standardScreenWidth * currentScreenWidth);
}

CGFloat ScanStatusBarHeight()
{
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    if (@available(iOS 11.0, *)) {
        return keyWindow.safeAreaInsets.bottom == 0 ? 20: 44;
    }
    return 20;
}

UIImage* ScanViewTopBackgroundImage() {
    return [UIImage imageNamed:@"scan-code_img_on" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}

UIImage* ScanViewMiddleBackgroundImage() {
    return [UIImage imageNamed:@"scan-code_img_middle" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}

UIImage* ScanViewBottomBackgroundImage() {
    return [UIImage imageNamed:@"scan-code_img_down" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}

UIImage* ScanViewDismissBtnImage() {
    return [UIImage imageNamed:@"basc_nav_back" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}

UIImage* ScanViewLightOnBtnImage() {
    return [UIImage imageNamed:@"scan-code_btn_click" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}


UIImage* ScanViewLightOffBtnImage() {
    return [UIImage imageNamed:@"scan-code_btn_flashlight" inBundle:[NSBundle bundleWithURL:[[NSBundle bundleForClass:NSClassFromString(@"FFScanRelative")] URLForResource:@"FFScanCodeKit" withExtension:@"bundle"]] compatibleWithTraitCollection:nil];
}

NSString* ScanFilterChineseiRegex(NSString *str) {
    NSString *searchText = str;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\u4e00-\u9fa5]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}

+ (void)openCameraPermissionAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请在iPhone的“设置-隐私-相机”选项中，允许程序访问你的相机" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


+ (void)videoPreViewInitFailedAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫码界面初始化失败" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)pleaseInputBarCodeAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入条形码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
