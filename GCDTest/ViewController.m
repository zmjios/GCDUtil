//
//  ViewController.m
//  GCDTest
//
//  Created by zmjios on 15/10/29.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import "ViewController.h"
#import "CustomOperation.h"
#import "CustomeTimer.h"
#import "NSObject+gcd.h"


@interface ViewController ()
{
    void *queueTag;
}


@property (nonatomic, strong) NSString *mystring;
@property (nonatomic, strong) NSMutableArray *operationArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    

    
    NSInteger a = 100;
    a++;
    
    NSLog(@"a = %ld",a);
    
    
    self.mystring = @"test";
    self.operationArray = [NSMutableArray array];
    
    
//[self test222];
    
    
   // [self testforsemaphore];
    
    
    //[self testForSemaphore2];
    
    //[self testForSemaphore3];
    
    //[self testforbarrier];
    
    
//    __block NSInteger iCount = 0;
//    
//    CustomeTimer *timer = [CustomeTimer scheduledTimerWithTimeInterval:5 repeats:YES block:^{
//        
//        iCount ++;
//        
//        NSLog(@"iCount = %ld",iCount);
//        
//        
//        if(iCount > 100)
//        {
//            [timer invalidate];
//        }
//        
//    }];
    
    
    
    //[self simulatorNSOperationTest];
    
    
    
    [self testFordgcdGroup];
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


void func(dispatch_queue_t queue, dispatch_block_t block)
{
    if (dispatch_get_current_queue() == queue) {
        block();
    }else{
        
        NSLog(@"=====queue = %@=====",queue);
        dispatch_sync(queue, block);
    }
    
    
    NSLog(@"======finish excute========");
}


void dispatch_reentrant(void (^block)())
{
    static NSRecursiveLock *lock = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSRecursiveLock alloc]init];
    });
    [lock lock];
    block();
    [lock unlock];
}


void noDeadLockFunc(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_sync(queue, ^{
        dispatch_reentrant(block);
    });
}


void func2(dispatch_queue_t queue, dispatch_block_t block){
    
    void *queueTag;
    queueTag = &queueTag;

    dispatch_queue_set_specific(queue, queueTag, queueTag, NULL);
    
    if (dispatch_get_specific(queueTag)) {
        block();
    }else
    {
        
        dispatch_sync(queue, block);
    }
}





- (void)deadLockFunc
{
    dispatch_queue_t queueA = dispatch_queue_create("com.zmj.queueA", NULL);
    dispatch_queue_t queueB = dispatch_queue_create("com.zmj.queueB", NULL);
    
    dispatch_sync(queueA, ^{
        
        NSLog(@"==========in queueA============");
        
        dispatch_sync(queueB, ^{
            
            NSLog(@"===========in queueB===========");
            
            dispatch_block_t block = ^{
               
                NSLog(@"this is a test block");
            };
            
            func(queueA, block);
        });
    });
}



- (void)test1
{
    dispatch_queue_t queueA = dispatch_queue_create("com.zmj.queueA", NULL);
    dispatch_queue_t queueB = dispatch_queue_create("com.zmj.queueB", NULL);
    
    dispatch_set_target_queue(queueB, queueA);
    
    static int specificKey;
    
    CFStringRef specificValue = CFSTR("queueA");
    
    dispatch_queue_set_specific(queueA,
                                &specificKey,
                                (void*)specificValue,
                                (dispatch_function_t)CFRelease);
    
    dispatch_sync(queueB, ^{
        dispatch_block_t block = ^{
            //do something
            
            NSLog(@"**********************");
            
        };
        CFStringRef retrievedValue = dispatch_get_specific(&specificKey);
        if (retrievedValue) {
            block();
        } else {
            dispatch_sync(queueA, block);
        }
    });
    
    NSLog(@"-------------finish-----------------");
}


- (void)test2
{
    dispatch_queue_t queueA = dispatch_queue_create("com.yubinbin.queueA", NULL);
    dispatch_queue_t queueB = dispatch_queue_create("com.yubinbin.queueB", NULL);
    
    dispatch_set_target_queue(queueB, queueA);
    
    static const void * const kDispatchQueueSpecificKey = &kDispatchQueueSpecificKey;
    
    dispatch_queue_set_specific(queueB,kDispatchQueueSpecificKey,(__bridge void *)(queueA),NULL);
    
    
    dispatch_sync(queueB, ^{
        
        dispatch_block_t block = ^{
            
            
        };
        
        dispatch_queue_t queueC = (__bridge dispatch_queue_t)(dispatch_get_specific(kDispatchQueueSpecificKey));
        
        if (queueC) {
            block();
        }else
        {
            dispatch_sync(queueA, block);
        }
        
    });

}



