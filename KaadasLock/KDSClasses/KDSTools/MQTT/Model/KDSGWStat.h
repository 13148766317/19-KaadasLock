//
//  KDSGWStat.h
//  KaadasLock
//
//  Created by orange on 2019/4/17.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///网关统计信息。所有的字段都没有标注文档。
@interface KDSGWStat : NSObject

@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *txSucces;
@property (nonatomic, strong) NSString *txFailed;
@property (nonatomic, strong) NSString *rxSuccess;
@property (nonatomic, strong) NSString *rxWithCrc;
@property (nonatomic, strong) NSString *rxWithPhyErr;
@property (nonatomic, strong) NSString *rxWithPlcpErr;
@property (nonatomic, strong) NSString *rxDrop;
@property (nonatomic, strong) NSString *rxDuplicate;
@property (nonatomic, strong) NSString *falseCaa;
@property (nonatomic, strong) NSString *rssi;
@property (nonatomic, strong) NSString *txAggRange1;
@property (nonatomic, strong) NSString *txAggRange2;
@property (nonatomic, strong) NSString *txAggRange3;
@property (nonatomic, strong) NSString *txAggRange4;
@property (nonatomic, strong) NSString *ampduTxSuccess;
@property (nonatomic, strong) NSString *ampduTxFailed;
@property (nonatomic, strong) NSString *apClientWpsProfile;

@end

NS_ASSUME_NONNULL_END
