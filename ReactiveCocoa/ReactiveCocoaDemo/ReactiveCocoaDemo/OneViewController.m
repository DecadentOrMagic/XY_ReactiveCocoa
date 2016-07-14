//
//  OneViewController.m
//  ReactiveCocoaDemo
//
//  Created by 薛尧 on 16/7/14.
//  Copyright © 2016年 Dom. All rights reserved.
//

#import "OneViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TwoViewController.h"

@interface OneViewController ()

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"OneVC";
}

#pragma mark - RACSiganl 简单使用
- (IBAction)RACSiganlSimpleUse:(id)sender {
    /**
     *  在RAC中最核心的类 RACSiganl ,搞定这个类就能用ReactiveCocoa开发了
     *
     *  RACSiganl:信号类,一般表示将来有数据传递,只要有数据改变,信号内部接收到数据,就会马上发出数据
     *
     *  注意:
     *  信号类(RACSiganl),只是表示当数据改变时,信号内部会发出数据,它本身不具备发送信号的能力,而是交给内部一个订阅者去发出.
     *  默认一个信号都是冷信号,也就是值改变了,也不会触发,只有订阅了这个信号,这个信号才会变成热信号,值改变才会触发
     *  如何订阅信号:调用信号RACSignal的subscribeNext就能订阅
     *
     *
     **********************************************************************
     *
     *
     *  RACSignal使用步骤:
     *  1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
     *  2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     *  3.发送信号 - (void)sendNext:(id)value
     *
     *
     **********************************************************************
     *
     *
     *  RACSignal底层实现
     *  1.创建信号,首先把didSubscribe保存到信号中,还不会触发.
     *  2.当信号被订阅,也就是调用singal的subscribeNext:nextBlock
     *  2.2 subscribeNext内部会创建订阅者subscriber,并且把nextBlock保存到subscriber中.
     *  2.1 subscribeNext内部会调用siganl的didSubscribe
     *  3.siganl的didSubscribe中调用[subscriber sendNext:@1];
     *  3.1 sendNext底层其实就是执行subscriber的nextBlock
     */
    
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block调用时刻:每当有订阅者订阅信号,就会调用block
        
        // 2.发送信号
        [subscriber sendNext:@1];
        
        // 如果不在发送数据,最好发送信号完成,内部会自动调用[RACDisposable disposable]取消订阅信号.
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            // block调用时刻:当信号发送完成或者发送错误,就会自动执行这个block,取消订阅信号
            // 执行完block后,当前信号就不再被订阅了.
            NSLog(@"信号被销毁");
        }];
    }];
    
    // 3.订阅信号,才会激活信号
    [siganl subscribeNext:^(id x) {
        // block调用时刻:每当有信号发出数据,就会调用block
        NSLog(@"接收到数据:%@",x);
    }];
    
    /**
     *  RACSubscriber:表示订阅者的意思,用于发送信号,这是一个协议,不是一个类,只要遵守这个协议,并且实现方法才能成为订阅者.通过create创建的信号,都有一个订阅者帮他发送数据
     *  RACDisposable:用于取消订阅或者清理资源,当信号发送完成或者发送错误的时候,就会触发它
     */
}


#pragma mark - RACSubject 简单使用
- (IBAction)RACSubjectSimpleUse:(id)sender {
    /**
     *  RACSubject:信号提供者,自己可以充当信号,又能发送信号.使用场景:通常用来代替代理,有了它,就不必要定义代理了.
     *
     *
     **********************************************************************
     *
     *
     *  RACSubject使用步骤
     *  1.创建信号 [RACSubject subject],跟RACSiganl不一样,创建信号时没有block
     *  2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     *  3.发送信号 sendNext:(id)value
     *
     *
     **********************************************************************
     *
     *
     *  RACSubject:底层实现和RACSignal不一样
     *  1.调用subscribeNext订阅信号,只是把订阅者保存起来,并且订阅者的nextBlock已经赋值了.
     *  2.调用sendNext发送信号,遍历刚刚保存的所有订阅者,一个一个调用订阅者的nextBlock.
     */
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻:当信号发出新值,就会调用
        NSLog(@"第一个订阅者 %@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻:当信号发出新值,就会调用
        NSLog(@"第二个订阅者 %@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"1"];
    
}


#pragma mark - RACReplaySubject简单使用
- (IBAction)RACReplaySubjectSimpleUse:(id)sender {
    /**
     *  RACReplaySubject:重复提供信号类,RACSubject的子类
     *
     *  RACReplaySubject 与 RACSubject 区别
     *  RACReplaySubject可以先发送信号,再订阅信号,RACSubject就不可以
     *
     *  使用场景一:如果一个信号每被订阅一次,就需要把之前的值重复发送一遍,使用重复提供信号类
     *  使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓冲最近的几个值
     *
     *
     **********************************************************************
     *
     *
     *  RACReplaySubject使用步骤:
     *  1.创建信号 [RACSubject subject],跟RACSiganl不一样，创建信号时没有block.
     *  2.可以先订阅信号，也可以先发送信号.
     *  2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
     *  2.2 发送信号 sendNext:(id)value
     *
     *
     **********************************************************************
     *
     *
     *  RACReplaySubject:底层实现和RACSubject不一样
     *  1.调用sendNext发送信号,把值保存起来，然后遍历刚刚保存的所有订阅者,一个一个调用订阅者的nextBlock.
     *  2.2.调用subscribeNext订阅信号,遍历保存的所有值,一个一个调用订阅者的nextBlock
     *
     *  如果想当一个信号被订阅,就重复播放之前的所有值,需要先发送信号,再订阅信号.
     *  也就是先保存值,再订阅值
     */
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    
    // 2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    // 3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者接收到额数据%@",x);
    }];
}


// 步骤三:在第一个控制器(OneVC)中,监听跳转按钮,给第二个控制器的代理信号赋值,并且监听.
#pragma mark - RACSubject 替代代理
- (IBAction)pushTwoVC:(id)sender {
    // 需求:
    // 1.给当前控制器(OneVC)添加一个按钮,push到另一个控制器界面
    // 2.另一个控制器(TwoVC)view中有个按钮,点击按钮,通知当前控制器
    
    
    TwoViewController *twoVC = [[TwoViewController alloc] init];
    
    // 设置代理信号
    twoVC.delegateSignal = [RACSubject subject];
    // 订阅代理信号
    [twoVC.delegateSignal subscribeNext:^(id x) {
        NSLog(@"点击了通知按钮");
    }];
    
    [self.navigationController pushViewController:twoVC animated:YES];
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
