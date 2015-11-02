//
//  CustomeTimer.m
//  GCDTest
//
//  Created by zmjios on 15/11/2.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import "CustomeTimer.h"

@interface CustomeTimer ()

@property (nonatomic, strong) dispatch_source_t timer;

@end


@implementation CustomeTimer


+ (CustomeTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)rep block:(dispatch_block_t)block
{
    return [[CustomeTimer alloc] initScheduledTimerWithTimeInterval:ti repeats:rep block:block];
}


- (instancetype)initScheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)rep block:(dispatch_block_t)block
{
    return [self initScheduledTimerWithTimeInterval:ti repeats:rep queue:dispatch_get_main_queue() block:block];
}



- (instancetype)initScheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)rep queue:(dispatch_queue_t)queue block:(dispatch_block_t)block
{
    NSAssert(queue != NULL, @"queue cannot be nil");
    
    if (self = [super init]) {
        
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        __weak __typeof(self) weakSelf = self;
        
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, ti * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(self.timer, ^{
            if (block) {
                block();
            }
            if (!rep) {
                dispatch_source_cancel(self.timer);
            }
        });
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, ti * NSEC_PER_SEC), queue, ^{
            dispatch_resume(self.timer);
        });
    }
    
    
    return self;
    
}


- (void)dealloc
{
    dispatch_source_cancel(self.timer);
    
    NSLog(@"===========dealloc:%@===========",NSStringFromClass([self class]));
}



- (void) invalidate
{
    dispatch_source_cancel(self.timer);
}

@end
