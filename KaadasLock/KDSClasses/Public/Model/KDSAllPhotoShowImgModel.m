//
//  KDSAllPhotoShowImgModel.m
//  KaadasLock
//
//  Created by zhaona on 2020/1/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAllPhotoShowImgModel.h"

@implementation KDSAllPhotoShowImgModel

+ (instancetype)shareModel
{
    static KDSAllPhotoShowImgModel *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSAllPhotoShowImgModel alloc] init];
    });
    return _manager;
}

- (void)setModel:(id)model
{
    _model = model;
    if ([model isKindOfClass:KDSCatEye.class]) {
    }else if ([model isKindOfClass:KDSGW.class]) {///网关
        return;
    }else if ([model isKindOfClass:KDSLock.class]){
        if ([model gwDevice])
        {//网关锁
            [self setGwLockUI:model];
        }
        else if ([model wifiDevice])
        {//Wi-Fi锁
            [self setWFLockUI:model];
        }
        else
        {//蓝牙锁
            [self setBleLockUI:model];
        }
    }
}

- (void)setDevice:(id)device
{
    _device = device;
    if ([device isKindOfClass:KDSWifiLockModel.class]) {
        KDSWifiLockModel * wifiModel = device;
        if (wifiModel.isAdmin.intValue == 1) {//主用户
            [self setWFLockDetailsUI:wifiModel];
        }else{
            [self setWFShareLockDetailsUI:wifiModel];
        }
    }else if ([device isKindOfClass:MyDevice.class]){
        MyDevice * bleModel = device;
        if (bleModel.is_admin.intValue == 1) {
            [self setBleLockDetailsUI:bleModel];
        }else{
            [self setBleShareLockUI:bleModel];
        }
    }
}
//网关锁页面（设备列表）
-(void)setGwLockUI:(KDSLock *)gwLock
{
    GatewayDeviceModel * device = gwLock.gwDevice;
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.developmentModel isEqualToString:device.deviceType]
            && product.developmentModel != nil && device.deviceType != nil
            && product.developmentModel.length >0 && device.deviceType.length >0) {
            
            [self.productModel setValue:product.productModel forKey:device.deviceType];
            if (KDSScreenWidth <= 375) {
                self.deviceListImgName[device.deviceType] = product.deviceListUrl2x;
            }else{
                self.deviceListImgName[device.deviceType] = product.deviceListUrl3x;
            }
            return;
        }
    }
    if (![[self.deviceListImgName allKeys] containsObject:device.deviceType] && device.deviceType != nil && device.deviceType.length >0) {
        if ([device.deviceType containsString:@"KX"]){
            [self.deviceListImgName setValue:@"KX" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"K7"]){
            [self.deviceListImgName setValue:@"K7" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"K8-T"]){
            [self.deviceListImgName setValue:@"K8-T" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"K8"]){
            [self.deviceListImgName setValue:@"K8" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"K9"]){
            [self.deviceListImgName setValue:@"K9" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"QZ012"]){
            [self.deviceListImgName setValue:@"QZ012" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"QZ013"]){
            [self.deviceListImgName setValue:@"QZ013" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"S8"]){
            [self.deviceListImgName setValue:@"S8" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"V6"]||[device.deviceType containsString:@"V350"]){
            [self.deviceListImgName setValue:@"V6" forKey:device.deviceType];
        }else if ([device.deviceType containsString:@"V7"]||[device.deviceType containsString:@"S100"]){
            [self.deviceListImgName setValue:@"V7" forKey:device.deviceType];
        }else{
            [self.deviceListImgName setValue:@"Unrecognized lock_pic" forKey:device.deviceType];
        }
    }
}
//蓝牙锁页面（设备列表）
-(void)setBleLockUI:(KDSLock *)lock
{
    MyDevice * d = lock.device;
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.developmentModel isEqualToString:d.model]
            && product.developmentModel != nil && d.model != nil
            && product.developmentModel.length >0 && d.model.length >0
            
            && [product.snHead isEqualToString:[d.deviceSN substringToIndex:3]]
            && product.snHead != nil && d.deviceSN != nil
            && product.snHead.length >0 && d.deviceSN.length >0) {

            [self.productModel setValue:product.productModel forKey:d.model];
            if (KDSScreenWidth <= 375) {
                [self.deviceListImgName setValue:product.deviceListUrl2x forKey:d.model];
            }else{
                [self.deviceListImgName setValue:product.deviceListUrl3x forKey:d.model];
            }
            return;
        }
        
    }
    if (![[self.deviceListImgName allKeys] containsObject:d.model] && d.model != nil && d.model.length > 0) {
        if ([d.model containsString:@"KX"]){
            [self.deviceListImgName setValue:@"KX" forKey:d.model];
        }else if ([d.model containsString:@"K7"]){
            [self.deviceListImgName setValue:@"K7" forKey:d.model];
        }else if ([d.model containsString:@"K8-T"]){
            [self.deviceListImgName setValue:@"K8-T" forKey:d.model];
        }else if ([d.model containsString:@"KX-T"] || [d.model containsString:@"K8300"]){
            [self.deviceListImgName setValue:@"KX-T" forKey:d.model];
        }else if ([d.model containsString:@"K8"]){
            [self.deviceListImgName setValue:@"K8" forKey:d.model];
        }else if ([d.model containsString:@"K9"]){
            [self.deviceListImgName setValue:@"K9" forKey:d.model];
        }else if ([d.model containsString:@"K10W"]){
            [self.deviceListImgName setValue:@"K10W" forKey:d.model];
        }else if ([d.model containsString:@"QZ012"]){
            [self.deviceListImgName setValue:@"QZ012" forKey:d.model];
        }else if ([d.model containsString:@"QZ013"]){
            [self.deviceListImgName setValue:@"QZ013" forKey:d.model];
        }else if ([d.model containsString:@"S800"]){
            [self.deviceListImgName setValue:@"S800" forKey:d.model];
        }else if ([d.model containsString:@"V6"]||[d.model containsString:@"V350"]){
            [self.deviceListImgName setValue:@"V6" forKey:d.model];
        }else if ([d.model containsString:@"V7"]||[d.model containsString:@"S100"]){
            [self.deviceListImgName setValue:@"V7" forKey:d.model];
        }else if ([d.model containsString:@"K100"] || [d.model containsString:@"V450"]){
            [self.deviceListImgName setValue:@"K100" forKey:d.model];
        }else if ([d.model containsString:@"H5606"]){
            [self.deviceListImgName setValue:@"H5606" forKey:d.model];
        }else if ([d.model containsString:@"S6"]){
            [self.deviceListImgName setValue:@"S6" forKey:d.model];
        }else if ([d.model containsString:@"S700"]){
            [self.deviceListImgName setValue:@"S700" forKey:d.model];
        }else if ([d.model containsString:@"8008"]){
            [self.deviceListImgName setValue:@"8008" forKey:d.model];
        }else if ([d.model containsString:@"8100B"]){
            [self.deviceListImgName setValue:@"8008B" forKey:d.model];
        }else if ([d.model containsString:@"8100C"]){
            [self.deviceListImgName setValue:@"8100C" forKey:d.model];
        }else if ([d.model containsString:@"8100"]){
            [self.deviceListImgName setValue:@"8100" forKey:d.model];
        }else if ([d.model containsString:@"S8"]){
            [self.deviceListImgName setValue:@"S8" forKey:d.model];
        }else if ([d.model containsString:@"K200"]){
            [self.deviceListImgName setValue:@"K200" forKey:d.model];
        }else if ([d.model containsString:@"S3006"]){
            [self.deviceListImgName setValue:@"S3006" forKey:d.model];
        }else if ([d.model containsString:@"S3001"]){
            [self.deviceListImgName setValue:@"S3001" forKey:d.model];
        }else if ([d.model containsString:@"S300"]){
            [self.deviceListImgName setValue:@"S300" forKey:d.model];
        }else if ([d.model containsString:@"5011"]){
            [self.deviceListImgName setValue:@"5011" forKey:d.model];
        }else if ([d.model containsString:@"Q8"]){
            [self.deviceListImgName setValue:@"Q8" forKey:d.model];
        }else if ([d.model containsString:@"G8012"]){
            [self.deviceListImgName setValue:@"8012" forKey:d.model];
        }else if ([d.model containsString:@"G3560"]){
            [self.deviceListImgName setValue:@"5200-A6J" forKey:d.model];
        }else if ([d.model containsString:@"G3350"]){
            [self.deviceListImgName setValue:@"5200-A5PJ" forKey:d.model];
        }else if ([d.model containsString:@"A8"]){
            [self.deviceListImgName setValue:@"A8" forKey:d.model];
        }else{
            [self.deviceListImgName setValue:@"Unrecognized lock_pic" forKey:d.model];
        }
    }
    
}

