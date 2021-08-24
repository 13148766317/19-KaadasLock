//
//  KDSGWStat.m
//  KaadasLock
//
//  Created by orange on 2019/4/17.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWStat.h"
#import <MJExtension/MJExtension.h>

@implementation KDSGWStat

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"temperature" : @"CurrentTemperature",
             @"txSuccess" : @"Tx success",
             @"txFailed" : @"Tx fail count",
             @"rxSuccess" : @"Rx success",
             @"rxWithCrc" : @"Rx with CRC",
             @"rxWithPhyErr" : @"Rx with PhyErr",
             @"rxWithPlcpErr" : @"Rx with PlcpErr",
             @"rxDrop" : @"Rx drop due to out of resource",
             @"rxDuplicate" : @"Rx duplicate frame",
             @"falseCaa" : @"False CCA",
             @"rssi" : @"RSSI",
             @"txAggRange1" : @"TX AGG Range 1 (1)",
             @"txAggRange2" : @"TX AGG Range 2 (2~5)",
             @"txAggRange3" : @"TX AGG Range 3 (6~15)",
             @"txAggRange4" : @"TX AGG Range 4 (>15)",
             @"ampduTxSuccess" : @"AMPDU Tx success",
             @"ampduTxFailed" : @"AMPDU Tx fail count",
             @"apClientWpsProfile" : @"Ap Client WPS Profile Count",
             };
}

@end
