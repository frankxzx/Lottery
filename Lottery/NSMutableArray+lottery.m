//
//  NSMutableArray+lottery.m
//  Lottery
//
//  Created by Xuzixiang on 16/1/18.
//  Copyright © 2016年 frankxzx. All rights reserved.
//

#import "NSMutableArray+lottery.h"

@implementation NSMutableArray (lottery)

-(NSNumber *)random {
    
    NSUInteger randomIndex = self.count;
    if (randomIndex == 0) {
        return nil;
    }
    return (NSNumber *)self[arc4random()%randomIndex];
}

@end