//wifi锁界面(设备列表)。
- (void)setWFLockUI:(KDSLock *)lock
{
    KDSWifiLockModel *d = lock.wifiDevice;
    NSString * tt = d.productModel ?: d.wifiSN;
    d.productModel = tt;
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.snHead isEqualToString:[d.wifiSN substringToIndex:3]]
            && product.snHead != nil && d.wifiSN != nil
            && product.snHead.length >0 && d.wifiSN.length >0) {
            
            [self.productModel setValue:product.productModel forKey:d.productModel];
            if (KDSScreenWidth <= 375) {
                [self.deviceListImgName setValue:product.deviceListUrl2x forKey:d.productModel];
            }else{
                [self.deviceListImgName setValue:product.deviceListUrl3x forKey:d.productModel];
            }
            return;
        }
    }
    if (![[self.deviceListImgName allKeys] containsObject:d.productModel] && d.productModel != nil && d.productModel.length >0) {
        if ([d.productModel containsString:@"KX"]){
            [self.deviceListImgName setValue:@"KX" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K7"]){
            [self.deviceListImgName setValue:@"K7" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K8-T"]){
            [self.deviceListImgName setValue:@"K8-T" forKey:d.productModel];
        }else if ([d.productModel containsString:@"KX-T"] || [d.productModel containsString:@"K8300"]){
            [self.deviceListImgName setValue:@"KX-T" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K8"]){
            [self.deviceListImgName setValue:@"K8" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K9W"]){
            [self.deviceListImgName setValue:@"K9W" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K9"]){
            [self.deviceListImgName setValue:@"K9" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K10W"]){
            [self.deviceListImgName setValue:@"K10W" forKey:d.productModel];
        }else if ([d.productModel containsString:@"QZ012"]){
            [self.deviceListImgName setValue:@"QZ012" forKey:d.productModel];
        }else if ([d.productModel containsString:@"QZ013"]){
            [self.deviceListImgName setValue:@"QZ013" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S800"]){
            [self.deviceListImgName setValue:@"S800" forKey:d.productModel];
        }else if ([d.productModel containsString:@"V6"]||[d.productModel containsString:@"V350"]){
            [self.deviceListImgName setValue:@"V6" forKey:d.productModel];
        }else if ([d.productModel containsString:@"V7"]||[d.productModel containsString:@"S100"]){
            [self.deviceListImgName setValue:@"V7" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K100"] || [d.productModel containsString:@"V450"]){
            [self.deviceListImgName setValue:@"K100" forKey:d.productModel];
        }else if ([d.productModel containsString:@"H5606"]){
            [self.deviceListImgName setValue:@"H5606" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S6"]){
            [self.deviceListImgName setValue:@"S6" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S700"]){
            [self.deviceListImgName setValue:@"S700" forKey:d.productModel];
        }else if ([d.productModel containsString:@"8008"]){
            [self.deviceListImgName setValue:@"8008" forKey:d.productModel];
        }else if ([d.productModel containsString:@"8100B"]){
            [self.deviceListImgName setValue:@"8100B" forKey:d.productModel];
        }else if ([d.productModel containsString:@"8100C"]){
            [self.deviceListImgName setValue:@"8100C" forKey:d.productModel];
        }else if ([d.productModel containsString:@"8100"]){
            [self.deviceListImgName setValue:@"8100" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S8"]){
            [self.deviceListImgName setValue:@"S8" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K200"]){
            [self.deviceListImgName setValue:@"K200" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S3006"]){
            [self.deviceListImgName setValue:@"S3006" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S3001"]){
            [self.deviceListImgName setValue:@"S3001" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S300"]){
            [self.deviceListImgName setValue:@"S300" forKey:d.productModel];
        }else if ([d.productModel containsString:@"5011"]){
            [self.deviceListImgName setValue:@"5011" forKey:d.productModel];
        }else if ([d.productModel containsString:@"Q8"]){
            [self.deviceListImgName setValue:@"Q8" forKey:d.productModel];
        }else if ([d.productModel containsString:@"G8012"]){
            [self.deviceListImgName setValue:@"8012" forKey:d.productModel];
        }else if ([d.productModel containsString:@"G3560"]){
            [self.deviceListImgName setValue:@"5200-A6J" forKey:d.productModel];
        }else if ([d.productModel containsString:@"G3350"]){
            [self.deviceListImgName setValue:@"5200-A5PJ" forKey:d.productModel];
        }else if ([d.productModel containsString:@"A8"]){
            self.deviceListImgName[d.productModel] = @"A8";
            [self.deviceListImgName setValue:@"A8" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K11W"]){
            [self.deviceListImgName setValue:@"K11W" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K12W"]){
            [self.deviceListImgName setValue:@"K12W" forKey:d.productModel];
        }else if ([d.productModel containsString:@"K13"]){
            [self.deviceListImgName setValue:@"K13" forKey:d.productModel];
        }else if ([d.productModel containsString:@"X1"]){
            [self.deviceListImgName setValue:@"X1" forKey:d.productModel];
        }else if ([d.productModel containsString:@"S110"]){
            [self.deviceListImgName setValue:@"S110" forKey:d.productModel];
        }else if ([d.productModel containsString:@"F1"]){
            [self.deviceListImgName setValue:@"F1" forKey:d.productModel];
        }else{
            [self.deviceListImgName setValue:@"Unrecognized lock_pic" forKey:d.productModel];
        }
    }
    
}

//蓝牙锁详情页面（主用户）
-(void)setBleLockDetailsUI:(MyDevice *)device
{
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.developmentModel isEqualToString:device.model]
            && product.developmentModel != nil && device.model != nil
            && product.developmentModel.length >0 && device.model.length >0
            
            && [product.snHead isEqualToString:[device.deviceSN substringToIndex:3]]
            && product.snHead != nil && device.deviceSN != nil
            && product.snHead.length >0 && device.deviceSN.length >0) {
            [self.productModel setValue:product.productModel forKey:device.model];
            if (KDSScreenWidth <= 375) {
                [self.adminImgName setValue:product.adminUrl2x forKey:device.model];
            }else{
                [self.adminImgName setValue:product.adminUrl3x forKey:device.model];
            }
            return;
        }
    }
    if (![[self.adminImgName allKeys] containsObject:device.model] && device.model != nil && device.model.length >0) {
        if ([device.model containsString:@"KX"]){
            [self.adminImgName setValue:@"kxLock" forKey:device.model];
        }else if ([device.model containsString:@"K7"]){
            [self.adminImgName setValue:@"K7Lock" forKey:device.model];
        }else if ([device.model containsString:@"K8-T"]){
            [self.adminImgName setValue:@"k8-TLock" forKey:device.model];
        }else if ([device.model containsString:@"KX-T"] || [device.model containsString:@"K8300"]){
            [self.adminImgName setValue:@"KX-TLock" forKey:device.model];
        }else if ([device.model containsString:@"K8"]){
            [self.adminImgName setValue:@"k8Lock" forKey:device.model];
        }else if ([device.model containsString:@"K9"]){
            [self.adminImgName setValue:@"k9Lock" forKey:device.model];
        }else if ([device.model containsString:@"K10W"]){
            [self.adminImgName setValue:@"K10WLock" forKey:device.model];
        }else if ([device.model containsString:@"QZ012"]){
            [self.adminImgName setValue:@"qz012Lock" forKey:device.model];
        }else if ([device.model containsString:@"QZ013"]){
            [self.adminImgName setValue:@"qz013Lock" forKey:device.model];
        }else if ([device.model containsString:@"S800"]){
            [self.adminImgName setValue:@"S800Lock" forKey:device.model];
        }else if ([device.model containsString:@"V6"]||[device.model containsString:@"V350"]){
            [self.adminImgName setValue:@"v6Lock" forKey:device.model];
        }else if ([device.model containsString:@"V7"]||[device.model containsString:@"S100"]){
            [self.adminImgName setValue:@"v7Lock" forKey:device.model];
        }else if ([device.model containsString:@"K100"] || [device.model containsString:@"V450"]){
            [self.adminImgName setValue:@"K100Lock" forKey:device.model];
        }else if ([device.model containsString:@"H5606"]){
            [self.adminImgName setValue:@"H5606Lock" forKey:device.model];
        }else if ([device.model containsString:@"S6"]){
            [self.adminImgName setValue:@"S6Lock" forKey:device.model];
        }else if ([device.model containsString:@"8008"]){
            [self.adminImgName setValue:@"8008Lock" forKey:device.model];
        }else if ([device.model containsString:@"8100B"]){
            [self.adminImgName setValue:@"8100BLock" forKey:device.model];
        }else if ([device.model containsString:@"8100C"]){
            [self.adminImgName setValue:@"8100CLock" forKey:device.model];
        }else if ([device.model containsString:@"8100"]){
            [self.adminImgName setValue:@"8100Lock" forKey:device.model];
        }else if ([device.model containsString:@"S700"]){
            [self.adminImgName setValue:@"S700Lock" forKey:device.model];
        }else if ([device.model containsString:@"S8"]){
            [self.adminImgName setValue:@"S8Lock" forKey:device.model];
        }else if ([device.model containsString:@"K200"]){
            [self.adminImgName setValue:@"K200Lock" forKey:device.model];
        }else if ([device.model containsString:@"S3006"]){
            [self.adminImgName setValue:@"S3006Lock" forKey:device.model];
        }else if ([device.model containsString:@"S3001"]){
            [self.adminImgName setValue:@"S3001Lock" forKey:device.model];
        }else if ([device.model containsString:@"S300"]){
            [self.adminImgName setValue:@"S300Lock" forKey:device.model];
        }else if ([device.model containsString:@"5011"]){
            [self.adminImgName setValue:@"5011Lock" forKey:device.model];
        }else if ([device.model containsString:@"Q8"]){
            [self.adminImgName setValue:@"Q8Lock" forKey:device.model];
        }else if ([device.model containsString:@"G8012"]){
            [self.adminImgName setValue:@"8012Lock" forKey:device.model];
        }else if ([device.model containsString:@"G3560"]){
            [self.adminImgName setValue:@"5200-A6JLock" forKey:device.model];
        }else if ([device.model containsString:@"G3350"]){
            [self.adminImgName setValue:@"5200-A5PJLock" forKey:device.model];
        }else if ([device.model containsString:@"A8"]){
            [self.adminImgName setValue:@"A8Lock" forKey:device.model];
        }else{
            [self.adminImgName setValue:@"lock_pic" forKey:device.model];
        }
    }
    
}
//蓝牙锁详情页面（授权用户）
-(void)setBleShareLockUI:(MyDevice *)device
{
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.developmentModel isEqualToString:device.model]
            && product.developmentModel != nil && device.model != nil
            && product.developmentModel.length >0 && device.model.length >0
            
            && [product.snHead isEqualToString:[device.deviceSN substringToIndex:3]]
            && product.snHead != nil && device.deviceSN != nil
            && product.snHead.length >0 && device.deviceSN.length >0) {
            
            [self.productModel setValue:product.productModel forKey:device.model];
            if (KDSScreenWidth <= 375) {
                [self.authImgName setValue:product.authUrl2x forKey:device.model];
            }else{
                [self.authImgName setValue:product.authUrl3x forKey:device.model];
            }
            return;
        }
    }
    if (![[self.authImgName allKeys] containsObject:device.model] && device.model != nil && device.model.length >0) {
        if ([device.model containsString:@"KX"]){
            [self.authImgName setValue:@"kxLockShare" forKey:device.model];
        }else if ([device.model containsString:@"K7"]){
            [self.authImgName setValue:@"k7LockShare" forKey:device.model];
        }else if ([device.model containsString:@"K8-T"]){
            [self.authImgName setValue:@"k8-TLockShare" forKey:device.model];
        }else if ([device.model containsString:@"KX-T"] || [device.model containsString:@"K8300"]){
            [self.authImgName setValue:@"KX-TLockShare" forKey:device.model];
        }else if ([device.model containsString:@"K8"]){
            [self.authImgName setValue:@"k8LockShare" forKey:device.model];
        }else if ([device.model containsString:@"K9"]){
            [self.authImgName setValue:@"k9LockShare" forKey:device.model];
        }else if ([device.model containsString:@"K10W"]){
            [self.authImgName setValue:@"K10WLockShare" forKey:device.model];
        }else if ([device.model containsString:@"QZ012"]){
            [self.authImgName setValue:@"qz012LockShare" forKey:device.model];
        }else if ([device.model containsString:@"QZ013"]){
            [self.authImgName setValue:@"qz013LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S800"]){
            [self.authImgName setValue:@"S800LockShare" forKey:device.model];
        }else if ([device.model containsString:@"V6"]||[device.model containsString:@"V350"]){
            [self.authImgName setValue:@"v6LockShare" forKey:device.model];
        }else if ([device.model containsString:@"V7"]||[device.model containsString:@"S100"]){
            [self.authImgName setValue:@"v7LockShare" forKey:device.model];
        }else if ([device.model containsString:@"K100"] || [device.model containsString:@"V450"]){
            [self.authImgName setValue:@"K100LockShare" forKey:device.model];
        }else if ([device.model containsString:@"H5606"]){
            [self.authImgName setValue:@"H5606LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S6"]){
            [self.authImgName setValue:@"S6LockShare" forKey:device.model];
        }else if ([device.model containsString:@"8008"]){
            [self.authImgName setValue:@"8008LockShare" forKey:device.model];
        }else if ([device.model containsString:@"8100B"]){
            [self.authImgName setValue:@"8100BLockShare" forKey:device.model];
        }else if ([device.model containsString:@"8100C"]){
            [self.authImgName setValue:@"8100CLockShare" forKey:device.model];
        }else if ([device.model containsString:@"8100"]){
            [self.authImgName setValue:@"8100LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S700"]){
            [self.authImgName setValue:@"S700LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S8"]){
            [self.authImgName setValue:@"S8LockShare" forKey:device.model];
        }else if ([device.model containsString:@"K200"]){
            [self.authImgName setValue:@"K200LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S3006"]){
            [self.authImgName setValue:@"S3006LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S3001"]){
            [self.authImgName setValue:@"S3001LockShare" forKey:device.model];
        }else if ([device.model containsString:@"S300"]){
            [self.authImgName setValue:@"S300LockShare" forKey:device.model];
        }else if ([device.model containsString:@"5011"]){
            [self.authImgName setValue:@"5011LockShare" forKey:device.model];
        }else if ([device.model containsString:@"Q8"]){
            [self.authImgName setValue:@"Q8LockShare" forKey:device.model];
        }else if ([device.model containsString:@"G8012"]){
            [self.authImgName setValue:@"8012LockShare" forKey:device.model];
        }else if ([device.model containsString:@"G3560"]){
            [self.authImgName setValue:@"5200-A6JLockShare" forKey:device.model];
        }else if ([device.model containsString:@"G3350"]){
            [self.authImgName setValue:@"5200-A5PJLockShare" forKey:device.model];
        }else if ([device.model containsString:@"A8"]){
            [self.authImgName setValue:@"A8LockShare" forKey:device.model];
        }else{
            [self.authImgName setValue:@"KDSLockShare" forKey:device.model];
        }
    }
    
}

//wifi锁详情页面（主用户）
-(void)setWFLockDetailsUI:(KDSWifiLockModel *)device
{
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.snHead isEqualToString:[device.wifiSN substringToIndex:3]]
            && product.snHead != nil && device.wifiSN != nil
            && product.snHead.length >0 && device.wifiSN.length >0) {

            [self.productModel setValue:product.productModel forKey:device.productModel];
            if (KDSScreenWidth <= 375) {
                [self.adminImgName setValue:product.adminUrl2x forKey:device.productModel];
            }else{
                [self.adminImgName setValue:product.adminUrl3x forKey:device.productModel];
            }
            return;
        }
    }

    if (![[self.adminImgName allKeys] containsObject:device.productModel] && device.productModel != nil && device.productModel.length >0) {
        if ([device.productModel containsString:@"KX"]){
            [self.adminImgName setValue:@"kxLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K7"]){
            [self.adminImgName setValue:@"K7Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K8-T"]){
            [self.adminImgName setValue:@"k8-TLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"KX-T"] || [device.productModel containsString:@"K8300"]){
            [self.adminImgName setValue:@"KX-TLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K8"]){
            [self.adminImgName setValue:@"k8Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K9W"]){
            [self.adminImgName setValue:@"K9WLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K10W"]){
            [self.adminImgName setValue:@"K10WLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K9"]){
            [self.adminImgName setValue:@"k9Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"QZ012"]){
            [self.adminImgName setValue:@"qz012Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"QZ013"]){
            [self.adminImgName setValue:@"qz013Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S800"]){
            [self.adminImgName setValue:@"S800Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"V6"]||[device.productModel containsString:@"V350"]){
            [self.adminImgName setValue:@"v6Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"V7"]||[device.productModel containsString:@"S100"]){
            [self.adminImgName setValue:@"v7Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K100"] || [device.productModel containsString:@"V450"]){
            [self.adminImgName setValue:@"K100Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"H5606"]){
            [self.adminImgName setValue:@"H5606Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S6"]){
            [self.adminImgName setValue:@"S6Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8008"]){
            [self.adminImgName setValue:@"8008Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100B"]){
            [self.adminImgName setValue:@"8100BLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100C"]){
            [self.adminImgName setValue:@"8100C Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100"]){
            [self.adminImgName setValue:@"8100Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S700"]){
            [self.adminImgName setValue:@"S700Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S8"]){
            [self.adminImgName setValue:@"S8Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K200"]){
            [self.adminImgName setValue:@"K200Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S3006"]){
            [self.adminImgName setValue:@"S3006Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S3001"]){
            [self.adminImgName setValue:@"S3001Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S300"]){
            [self.adminImgName setValue:@"S300Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"5011"]){
            [self.adminImgName setValue:@"5011Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"Q8"]){
            [self.adminImgName setValue:@"Q8Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G8012"]){
            [self.adminImgName setValue:@"8012Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G3560"]){
            [self.adminImgName setValue:@"5200-A6JLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G3350"]){
            [self.adminImgName setValue:@"5200-A5PJLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"A8"]){
            [self.adminImgName setValue:@"A8Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K11W"]){
            [self.adminImgName setValue:@"K11WLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K12W"]){
            [self.adminImgName setValue:@"K12WLock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K13"]){
            [self.adminImgName setValue:@"K13Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"X1"]){
            [self.adminImgName setValue:@"X1Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S110"]){
            [self.adminImgName setValue:@"S110Lock" forKey:device.productModel];
        }else if ([device.productModel containsString:@"F1"]){
            [self.adminImgName setValue:@"F1Lock" forKey:device.productModel];
        }else{
            [self.adminImgName setValue:@"lock_pic" forKey:device.productModel];
        }
    }
    
}
//wifi锁详情页面(授权用户)
-(void)setWFShareLockDetailsUI:(KDSWifiLockModel *)device
{
    for (KDSProductInfoList * product in [KDSUserManager sharedManager].productInfoList) {
        if ([product.developmentModel isEqualToString:device.productModel]
            && product.developmentModel != nil && device.productModel != nil
            && product.developmentModel.length >0 && device.productModel.length >0
            
            && [product.snHead isEqualToString:[device.wifiSN substringToIndex:3]]
            && product.snHead != nil && device.wifiSN != nil
            && product.snHead.length >0 && device.wifiSN.length >0) {
            
            [self.productModel setValue:product.productModel forKey:device.productModel];
            if (KDSScreenWidth <= 375) {
                [self.authImgName setValue:product.authUrl2x forKey:device.productModel];
            }else{
                [self.authImgName setValue:product.authUrl3x forKey:device.productModel];
            }
            return;
        }
    }
    if (![[self.authImgName allKeys] containsObject:device.productModel] && device.productModel != nil && device.productModel.length >0) {
        if ([device.productModel containsString:@"KX"]){
            [self.authImgName setValue:@"kxLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K7"]){
            [self.authImgName setValue:@"k7LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K8-T"]){
            [self.authImgName setValue:@"k8-TLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"KX-T"] || [device.productModel containsString:@"K8300"]){
            [self.authImgName setValue:@"KX-TLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K8"]){
            [self.authImgName setValue:@"k8LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K9W"]){
            [self.authImgName setValue:@"K9WLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K10W"]){
            [self.authImgName setValue:@"K10WLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K9"]){
            [self.authImgName setValue:@"k9LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"QZ012"]){
            [self.authImgName setValue:@"qz012LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"QZ013"]){
            [self.authImgName setValue:@"qz013LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S800"]){
            [self.authImgName setValue:@"S800LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"V6"]||[device.productModel containsString:@"V350"]){
            [self.authImgName setValue:@"v6LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"V7"]||[device.productModel containsString:@"S100"]){
            [self.authImgName setValue:@"v7LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K100"] || [device.productModel containsString:@"V450"]){
            [self.authImgName setValue:@"K100LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"H5606"]){
            [self.authImgName setValue:@"H5606LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S6"]){
            [self.authImgName setValue:@"S6LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8008"]){
            [self.authImgName setValue:@"8008LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100B"]){
            [self.authImgName setValue:@"8100BLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100C"]){
            [self.authImgName setValue:@"8100CLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"8100"]){
            [self.authImgName setValue:@"8100LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S700"]){
            [self.authImgName setValue:@"S700LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S8"]){
            [self.authImgName setValue:@"S8LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K200"]){
            [self.authImgName setValue:@"K200LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S3006"]){
            [self.authImgName setValue:@"S3006LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S3001"]){
            [self.authImgName setValue:@"S3001LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S300"]){
            [self.authImgName setValue:@"S300LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"5011"]){
            [self.authImgName setValue:@"5011LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"Q8"]){
            [self.authImgName setValue:@"Q8LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G8012"]){
            [self.authImgName setValue:@"8012LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G3560"]){
            [self.authImgName setValue:@"5200-A6JLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"G3350"]){
            [self.authImgName setValue:@"5200-A5PJLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"A8"]){
            [self.authImgName setValue:@"A8LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K11W"]){
            [self.authImgName setValue:@"K11WLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K12W"]){
            [self.authImgName setValue:@"K12WLockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"K13"]){
            [self.authImgName setValue:@"K13LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"X1"]){
            [self.authImgName setValue:@"X1LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"S110"]){
            [self.authImgName setValue:@"S110LockShare" forKey:device.productModel];
        }else if ([device.productModel containsString:@"F1"]){
            [self.authImgName setValue:@"F1LockShare" forKey:device.productModel];
        }else{
            [self.authImgName setValue:@"KDSLockShare" forKey:device.productModel];
        }
    }
    
}

- (UIImage *)getDeviceImgWithImgName:(NSString *)imgName completion:(void (^)(UIImage * _Nullable))completion
{
    [YBIBWebImageManager queryCacheOperationForKey:[NSURL URLWithString:imgName] completed:^(UIImage * _Nullable image, NSData * _Nullable data) {
        if (image) {
            //读取缓存
            return !completion ?: completion(image);
        }else{
            [YBIBWebImageManager downloadImageWithURL:[NSURL URLWithString:imgName] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                //下载进度，暂时没有用到
            } success:^(UIImage * _Nullable image, NSData * _Nullable data, BOOL finished) {
                //下载成功赋值给imgview
                if (image && finished) {
                    [YBIBWebImageManager storeImage:image imageData:data forKey:[NSURL URLWithString:imgName] toDisk:YES];
                    return !completion ?: completion(image);
                }
            } failed:^(NSError * _Nullable error, BOOL finished) {
                return !completion ?: completion(nil);
            }];
        }
    }];
    return nil;
}


#pragma mark --Lazy load
- (NSMutableDictionary *)adminImgName
{
    if (!_adminImgName) {
        _adminImgName = [[NSMutableDictionary alloc] init];
    }
    return _adminImgName;
}
- (NSMutableDictionary *)deviceListImgName
{
    if (!_deviceListImgName) {
        _deviceListImgName = [[NSMutableDictionary alloc] init];
    }
    return _deviceListImgName;
}
- (NSMutableDictionary *)authImgName
{
    if (!_authImgName) {
        _authImgName = [[NSMutableDictionary alloc] init];
    }
    return _authImgName;
}
- (NSMutableDictionary *)productModel
{
    if (!_productModel) {
        _productModel = [[NSMutableDictionary alloc] init];
    }
    return _productModel;
}

@end
