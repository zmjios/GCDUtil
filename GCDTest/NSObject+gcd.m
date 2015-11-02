//
//  NSObject+gcd.m
//  GCDTest
//
//  Created by zmjios on 15/11/2.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import "NSObject+gcd.h"

@implementation NSObject (gcd)


void dispatch_asyn_limit(dispatch_queue_t queue,NSInteger maxLimit,dispatch_block_t block){
    
    //控制并发的信号量
    static dispatch_semaphore_t limitSemphore;
    
    //控制并发等待的reciverQueue
    static dispatch_queue_t reciverQueue;
    
    //线程安全
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        limitSemphore = dispatch_semaphore_create(maxLimit);
        reciverQueue =  dispatch_queue_create("com.zmj.recierQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(reciverQueue, ^{
        
        /**
         *  等待信号量，直到信号量的计数器大于1
         */
        dispatch_semaphore_wait(limitSemphore, DISPATCH_TIME_FOREVER);
        
        dispatch_async(queue, ^{
            
            if(block)
            {
                block();
            }
            
            /*
             * 任务完成后，要调用dispatch_semaphore_signal函数，使计数器+1
             * 如果还有其他线程在等待信号量，第一个进入等待状态的线程得到通知后就可以开始了运行了。
             */
            dispatch_semaphore_signal(limitSemphore);
            
        });
        
    });
    
    
    
}

@end
