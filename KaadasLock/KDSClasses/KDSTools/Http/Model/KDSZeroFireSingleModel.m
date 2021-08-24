//
//  KDSZeroFireSingleModel.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSZeroFireSingleModel.h"

@implementation KDSZeroFireSingleModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    KDSZeroFireSingleModel *other = object;
    return [self.name isEqualToString:other.name] && [self._id isEqualToString:other._id];
}

@end
