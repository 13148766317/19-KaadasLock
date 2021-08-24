//
//  KDSBleWeeklyModel.m
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleWeeklyModel.h"

@implementation KDSBleWeeklyModel

- (instancetype)initWithData:(NSData *)data
{
    self = [super initWithData:data];
    if (self)
    {
        if (data.length > 11)
        {
            const unsigned char *bytes = data.bytes;
            _mask = bytes[7];
            _beginHour = bytes[8];
            _beginMin = bytes[9];
            _endHour = bytes[10];
            _endMin = bytes[11];
        }
    }
    return self;
}

@end
