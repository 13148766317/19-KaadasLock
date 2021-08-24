//
//  KDSDeviceCell.m
//  KaadasLock
//
//  Created by orange on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSDeviceCell.h"
#import "GatewayDeviceModel.h"
#import "KDSAllPhotoShowImgModel.h"

@interface KDSDeviceCell ()

///container.
@property (nonatomic, strong) UIView *containerView;
///display the device image.
@property (nonatomic, strong) UIImageView *deviceIV;
///device name label, display the device nickname.
@property (nonatomic, strong) UILabel *nameLabel;
///power image view, display the device power image.
@property (nonatomic, strong) UIImageView *powerIV;
///电量用两张图表示，一张底图，一张显示电量示意图
@property (nonatomic, strong) UIImageView * abroadPowerIV;
///power label, display the device power literals.
@property (nonatomic, strong) UILabel *powerLabel;
///state image view, display the device state image of online or offline.
@property (nonatomic, strong) UIImageView *stateIV;
///state label, display the device state description.
@property (nonatomic, strong) UILabel *stateLabel;
///the right arrow image view.
@property (nonatomic, strong) UIImageView *arrowIV;

@end

@implementation KDSDeviceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.containerView = [UIView new];
        self.containerView.backgroundColor = UIColor.whiteColor;
        self.containerView.layer.cornerRadius = 4;
        self.containerView.clipsToBounds = YES;
        [self.contentView addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
        }];
        
        self.deviceIV = [UIImageView new];
        self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
        self.deviceIV.contentMode = UIViewContentModeScaleAspectFit;
        [self.containerView addSubview:self.deviceIV];
        [self.deviceIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@92);
            make.left.equalTo(self.containerView);
            make.top.equalTo(self.containerView).offset(10);
            make.bottom.equalTo(self.containerView).offset(-10);
        }];
        
        
        
        self.nameLabel = [UILabel new];
        self.nameLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self.containerView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if ([reuseIdentifier isEqualToString:@"hanger"]) {
                make.centerY.equalTo(self.containerView.mas_centerY);
            }else {
                make.top.equalTo(self.containerView).offset(31);
            }
            
            make.left.equalTo(self.deviceIV.mas_right).offset(8);
            make.right.equalTo(self.containerView).offset(-15);
        }];
        
        self.abroadPowerIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"offline battery_icon"]];
        [self.contentView addSubview:self.abroadPowerIV];
        [self.abroadPowerIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).offset(51);
            make.left.equalTo(self.nameLabel);
            make.width.mas_equalTo(23);
            make.height.mas_equalTo(12);
        }];
        
        self.powerIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onLineElectric"]];
        self.powerIV.layer.cornerRadius = 1;
        [self.containerView addSubview:self.powerIV];
        [self.powerIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).offset(52);
            make.left.equalTo(self.deviceIV.mas_right).offset(9);
            make.width.mas_equalTo(18);
            make.height.mas_equalTo(10);
        }];
        
        self.powerLabel = [UILabel new];
        self.powerLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.powerLabel.font = [UIFont systemFontOfSize:12];
        [self.containerView addSubview:self.powerLabel];
        [self.powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.abroadPowerIV.mas_right).offset(8);
            make.centerY.equalTo(self.abroadPowerIV);
            make.right.equalTo(self).offset(-40);
        }];
        
        self.stateIV = [UIImageView new];
        [self.containerView addSubview:self.stateIV];
        [self.stateIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.containerView).offset(-31);
            make.left.equalTo(self.nameLabel);
            make.width.height.equalTo(@17);
        }];
        
        self.stateLabel = [UILabel new];
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        [self.containerView addSubview:self.stateLabel];
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.stateIV.mas_right).offset(5);
            make.centerY.equalTo(self.stateIV);
            make.right.equalTo(self).offset(-40);
        }];
        
        self.arrowIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"箭头Hight"]];
        [self.containerView addSubview:self.arrowIV];
        [self.arrowIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.right.equalTo(self.containerView).offset(-12);
            make.size.mas_equalTo(self.arrowIV.image.size);
        }];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setFrame:(CGRect)frame{
    //frame.origin.x +=10;
    frame.origin.y += 10;
    frame.size.height -= 10;
    //frame.size.width -= 20;
    [super setFrame:frame];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

///set the device power info, the param power is the ramaining electricity, if <0 , display none.
- (void)setDevicePowerInfo:(int)power
{
    if (power > 100) {
        power = 100;
    }
    float width = power/100.0;
    NSString *text = power<0 ? [Localized(@"lockEnergy") stringByAppendingFormat:@" (%@)", Localized(@"none")] : [Localized(@"lockEnergy") stringByAppendingFormat:@" %d%%", power];
    [self.powerIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(18 * width);
    }];
    self.powerLabel.text = text;
}

