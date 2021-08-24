//
//  KDSDevSwithModel.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDevSwithModel.h"

@implementation KDSDevSwithModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    KDSDevSwithModel *other = object;
    return [self.devId isEqualToString:other.devId];
}

- (NSUInteger)hash
{
    return self.devId.hash;
}

@end
