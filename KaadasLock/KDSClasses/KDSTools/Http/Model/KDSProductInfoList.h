//
//  KDSProductInfoList.h
//  KaadasLock
//
//  Created by zhaona on 2020/4/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSProductInfoList : KDSCodingObject

///研发型号
@property (nonatomic,strong) NSString * developmentModel;
///产品型号
@property (nonatomic,strong) NSString * productModel;
//PID，当使用PID检索方式时响应
@property (nonatomic,strong) NSString * snHead;
//客户编号，当使用研发型号检索方式时响应
@property (nonatomic,assign) int customer;
///IOS主用户设备详情图片
@property (nonatomic,strong) NSString * adminUrl;
///IOS主用户设备详情图片@1x
@property (nonatomic,strong) NSString * adminUrl1x;
///IOS主用户设备详情图片@2x
@property (nonatomic,strong) NSString * adminUrl2x;
///IOS主用户设备详情图片@3x
@property (nonatomic,strong) NSString * adminUrl3x;
///IOS授权户设备详情图片
@property (nonatomic,strong) NSString * authUrl;
///IOS授权户设备详情图片@1x
@property (nonatomic,strong) NSString * authUrl1x;
///IOS授权户设备详情图片@2x
@property (nonatomic,strong) NSString * authUrl2x;
///IOS授权户设备详情图片@3x
@property (nonatomic,strong) NSString * authUrl3x;
///设备列表图片
@property (nonatomic,strong) NSString * deviceListUrl;
///设备列表图片@1x
@property (nonatomic,strong) NSString * deviceListUrl1x;
///设备列表图片@2x
@property (nonatomic,strong) NSString * deviceListUrl2x;
///设备列表图片@3x
@property (nonatomic,strong) NSString * deviceListUrl3x;

@property (nonatomic,strong) NSString * _id;

@end

NS_ASSUME_NONNULL_END
