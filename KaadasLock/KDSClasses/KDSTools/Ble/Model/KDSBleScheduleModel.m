//
//  KDSBleScheduleModel.m
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleScheduleModel.h"

@implementation KDSBleScheduleModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _keyType = KDSBleKeyTypeInvalid;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [self init];
    if (data.length > 6)
    {
        const unsigned char *bytes = data.bytes;
        _scheduleId = bytes[4];
        _userId = bytes[5];
        _keyType = (KDSBleKeyType)bytes[6];
    }
    return self;
}

@end
