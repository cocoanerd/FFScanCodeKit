//
//  FFViewController.m
//  FFScanCodeKit
//
//  Created by Cocoanerd on 04/14/2020.
//  Copyright (c) 2020 Cocoanerd. All rights reserved.
//

#import "FFViewController.h"
#import "FFScanningViewController.h"

@interface FFViewController ()

@end

@implementation FFViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 200, 200)];
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"扫码" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)btnClicked {
    FFScanningViewController *scanVC = [[FFScanningViewController alloc] init];
    
    scanVC.scanResultBlock = ^(FFScanningViewController *viewController, NSString *scanCode) {
        // 这里可以根据model.type进行处理
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:scanCode message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [viewController startScan];
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    };
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
