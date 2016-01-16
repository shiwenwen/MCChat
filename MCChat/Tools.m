//
//  Tools.m
//  MCChat
//
//  Created by 石文文 on 16/1/16.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+(nonnull NSString *)randomStringWithBit:(NSInteger)bit
{
    
    char data[bit];
    
    for (int x=0;x<bit;data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
}

@end
