//
//  CustomeTimer.h
//  GCDTest
//
//  Created by zmjios on 15/11/2.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomeTimer : NSObject


+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)rep block:(dispatch_block_t)block;


+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)rep queue:(dispatch_queue_t)queue block:(dispatch_block_t)block;


- (void) invalidate;

@end
