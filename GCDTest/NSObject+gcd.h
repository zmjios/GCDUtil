//
//  NSObject+gcd.h
//  GCDTest
//
//  Created by zmjios on 15/11/2.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (gcd)


void dispatch_asyn_limit(dispatch_queue_t queue,NSInteger maxLimit,dispatch_block_t block);


@end
