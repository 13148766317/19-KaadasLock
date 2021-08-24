//
//  KDSSmartHangerModel.m
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/11.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSSmartHangerModel.h"

@implementation KDSSmartHangerModel

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    KDSSmartHangerModel *other = object;
    return [self._id isEqualToString:other._id];
}

@end
