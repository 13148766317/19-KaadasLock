//
//  KDSGWDetailCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/8/21.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGWDetailCell.h"
#import "GatewayDeviceModel.h"

@interface KDSGWDetailCell ()

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

@implementation KDSGWDetailCell

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
        self.deviceIV.image = [UIImage imageNamed:@"K7"];
        self.deviceIV.contentMode = UIViewContentModeCenter;
        [self.containerView addSubview:self.deviceIV];
        [self.deviceIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@92);
            make.left.equalTo(self.containerView);
            make.top.bottom.equalTo(self.containerView);
        }];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        self.nameLabel.numberOfLines = 1;
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self.containerView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.containerView).offset(31);
            make.left.equalTo(self.deviceIV.mas_right).offset(8);
            make.right.equalTo(self.containerView).offset(-15);
            make.height.mas_equalTo(17);
        }];
        
        self.abroadPowerIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"offline battery_icon"]];
        self.abroadPowerIV.contentMode =  UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.abroadPowerIV];
        [self.abroadPowerIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(17);
            make.left.equalTo(self.nameLabel);
            make.width.mas_equalTo(23);
            make.height.mas_equalTo(12);
        }];
        
        self.powerIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"onLineElectric"]];
        self.powerIV.layer.cornerRadius = 1;
        [self.containerView addSubview:self.powerIV];
        [self.powerIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(18);
            make.left.equalTo(self.deviceIV.mas_right).offset(9);
            make.width.mas_equalTo(18);
            make.height.mas_equalTo(10);
        }];
        
        self.powerLabel = [UILabel new];
        self.powerLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        self.powerLabel.font = [UIFont systemFontOfSize:12];
        [self.containerView addSubview:self.powerLabel];
        [self.powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(17);
            make.left.equalTo(self.abroadPowerIV.mas_right).offset(8);
            make.width.mas_equalTo(60);
        }];
        
        self.stateIV = [UIImageView new];
        self.stateIV.contentMode =  UIViewContentModeScaleAspectFill;
        [self.containerView addSubview:self.stateIV];
        [self.stateIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(17);
            make.left.equalTo(self.powerLabel.mas_right).offset(KDSSSALE_WIDTH(52));
            make.width.height.equalTo(@17);
        }];
        
        self.stateLabel = [UILabel new];
        self.stateLabel.font = [UIFont systemFontOfSize:12];
        [self.containerView addSubview:self.stateLabel];
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(17);
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
    _model = model;
    if ([model isKindOfClass:KDSCatEye.class]) {
        [self setCateyeUI:model];
    }else if ([model isKindOfClass:KDSGW.class]) {///网关
        [self setGateWayUI:model];
        return;
    }else if ([model isKindOfClass:KDSLock.class]){
        if ([model gwDevice])
        {
            [self setGwLockUI:model];
        }
        else
        {
            [self setBleLockUI:model];
        }
    }
}
///设置蓝牙锁界面
-(void)setBleLockUI:(KDSLock *)lock
{
    MyDevice *d = lock.device;
    if ([d.model containsString:@"KX"]){
        self.deviceIV.image = [UIImage imageNamed:@"KX"];
    }else if ([d.model containsString:@"K7"]){
        self.deviceIV.image = [UIImage imageNamed:@"K7"];
    }
    else if ([d.model containsString:@"K8-T"]){
        self.deviceIV.image = [UIImage imageNamed:@"K8-T"];
    }
    else if ([d.model containsString:@"KX-T"] || [d.model containsString:@"K8300"]){
        self.deviceIV.image = [UIImage imageNamed:@"KX-T"];
    }
    else if ([d.model containsString:@"K8"]){
        self.deviceIV.image = [UIImage imageNamed:@"K8"];
    }else if ([d.model containsString:@"K9"]){
        self.deviceIV.image = [UIImage imageNamed:@"K9"];
    }else if ([d.model containsString:@"QZ012"]){
        self.deviceIV.image = [UIImage imageNamed:@"QZ012"];
    }else if ([d.model containsString:@"QZ013"]){
        self.deviceIV.image = [UIImage imageNamed:@"QZ013"];
    }else if ([d.model containsString:@"S8"]){
        self.deviceIV.image = [UIImage imageNamed:@"S8"];
    }else if ([d.model containsString:@"V6"]||[d.model containsString:@"V350"]){
        self.deviceIV.image = [UIImage imageNamed:@"V6"];
    }else if ([d.model containsString:@"V7"]||[d.model containsString:@"S100"]){
        self.deviceIV.image = [UIImage imageNamed:@"V7"];
    }else if ([d.model containsString:@"K100"] || [d.model containsString:@"V450"]){
        self.deviceIV.image = [UIImage imageNamed:@"K100"];
    }else if ([d.model containsString:@"H5606"]){
        self.deviceIV.image = [UIImage imageNamed:@"H5606"];
    }else if ([d.model containsString:@"S6"]){
        self.deviceIV.image = [UIImage imageNamed:@"S6"];
    }
    else if ([d.model containsString:@"Q8"]){
        self.deviceIV.image = [UIImage imageNamed:@"Q8"];
    }
    else if ([d.model containsString:@"G8012"]){
        self.deviceIV.image = [UIImage imageNamed:@"8012"];
    }
    else if ([d.model containsString:@"G3560"]){
        self.deviceIV.image = [UIImage imageNamed:@"5200-A6J"];
    }
    else if ([d.model containsString:@"G3350"]){
        self.deviceIV.image = [UIImage imageNamed:@"5200-A5PJ"];
    }
    else if ([d.model containsString:@"A8"]){
        self.deviceIV.image = [UIImage imageNamed:@"A8"];
    }
    else{
        self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
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
    self.deviceIV.image = [UIImage imageNamed:@"Gateway_pic"];
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
    if ([device.deviceType containsString:@"KX"]){
        self.deviceIV.image = [UIImage imageNamed:@"KX"];
    }else if ([device.deviceType containsString:@"K7"]){
        self.deviceIV.image = [UIImage imageNamed:@"K7"];
    }else if ([device.deviceType containsString:@"K8-T"]){
        self.deviceIV.image = [UIImage imageNamed:@"K8-T"];
    }else if ([device.deviceType containsString:@"K8"]){
        self.deviceIV.image = [UIImage imageNamed:@"K8"];
    }else if ([device.deviceType containsString:@"K9"]){
        self.deviceIV.image = [UIImage imageNamed:@"K9"];
    }else if ([device.deviceType containsString:@"QZ012"]){
        self.deviceIV.image = [UIImage imageNamed:@"QZ012"];
    }else if ([device.deviceType containsString:@"QZ013"]){
        self.deviceIV.image = [UIImage imageNamed:@"QZ013"];
    }else if ([device.deviceType containsString:@"S8"]){
        self.deviceIV.image = [UIImage imageNamed:@"S8"];
    }else if ([device.deviceType containsString:@"V6"]||[device.deviceType containsString:@"V350"]){
        self.deviceIV.image = [UIImage imageNamed:@"V6"];
    }else if ([device.deviceType containsString:@"V7"]||[device.deviceType containsString:@"S100"]){
        self.deviceIV.image = [UIImage imageNamed:@"V7"];
    }else{
        self.deviceIV.image = [UIImage imageNamed:@"Unrecognized lock_pic"];
    }
    //    self.modelLabel.text = [device.device_type stringByAppendingFormat:@" %@", Localized(@"smartLock")];
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

- (void)setHideArrow:(BOOL)hideArrow
{
    _hideArrow = hideArrow;
    self.arrowIV.hidden = hideArrow;
}

@end
