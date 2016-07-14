//
//  TwoViewController.m
//  ReactiveCocoaDemo
//
//  Created by 薛尧 on 16/7/14.
//  Copyright © 2016年 Dom. All rights reserved.
//

#import "TwoViewController.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"TwoVC";
}

// 步骤二:监听第二个控制器按钮点击
#pragma mark - 通知当前控制器
- (IBAction)notice:(id)sender {
    // 通知第一个控制器(OneVC),告诉它,按钮被点了
    
    // 通知代理
    // 判断代理信号是否有值
    if (self.delegateSignal) {
        // 有值,才需要通知
        [self.delegateSignal sendNext:nil];
    }
}





















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
