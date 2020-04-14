//
//  FFScanningPermissions.m
//  MamHao
//
//  Created by egg on 2017/4/27.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import "FFScanningPermissions.h"
#import <AVFoundation/AVFoundation.h>

@implementation FFScanningPermissions

#pragma mark - 扫码权限

+ (BOOL)isGetCameraPermission {
    AVAuthorizationStatus authStaus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStaus != AVAuthorizationStatusDenied) {
        return YES;
    }
    return NO;
}

#pragma mark - 播放音频

+ (void)playAudio:(NSString *)fileName isAlert:(BOOL)isAlert {
    SystemSoundID soundsId;
    NSURL *url = [[NSBundle mainBundle ] URLForResource:fileName withExtension:nil];
    if (url) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundsId);
        if (isAlert) {
            AudioServicesPlayAlertSound(soundsId);
        } else {
            AudioServicesPlaySystemSound(soundsId);
        }
    }
}

@end

