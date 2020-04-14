//
//  FFScanningPermissions.h
//  MamHao
//
//  Created by egg on 2017/4/27.
//  Copyright © 2017年 Mamahao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFScanningPermissions : NSObject

/**
 获取相机权限

 @return 相机权限
 */
+ (BOOL)isGetCameraPermission;

/**
 播放音频

 @param fileName 音频文件名称
 @param isAlert 是否震动
 */
+ (void)playAudio:(NSString *)fileName isAlert:(BOOL)isAlert;

@end
