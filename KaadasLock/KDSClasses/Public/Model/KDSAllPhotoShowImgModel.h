//
//  KDSAllPhotoShowImgModel.h
//  KaadasLock
//
//  Created by zhaona on 2020/1/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAllPhotoShowImgModel : NSObject

+(instancetype)shareModel;
///设备对应的模型（设备列表）
@property(nonatomic,strong)id model;
///具体的设备（设备详情，授权设备详情）
@property(nonatomic,strong)id device;
///缓存到本地的图片地址
@property (nonatomic,strong)UIImage * downLoadImg;
///设备根据研发型号映射出来的产品型号
@property (nonatomic,strong)NSMutableDictionary * productModel;
///设备主用户图片
@property (nonatomic,strong)NSMutableDictionary * adminImgName;
///分享用户图片
@property (nonatomic,strong)NSMutableDictionary * authImgName;
///设备列表图片的名字
@property(nonatomic,strong)NSMutableDictionary * deviceListImgName;
/**
*@abstract 根据设备模型下载设备图片（设备列表、设备详情、授权用户详情）。
*@param imgName 图片的下载地址
*@return 返回图片（下载或者从缓存读取）。
*/
- (UIImage *)getDeviceImgWithImgName:(NSString *)imgName completion:(nullable void(^)(UIImage * _Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