- (void)deadLockFunTest
{
    NSLog(@"=======执行任务1========="); // 任务1
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"==========执行任务2============="); // 任务2
    });
    NSLog(@"=============执行任务3==============="); // 任务3
}



- (void)deadLockFunTest2
{
    
    //主线程中
    NSLock *theLock = [[NSLock alloc] init];
    NSNumber *aObject = [[NSNumber alloc] initWithLong:100];
    //线程1
    //线程1 在递归的block内，可能会进行多次的lock，而最后只有一次unlock
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void(^TestMethod)(int);
        TestMethod = ^(int value)
        {
            [theLock lock];
            if (value > 0)
            {
                [aObject stringValue];
                sleep(5);
                TestMethod(value-1);
            }
            [theLock unlock];
        };
        TestMethod(5);
    });
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        [theLock lock];
        [aObject integerValue];
        [theLock unlock];
    });
}




- (void)test222
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *array = [NSMutableArray array];
    
    //非线程安全，随时有可能会崩溃
    
    for (int i = 0; i < 100; i ++) {
    
        dispatch_async(globalQueue, ^{
            
            
            NSLog(@"currentThread = %@",[NSThread currentThread]);
            
            [array addObject:[NSNumber numberWithInt:i]];
        });
    }
    
    NSLog(@"array = %@",array);
}


- (void)testFordgcdGroup
{
    NSMutableArray  *array = [NSMutableArray arrayWithArray:@[@"5",@"2",@"3",@"4",@"1"]];
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *copyArray = [[NSMutableArray alloc] initWithArray:array copyItems:YES];
    
    for (int  i = 0; i < array.count; i ++) {
        
        dispatch_group_enter(group);
        
        dispatch_async(queue, ^{
            
            
            
            NSLog(@"process = %@",[NSProcessInfo processInfo]);
            
            NSString *obj = [array objectAtIndex:i];
            NSNumber *number = [NSNumber numberWithInteger:[obj integerValue]];
            [copyArray replaceObjectAtIndex:i withObject:number];
        });
        
        dispatch_group_leave(group);
       
    }
    
    dispatch_group_notify(group, queue, ^{
        
        for (id obj in array) {
            NSLog(@"obj[%ld] = %@",[array indexOfObject:obj],obj);
        }
        
    });
    
    

}


- (void)testforsemaphore
{
    //信号量
    
    /*
     *Dispatch semaphore是一个带有一个计数器的信号量。这就是多线程编程中所谓的计数器信号量。信号量有点像一个交通信号标志，标志起来的时候你可以走，标准落下的时候你要停下来。Dispatch semaphore用计数器来模拟这种标志。计数器为0，队列暂停执行新任务并等待信号；当计数器超过0后，队列继续执行新任务，并减少计数器。
     */
    
    
    CFTimeInterval beginTime = CFAbsoluteTimeGetCurrent();
    
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    NSMutableArray *array = [NSMutableArray array];
    
    
    
    /*
     * 创建一个信号量
     *
     * 将初始计数器设置为1， 使得一次只能有1个线程访问NSMutableArray对象。
     */
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    
    for (int i = 0; i < 100; i ++) {
        
       
        dispatch_async(globalQueue, ^{
            
            
            /**
             *  等待信号量，知道信号量的计数器大于1
             */
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            NSLog(@"i = %d  &&& currentThread = %@",i,[NSThread currentThread]);
            
        
            /*
             * 因为信号量计数器>=1，
             * dispatch_semaphore_wait函数停止等待，计数器自动-1，流程继续
             *
             * 此例中，到这里的时候，计数器始终会变成0。
             * 因为初始时为1，限定了一次只能有一个线程访问NSMutableArray对象。
             * 
             * 现在，在这里，你可以安全地更新数组了。
             */
            [array addObject:[NSNumber numberWithInt:i]];
            
            
            
            /*
             * 任务完成后，要调用dispatch_semaphore_signal函数，使计数器+1
             * 如果还有其他线程在等待信号量，第一个进入等待状态的线程得到通知后就可以开始了运行了。
             */
            dispatch_semaphore_signal(semaphore);
        });
        
        
    }
    
    
    NSLog(@"===========finish===============");

    
}




