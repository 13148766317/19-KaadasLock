//
//  KDSBleUserType.m
//  lock
//
//  Created by orange on 2019/1/10.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleUserType.h"

@implementation KDSBleUserType

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.keyType = KDSBleKeyTypeInvalid;
        self.userType = KDSBleSetUserTypeInvalid;
    }
    return self;
}

@end
