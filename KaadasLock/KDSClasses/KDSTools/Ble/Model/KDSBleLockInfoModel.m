//
//  KDSLockInfoModel.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/14.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBleLockInfoModel.h"

@implementation KDSBleLockInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.power = -1;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
    self = [self init];
    if (self)
    {
        if (data.length)
        {
            const Byte *bytes = data.bytes;
            _lockFunc = *(uint32_t*)(bytes + 4);
            _lockState = *(uint32_t*)(bytes + 8);
            _volume = bytes[12];
            _language = [[NSString alloc] initWithBytes:bytes + 13 length:2 encoding:NSUTF8StringEncoding];
            _power = bytes[15];
        }
    }
    return self;
}

@end
