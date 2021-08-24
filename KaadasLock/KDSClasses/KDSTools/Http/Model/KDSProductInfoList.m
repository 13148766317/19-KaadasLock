//
//  KDSProductInfoList.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSProductInfoList.h"

@implementation KDSProductInfoList

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"adminUrl1x":@"adminUrl@1x", @"adminUrl2x":@"adminUrl@2x", @"adminUrl3x":@"adminUrl@3x", @"authUrl1x":@"authUrl@1x",  @"authUrl2x":@"authUrl@2x", @"authUrl3x":@"authUrl@3x",@"deviceListUrl1x":@"deviceListUrl@1x",@"deviceListUrl2x":@"deviceListUrl@2x",@"deviceListUrl3x":@"deviceListUrl@3x"};
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:self.class]) return NO;
    if (self == object) return YES;
    KDSProductInfoList *other = object;
    return [self.productModel isEqualToString:other.productModel] && [self._id isEqualToString:other._id] && [self.developmentModel isEqualToString:other.developmentModel];
}

- (NSUInteger)hash
{
    return self._id.hash  + self._id.boolValue;
}


@end
