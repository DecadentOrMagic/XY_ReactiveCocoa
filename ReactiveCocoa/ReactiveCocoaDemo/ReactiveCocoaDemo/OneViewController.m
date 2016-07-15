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
@property (nonatomic, strong) RACCommand *command;
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




#pragma mark - RACSequence 和 RACTuple 简单使用
- (IBAction)RACSequenceAndRACTupleSimpleUse:(id)sender {
    /**
     *  RACTuple:元组类,类似NSArray,用来包装值.
     *
     *  RACSequence:RAC中的集合类,用于代替NSArray,NSDictionary,可以使用他来快速遍历数组和字典
     *  使用场景:1.字典转模型
     */
    
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    
    // 这里其实是三步
    // 第一步:把数组转化成集合RACSequence numbers.rac_sequence
    // 第二步:把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步:订阅信号,激活信号,会自动把集合中的所有值,遍历出来
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 2.遍历字典,遍历出来的键值对会包装成RATuple(元组对象)
    NSDictionary *dict = @{@"name":@"xmg",@"age":@"18"};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        // 解包元组,会把元组的值,按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        
        // 相当于以下写法
//        NSString *key = x[0];
//        NSString *value = x[1];
        
        NSLog(@"%@ %@",key,value);
    }];
    
//    // 3.字典转模型
//    // 3.1 OC写法
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"" ofType:nil];
//    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
//    NSMutableArray *items = [NSMutableArray array];
//    for (NSDictionary *dict in dictArr) {
//        
//    }
}




#pragma mark - RACCommand 简单使用
- (IBAction)RACCommandSimpleUse:(id)sender {
    /**
     *  RACCommand:RAC中用于处理事件的类,可以把事件如何处理,事件中的数据如何传递,包装到这个类中,他可以很方便的监控事件的执行过程
     *  使用场景:监听按钮点击,网络请求
     *
     *
     **********************************************************************
     *
     *
     *  一.RACCommand使用步骤:
     *  1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
     *  2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
     *  3.执行命令 - (RACSignal *)execute:(id)input
     *
     *
     **********************************************************************
     *
     *
     *  二.RACCommand使用注意:
     *  1.singnalBlock必须要返回一个信号,不能传nil.
     *  2.如果不想要传递信号,直接创建空的信号[RACSignal empty];
     *  3.RACCommand中信号如果数据传递完,必须调用[subscriber sendCompleted],这时命令才会执行完毕,否则永远处于执行中.
     *  4.RACCommand需要被强引用,否则接收不到RACCommand中的信号,因此RACCommand中的信号是延迟发送的.
     *
     *
     **********************************************************************
     *
     *
     *  三.RACCommand设计思想:内部signalBlock为什么要返回一个信号?这个信号有什么用?
     *  1.在RAC开发中,通常会把网络请求封装到RAACommand,直接执行某个RACCommand就能发送请求.
     *  2.在RACCommand内部请求到数据的时候,需要把请求的数据传递给外界,这个时候就需要通过signalBlock返回的信号传递了
     *
     *
     **********************************************************************
     *
     *
     *  四.如何拿到RACCommand中返回信号发出的数据.
     *  1.RACCommand有个执行信号源executionSignals,这个是signal of signals(信号的信号),意思是信号发出的数据是信号,不是普通的类型.
     *  2.订阅executionSignals就能拿到RACCommand中返回的信号,然后订阅signalBlock返回的信号,就能获取发出的值
     *
     *
     *  五.监听当前命令是否正在执行executing
     *
     *
     *  六.使用场景,监听按钮点击,网络请求
     */
    
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        
        // 创建空信号,必须返回信号
//        return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"请求数据"];
            
            // 注意:数据传递完,最好调用sendCompleted,这时命令才执行完毕
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    // 强引用命令,不要被销毁,否则接收不到数据
    _command = command;
    
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@",x);
        }];
    }];
    
    // RAC高级用法
    // switchToLatest:用于signal of signals,获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    // 4.监听命令是否执行完毕,默认会来一次,可以直接跳过,skip表示跳过第一次信号
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            // 正在执行
            NSLog(@"正在执行");
        }
        else {
            // 执行完成
            NSLog(@"执行完成");
        }
    }];
    
    // 5.执行命令
    [self.command execute:@1];
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
