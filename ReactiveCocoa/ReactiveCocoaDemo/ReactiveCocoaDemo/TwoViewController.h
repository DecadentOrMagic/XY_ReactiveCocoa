//
//  TwoViewController.h
//  ReactiveCocoaDemo
//
//  Created by 薛尧 on 16/7/14.
//  Copyright © 2016年 Dom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

// 需求:
// 1.给当前控制器(OneVC)添加一个按钮,push到另一个控制器界面
// 2.另一个控制器(TwoVC)view中有个按钮,点击按钮,通知当前控制器

// 步骤一:在第二个控制器.h,添加一个RACSuject代替代理
@interface TwoViewController : UIViewController

@property (nonatomic, strong) RACSubject *delegateSignal;

@end