///set the device online or offline state image and associated description.
- (void)setDeviceStateImage:(UIImage *)image description:(NSString *)desc
{
    self.stateIV.image = image;
    self.stateLabel.text = desc;
}

- (void)setModel:(id)model
{
    self.powerLabel.hidden = NO;
    self.powerIV.hidden = NO;
    self.abroadPowerIV.hidden = NO;
    self.stateIV.hidden = NO;
    self.stateLabel.hidden = NO;
    _model = model;
    //设备列表的图片、设备详情的图片、授权设备详情图片统一在KDSAllPhotoShowImgModel管理，根据设备型号的设置对应的图片（修改一处即可）
    if ([model isKindOfClass:KDSCatEye.class]) {//猫眼
        [self setCateyeUI:model];
    }else if ([model isKindOfClass:KDSGW.class]) {//网关
        [self setGateWayUI:model];
    }else if ([model isKindOfClass:KDSLock.class]){
        if ([model gwDevice])
        {//网关锁
            [self setGwLockUI:model];
        }
        else if ([model wifiDevice])
        {//Wi-Fi锁
            [KDSAllPhotoShowImgModel shareModel].model = model;
            [self setWFLockUI:model];
        }
        else
        {//蓝牙锁
            [KDSAllPhotoShowImgModel shareModel].model = model;
            [self setBleLockUI:model];
        }
    }else if([model isKindOfClass:[KDSDeviceHangerModel class]]) {
        [self setHangerUI:model];
    }
}
//设置晾衣机
-(void)setHangerUI:(KDSDeviceHangerModel *) hanger{
    self.deviceIV.image = [UIImage imageNamed:@"hanger_cell"];
    self.nameLabel.text = hanger.hangerNickName;
    self.abroadPowerIV.hidden = YES;
    self.powerIV.hidden = YES;
    self.powerLabel.hidden = YES;
    self.stateIV.hidden = YES;

}
///设置蓝牙锁界面
-(void)setBleLockUI:(KDSLock *)lock
{
    MyDevice *d = lock.device;
    NSLog(@"锁图片存的地址的：%@",[[KDSAllPhotoShowImgModel shareModel].deviceListImgName allKeys]);
    self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].deviceListImgName allKeys]) {
        if ([imgName isEqualToString:d.model]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.model] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].deviceListImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.model] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        self.deviceIV.image = image;
                    }
                }];
            }else{
                self.deviceIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.model]];
            }
        }
    }
    [self setDevicePowerInfo:lock.power];
    if (lock.connected)
    {
        [self setDeviceStateImage:[UIImage imageNamed:@"蓝牙-连接中1"] description:Localized(@"online")];
        self.stateLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
        if (lock.power < 20) {
            self.powerIV.image = [UIImage imageNamed:@"low power"];
        }else{
            self.powerIV.image = [UIImage imageNamed:@"onLineElectric"];
        }
        
    }else
    {
        [self setDeviceStateImage:[UIImage imageNamed:@"蓝牙-未连接"] description:Localized(@"offline")];
        self.stateLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.powerIV.image = [UIImage imageNamed:@"offLineElectric"];
    }
    self.nameLabel.text = d.lockNickName ?: d.lockName;
    
}
///设置猫眼界面
-(void)setCateyeUI:(KDSCatEye *)cy
{
    GatewayDeviceModel *gwM = cy.gatewayDeviceModel;
    self.deviceIV.image = [UIImage imageNamed:@"cateye_pic"];
    [self setDevicePowerInfo:cy.powerStr];
    self.nameLabel.text = gwM.nickName ?: gwM.deviceId;
    if (!cy.online) {
        [self setDeviceStateImage:[UIImage imageNamed:@"Gateway outline_icon"] description:Localized(@"offline")];
        self.stateLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.powerIV.image = [UIImage imageNamed:@"offLineElectric"];
    }else {
        [self setDeviceStateImage:[UIImage imageNamed:@"Gateway online_icon"] description:Localized(@"online")];
        self.stateLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
        if (cy.powerStr < 20) {
            self.powerIV.image = [UIImage imageNamed:@"low power"];
        }else{
            self.powerIV.image = [UIImage imageNamed:@"onLineElectric"];
        }
    }
}

