//
//  KDSBleYMDModel.m
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleYMDModel.h"

@implementation KDSBleYMDModel

- (instancetype)initWithData:(NSData *)data
{
    self = [super initWithData:data];
    if (self)
    {
        if (data.length > 14)
        {
            const unsigned char *bytes = data.bytes;
            NSInteger secondsFromGMT = [NSTimeZone systemTimeZone].secondsFromGMT;
            uint32_t beginTime = (unsigned)(*((uint32_t *)(bytes + 7)) - secondsFromGMT);//系统是小端
            uint32_t endTime = (unsigned)(*((uint32_t *)(bytes + 11)) - secondsFromGMT);
            _beginTime = beginTime;
            _endTime = endTime;
        }
    }
    return self;
}

@end
