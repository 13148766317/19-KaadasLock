//
//  KDSGWCateyeParam.m
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWCateyeParam.h"
#import <MJExtension/MJExtension.h>

@implementation KDSGWCateyeParam

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"swVer":@"SW", @"hwVer":@"HW", @"mcuVer":@"MCU", @"t200Ver":@"T200",@"pirSensitivity":@"pirWander"};
}

@end
