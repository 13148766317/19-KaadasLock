//
//  KDSDeviceModelMapping.m
//  KaadasLock
//
//  Created by Frank Hu on 2019/11/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSDeviceModelMapping.h"

@implementation KDSDeviceModelMapping

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    //key为模型属性值
    return @{
             @"adminUrlx1":@"adminUrl@1x",
             @"deviceListUrlx1":@"deviceListUrl@1x",
             @"authUrlx1":@"authUrl@1x",
             @"adminUrlx2":@"adminUrl@2x",
             @"deviceListUrlx2":@"deviceListUrl@2x",
             @"authUrlx2":@"authUrl@2x",
             @"adminUrlx3":@"adminUrl@3x",
             @"deviceListUrlx3":@"deviceListUrl@3x",
             @"authUrlx3":@"authUrl@3x",
             };
}
@end
