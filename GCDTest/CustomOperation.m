//
//  CustomOperation.m
//  GCDTest
//
//  Created by zmjios on 15/10/30.
//  Copyright © 2015年 zmjios. All rights reserved.
//

#import "CustomOperation.h"

@implementation CustomOperation


- (void)main
{
    NSLog(@"===========operation %ld run....... =============",self.operationId);
    
    
    if (self.cancelled) {
        return;
    }
    
    
    NSLog(@"===========currentThread = %@==========",[NSThread currentThread]);
    
   [NSThread sleepForTimeInterval:2];
    
    NSLog(@"===========operation %ld is finished. =========",self.operationId);
}



@end
