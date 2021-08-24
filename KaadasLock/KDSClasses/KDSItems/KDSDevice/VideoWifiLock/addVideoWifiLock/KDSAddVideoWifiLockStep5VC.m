//
//  KDSAddVideoWifiLockStep5VC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/8.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddVideoWifiLockStep5VC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSVideoLockDistributionNetworkVC.h"
#import "KDSMediaLockInPutAdminPwdVC.h"
#import "KDSWifiLockModel.h"
#import "KDSAddWiFiLockFailVC.h"
#import "KDSXMMediaLockHelpVC.h"


@interface KDSAddVideoWifiLockStep5VC ()

@property (nonatomic,strong)UIImageView * QRCodeImg;
///是否已经push过（只能执行一次）
@property (nonatomic, assign) BOOL ispushing;
// 当前试图控制器的亮度
@property (nonatomic, readwrite, assign) CGFloat currentLight;


@end

///label之间多行显示的行间距
#define labelWidth  5
@implementation KDSAddVideoWifiLockStep5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ispushing = YES;
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    
    KDSUserManager * user = [KDSUserManager sharedManager];
    ///先去服务器请求讯美认证token，请求失败的话，没有必要进行下一步了，直接返回
    NSString *jsonStr = [self convertToJsonData:@{@"s":self.ssid,@"p":self.pwd,@"u":user.user.uid}];
    [self generateQRCodeWithStr:jsonStr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaLockBindStatus:) name:KDSMQTTEventNotification object:nil];
}
// 进入控制器完成后，让控制器变量
- (void)viewDidAppear:(BOOL)animated
{
    [[UIScreen mainScreen] setBrightness: 0.9];//0.1~1.0之间，值越大越亮
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KDSMQTTEventNotification object:nil];
    [[UIScreen mainScreen] setBrightness: 0.5];
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(3);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第五步：门锁扫描二维码";
    if (self.lock) {
        tipMsgLabe1.text = @"第三步：门锁扫描二维码";
    }if (self.isAgainNetwork) {
        tipMsgLabe1.text = @"第四步：门锁扫描二维码";
    }
    
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.width.equalTo(@261);
        make.centerX.equalTo(self.view);
    }];
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"① 请距离锁端前面板的摄像头10-15CM";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(15);
        make.height.mas_equalTo(16);
        make.width.equalTo(@261);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"② 出示此二维码，扫描成功后语音播报：“扫描成功，配网中”";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    tipMsg1Labe.numberOfLines = 0;
    tipMsg1Labe.tag = 1;
    [self setLabelSpace:tipMsg1Labe withSpace:labelWidth withFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(0);
        make.height.mas_equalTo(45);
        make.width.equalTo(@261);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③ 根据语音提示，点击对应的按钮";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(0);
        make.height.mas_equalTo(16);
        make.width.equalTo(@261);
        make.centerX.equalTo(self.view);
        
    }];
    ///添加门锁的logo
    self.QRCodeImg = [UIImageView new];
    [self.view addSubview:self.QRCodeImg];
    [self.QRCodeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(227);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(KDSScreenHeight <= 667 ? 30 : 65);
    }];
    
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"提示：因手机屏幕尺寸不同，请移动手机在距离门锁摄像头10-50CM范围内扫描";
    tipMsg3Labe.font = [UIFont systemFontOfSize:12];
    tipMsg3Labe.textColor = KDSRGBColor(153, 153, 153);
    tipMsg3Labe.textAlignment = NSTextAlignmentCenter;
    tipMsg3Labe.numberOfLines = 0;
    tipMsg3Labe.tag = 2;
    [self setLabelSpace:tipMsg3Labe withSpace:labelWidth withFont:[UIFont systemFontOfSize:12]];
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.QRCodeImg.mas_bottom).offset(10);
        make.height.mas_equalTo(45);
        make.width.equalTo(@235);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton * reNetworkBtn = [UIButton new];
    [reNetworkBtn setTitle:@"配网失败，重试" forState:UIControlStateNormal];
    [reNetworkBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [reNetworkBtn addTarget:self action:@selector(reNetworkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    reNetworkBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    reNetworkBtn.backgroundColor = UIColor.whiteColor;
    reNetworkBtn.layer.borderWidth = 1;
    reNetworkBtn.layer.masksToBounds = YES;
    reNetworkBtn.layer.cornerRadius = 20;
    reNetworkBtn.layer.borderColor = KDSRGBColor(31, 150, 247).CGColor;
    [self.view addSubview:reNetworkBtn];
    [reNetworkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
    }];
    
    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"Wi-Fi已连接，下一步" forState:UIControlStateNormal];
    [connectBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(connectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    connectBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    connectBtn.layer.masksToBounds = YES;
    connectBtn.layer.cornerRadius = 20;
    [self.view addSubview:connectBtn];
    [connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(reNetworkBtn.mas_top).offset(KDSScreenHeight > 667 ? -30 : -16);
    }];
    
    
}


-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    if (label.tag == 2) {
        paraStyle.alignment = NSTextAlignmentCenter;
    }else{
        paraStyle.alignment = NSTextAlignmentLeft;
    }
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

- (void)generateQRCodeWithStr:(NSString *)mesStr{
    
    //创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据
    NSString *string = mesStr;
    //将NSString格式转化成NSData格式
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSLog(@"配网时候的json字符串：%@-----data数据：%@",mesStr,data);
    [filter setValue:data forKeyPath:@"inputMessage"];
    //获取二维码过滤器生成的二维码
    CIImage *image = [filter outputImage];
    //将获取到的二维码添加到imageview上
    self.QRCodeImg.image =[self createNonInterpolatedUIImageFormCIImage:image withSize:550];
    //----------------给 二维码 中间增加一个 自定义图片----------------
    //开启绘图,获取图形上下文  (上下文的大小,就是二维码的大小)
    UIGraphicsBeginImageContext(self.QRCodeImg.image.size);
    //把二维码图片画上去. (这里是以,图形上下文,左上角为 (0,0)点)
    UIGraphicsBeginImageContextWithOptions(self.QRCodeImg.image.size, NO, [[UIScreen mainScreen] scale]);
    [self.QRCodeImg.image drawInRect:CGRectMake(0, 0, self.QRCodeImg.image.size.width, self.QRCodeImg.image.size.height)];
    //再把小图片画上去
    UIImage *sImage = [UIImage imageNamed:@"RQCodeLogo"];
    CGFloat sImageW = 150;
    CGFloat sImageH= 66;
    CGFloat sImageX = (self.QRCodeImg.image.size.width - sImageW) * 0.5;
    CGFloat sImgaeY = (self.QRCodeImg.image.size.height - sImageH) * 0.5;
    [sImage drawInRect:CGRectMake(sImageX, sImgaeY, sImageW, sImageH)];
    //获取当前画得的这张图片
    UIImage *finalyImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭图形上下文
    UIGraphicsEndImageContext();
    //设置图片
    self.QRCodeImg.image = finalyImage;
}
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


// 字典转json字符串方法
-(NSString *)convertToJsonData:(NSDictionary *)dict
{    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark --点击事件

//Wi-Fi已连接，下一步
-(void)connectBtnClick:(UIButton *)sender
{
    KDSVideoLockDistributionNetworkVC * vc = [KDSVideoLockDistributionNetworkVC new];
    vc.ssid = self.ssid;
    vc.pwd = self.pwd;
    [self.navigationController pushViewController:vc animated:YES];
}
//语音播报”配网失败“回到输入ssid、pwd页面重新输入
-(void)reNetworkBtnClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)navRightClick
{
    KDSXMMediaLockHelpVC * vc = [KDSXMMediaLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -- 视频锁绑定结果的通知
- (void)mediaLockBindStatus:(NSNotification *)noti
{
    KDSWifiLockModel * model = [KDSWifiLockModel new];
    MQTTSubEvent  subevent = noti.userInfo[MQTTEventKey];
    NSDictionary *param = noti.userInfo[MQTTEventParamKey];
    if ([subevent isEqualToString:MQTTSubEventMdeiaLockBindSucces]) {//视频锁绑定成功
        model.device_sn = param[@"device_sn"];
        model.mac = param[@"mac"];
        model.device_did = param[@"device_did"];
        model.p2p_password = param[@"p2p_password"];
        // 数据对比
        NSLog(@"zhu--  KDSAddVideoWifiLockStep5VC --数据对比 p2p 密码 ==%@",model.p2p_password);
        
        model.wifiName = self.ssid;
        model.wifiSN = param[@"wfId"];
        KDSMediaLockInPutAdminPwdVC * vc = [KDSMediaLockInPutAdminPwdVC new];
        vc.model = model;
        vc.crcData = param[@"randomCode"];
        if (self.ispushing) {
            self.ispushing = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if ([subevent isEqualToString:MQTTSubEventMdeiaLockBindErrorNotity]){
        //不管超时还是其他错误，都结束配网且失败
        KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


@end