///设置网关界面
-(void)setGateWayUI:(KDSGW *)gw
{
    self.powerIV.hidden = YES;
    self.powerLabel.hidden = YES;
    self.abroadPowerIV.hidden = YES;
    
    if ([gw.model.model isEqualToString:@"6032"]||[gw.model.model isEqualToString:@"6030"]) {
        self.deviceIV.image = [UIImage imageNamed:@"6030GWList"];
    }else{
        self.deviceIV.image = [UIImage imageNamed:@"Gateway_pic"];
    }
    self.nameLabel.text = gw.model.deviceNickName ?: gw.model.deviceSN;
    if (gw.online){///在线
        [self setDeviceStateImage:[UIImage imageNamed:@"Gateway online_icon"] description:Localized(@"online")];
        self.stateLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    }else{
        [self setDeviceStateImage:[UIImage imageNamed:@"Gateway outline_icon"] description:Localized(@"offline")];
        self.stateLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    }
}

///设置网关锁界面。
- (void)setGwLockUI:(KDSLock *)lock
{
    GatewayDeviceModel *device = lock.gwDevice;
    self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
    if (lock.gwDevice.lockversion) {
        if (([[lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
             || [[lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && lock.gwDevice.lockversion) {
            self.deviceIV.image = [UIImage imageNamed:@"zigbee-8100DevIcon"];
        }
    }
    self.nameLabel.text = device.nickName ?: device.deviceId;
    [self setDevicePowerInfo:lock.power];
    if (lock.connected)
    {
        [self setDeviceStateImage:[UIImage imageNamed:@"wifiOnline1"] description:Localized(@"online")];
        self.stateLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
        if (lock.power < 20) {
            self.powerIV.image = [UIImage imageNamed:@"low power"];
        }else{
            self.powerIV.image = [UIImage imageNamed:@"onLineElectric"];
        }
    }
    else
    {
        [self setDeviceStateImage:[UIImage imageNamed:@"wifiOffline"] description:Localized(@"offline")];
        self.stateLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.powerIV.image = [UIImage imageNamed:@"offLineElectric"];
    }
}

///设置wifi锁界面。
- (void)setWFLockUI:(KDSLock *)lock
{
    self.stateIV.hidden = YES;
    self.stateLabel.hidden = YES;
    KDSWifiLockModel * d = lock.wifiDevice;
    self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
    for (NSString * imgName in [[KDSAllPhotoShowImgModel shareModel].deviceListImgName allKeys]) {
        NSLog(@"字典里面所有的图片地址：%@",[[KDSAllPhotoShowImgModel shareModel].deviceListImgName allKeys]);
        if ([imgName isEqualToString:d.productModel]) {
            if ([[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.productModel] hasPrefix:@"http://"]) {
                NSLog(@"设备列表图片下载地址：%@",[KDSAllPhotoShowImgModel shareModel].deviceListImgName);
                [[KDSAllPhotoShowImgModel shareModel] getDeviceImgWithImgName:[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.productModel] completion:^(UIImage * _Nullable image) {
                    if (image) {
                        self.deviceIV.image = image;
                    }
                }];
            }else{
                self.deviceIV.image = [UIImage imageNamed:[[KDSAllPhotoShowImgModel shareModel].deviceListImgName objectForKey:d.productModel]];
            }
        }
    }
    self.nameLabel.text = d.lockNickname ?: d.wifiSN;
    [self setDevicePowerInfo:lock.wifiDevice.power];
    [self setDeviceStateImage:[UIImage imageNamed:@"wifiOnline1"] description:Localized(@"online")];
    self.stateLabel.textColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    if (lock.wifiDevice.power < 20) {
        self.powerIV.image = [UIImage imageNamed:@"low power"];
    }else{
        self.powerIV.image = [UIImage imageNamed:@"onLineElectric"];
    }
}

- (void)setHideArrow:(BOOL)hideArrow
{
    _hideArrow = hideArrow;
    self.arrowIV.hidden = hideArrow;
}

@end
