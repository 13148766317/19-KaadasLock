//
//  KDSDeviceModelMapping.h
//  KaadasLock
//
//  Created by Frank Hu on 2019/11/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSDeviceModelMapping : KDSCodingObject

///
@property (nonatomic, strong) NSString *_id;
///
@property (nonatomic, strong) NSString *developmentModel;
///
@property (nonatomic, strong) NSString *productModel;
///
@property (nonatomic, strong) NSString *adminUrl;
///
@property (nonatomic, strong) NSString *deviceListUrl;
///
@property (nonatomic, strong) NSString *authUrl;
///
@property (nonatomic, strong) NSString *adminUrlx1;
///
@property (nonatomic, strong) NSString *deviceListUrlx1;
///
@property (nonatomic, strong) NSString *authUrlx1;
///
@property (nonatomic, strong) NSString *adminUrlx2;
///
@property (nonatomic, strong) NSString *deviceListUrlx2;
///
@property (nonatomic, strong) NSString *authUrlx2;
///
@property (nonatomic, strong) NSString *adminUrlx3;
///
@property (nonatomic, strong) NSString *deviceListUrlx3;
///
@property (nonatomic, strong) NSString *authUrlx3;
///
@property (nonatomic, strong) NSString *createTime;

@end

NS_ASSUME_NONNULL_END