- (void)testForSemaphore2
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.zmj.yubinbin", DISPATCH_QUEUE_CONCURRENT);
    __block NSString *strTest = @"test";
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if ([strTest isEqualToString:@"test"]) {
            NSLog(@"--%@--1-", strTest);
            [NSThread sleepForTimeInterval:1];
            if ([strTest isEqualToString:@"test"]) {
                [NSThread sleepForTimeInterval:1];
                NSLog(@"--%@--2-", strTest);
            } else {
                NSLog(@"====changed===");
            }
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"--%@--3-", strTest);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        strTest = @"modify";
        NSLog(@"--%@--4-", strTest);
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_async(concurrentQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"--%@--5-", strTest);
        dispatch_semaphore_signal(semaphore);
    });
    
    
    NSLog(@"=============finish=============");
}



- (void)testForSemaphore3
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        /**
         *  计数器为0，队列暂停执行新任务并等待信号,当计数器超过0后，队列继续执行新任务，并减少计数器
         */
        dispatch_semaphore_t t = dispatch_semaphore_create(0);// 1、创建一个信号量,信号量为0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"耗时操作开始");
            sleep(3);
            NSLog(@"耗时操作结束");
            dispatch_semaphore_signal(t);// 2、返回一个信号量，信号量+1
        });
        
        dispatch_semaphore_wait(t, DISPATCH_TIME_FOREVER);// 3、等待一个信号量，信号量-1，为0后开始等待，直到上一个队列完成后在执行后面的0
        
        NSLog(@"回调回来");
    });
}



- (void)testforbarrier
{
    //拦删，有点类似信号量的概念，前面的任务结束后在执行其他任务
    dispatch_queue_t queue = dispatch_queue_create("com.zmj.barrier", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        
        NSString *test1 = self.mystring;
        NSLog(@"test1 = %@",test1);
        
    });
    
    dispatch_async(queue, ^{
        
        
        NSString *test2 = self.mystring;
        
        NSLog(@"test2 = %@",test2);
    });
    
    dispatch_async(queue, ^{
        
        
        NSLog(@"test3 = %@",self.mystring);
    });
    
    
    dispatch_barrier_async(queue, ^{
        
        self.mystring = @"modify";
        NSLog(@"begin modify");
    });
    
    
    dispatch_async(queue, ^{
        
        NSLog(@"test4 = %@",self.mystring);
    });
}




- (void)testOperation
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        
    }];
}



- (void)testSignalSource
{
    // 1
#if DEBUG
    // 2
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 3
    static dispatch_source_t source = nil;
    
    // 4
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 5
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGSTOP, 0, queue);
        
        // 6
        if (source)
        {
            // 7
            dispatch_source_set_event_handler(source, ^{
                // 8
                NSLog(@"Hi, I am: %@",self);
            });
            
            dispatch_resume(source); // 9
        }
    });
#endif
}




- (void)testgcdSource
{
    //dispatch source是一个监视某些类型事件的对象。当这些事件发生时，它自动将一个block放入一个dispatch queue的执行例程中。

}




- (void)simulatorNSOperationTest
{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//    for (int i = 0; i < 9; i ++) {
//        
//        dispatch_async(queue, ^{
//            
//            NSLog(@"job %d start",i);
//            
//            NSLog(@"current Thread %@",[NSThread currentThread]);
//            
//            sleep(2);
//            NSLog(@"job %d finish",i);
//            
//        });
//    }
    
   
    for (int i = 0; i < 9; i ++)
    {
        dispatch_asyn_limit(queue, 3, ^{
            
            NSLog(@"job %d start",i);
            
            NSLog(@"current Thread %@",[NSThread currentThread]);
            
            sleep(2);
            NSLog(@"job %d finish",i);
        });
    }
    
}




- (void)limitOperationTest
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3;
    
    
      NSInteger index = 1;
    
    for (int i = 0; i < 9; i ++) {
        
        CustomOperation *myTask = [[CustomOperation alloc] init];
        myTask.operationId = index ++;
        [queue addOperation:myTask];
    }
}

@end
