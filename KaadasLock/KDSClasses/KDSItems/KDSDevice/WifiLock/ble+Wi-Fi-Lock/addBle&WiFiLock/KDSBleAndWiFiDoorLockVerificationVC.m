//
//  KDSBleAndWiFiDoorLockVerificationVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiDoorLockVerificationVC.h"
#import "KDSWifiLockHelpVC.h"
#import "CYCircularSlider.h"
#import "KDSBleAssistant.h"
#import "NSData+JKEncrypt.h"
#import "NSString+extension.h"
#import "KDSHttpManager+WifiLock.h"
#import "KDSAddWiFiLockFailVC.h"
#import "KDSAddBleAndWiFiLockStep1.h"
#import "KDSInPutBleAndWiFiPwdVerificationVC.h"
#import "KDSBluetoothTool.h"
#import "KDSBleAndWiFiForgetAdminPwdVC.h"
#import "KDSAddBleAndWiFiLockStep4.h"
#import "KDSDBManager.h"
#import "NSTimer+KDSBlock.h"
#import "KDSBleAndWiFiUpDataAdminiPwdVC.h"

@interface KDSBleAndWiFiDoorLockVerificationVC ()<senderValueChangeDelegate, KDSBluetoothToolDelegate>

@property (nonatomic,strong)CYCircularSlider *circularSlider;
///进度条百分比
@property (nonatomic,strong)UILabel * sliderValueLb;
///发送门锁管理员密码
@property (nonatomic,strong)UILabel * showTipsLb1;
///门锁验证管理员密码
@property (nonatomic,strong)UILabel * showTipsLb2;
///门锁设备验证中
@property (nonatomic,strong)UILabel * showTipsLb3;
///第一步
@property (nonatomic,strong)UIImageView * showTipsImg1;
@property (nonatomic,strong)UIImageView * showHideImg1;
///第二步
@property (nonatomic,strong)UIImageView * showTipsImg2;
@property (nonatomic,strong)UIImageView * showHideImg2;
///第三步
@property (nonatomic,strong)UIImageView * showTipsImg3;
@property (nonatomic,strong)UIImageView * showHideImg3;
@property (strong,nonatomic) NSMutableArray *clientSocket;
///与Wi-Fi模块数据交互成功
@property (nonatomic,assign) BOOL wifiSuccess;
///100秒没有收到模块发来成功的字符串，就失败
@property (nonatomic,strong) NSTimer * ReceiveDataOutTimer;
@property (nonatomic,strong)CABasicAnimation * rotateAnimation;
@property (nonatomic,strong)KDSWifiLockModel * model;
///管理员密码输入错误次数（5次错误即失败）
//@property (nonatomic,assign) int intPutPwdCount;
///系统锁定100秒
@property (nonatomic, assign) NSInteger countdown;

@end

@implementation KDSBleAndWiFiDoorLockVerificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"门锁验证";
    self.countdown = 99;
    [self setRightButton];
    //    self.intPutPwdCount = self.bleTool.checkNum;
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
    self.ReceiveDataOutTimer = [NSTimer scheduledTimerWithTimeInterval:100.0 target:self selector:@selector(receiveDataOutTimer:) userInfo:nil repeats:NO];
    self.bleTool.delegate = self;
    self.showTipsImg1.hidden = YES;
    self.showHideImg1.hidden = NO;
    self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
    self.showTipsLb2.textColor = KDSRGBColor(31, 31, 31);
    [self stopImgRotatingWidthImg:self.showTipsImg1];
    [self startImgRotatingWidthImg:self.showTipsImg2];
    [_circularSlider setAngleCurrent:140];
    self.sliderValueLb.text = @"50%";
    if (self.bleTool.connectedPeripheral) {
        ///校验管理员密码是否正确
        if (self.crcData.length >= 46) {
            NSLog(@"配网过程将要开始");
            [self getRandomCodeWidthAdminPwd:self.adminPwd resultData:self.crcData];
        }else{
            ///锁下发的密码因子（32+13SN+1功能集）数据错误
            [self.ReceiveDataOutTimer invalidate];
            self.ReceiveDataOutTimer = nil;
            KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else{
        
        ///蓝牙断开，需要重新链接
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:@"门锁断开连接，无法验证 " preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
                    KDSAddBleAndWiFiLockStep1 *A =(KDSAddBleAndWiFiLockStep1 *)controller;
                    [self.navigationController popToViewController:A animated:YES];
                }
            }
        }];
        [alerVC addAction:okAction];
        
        [self presentViewController:alerVC animated:YES completion:nil];
    }
}

-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius = 10;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
    }];
    
    CGRect sliderFrame = CGRectMake((KDSScreenWidth-295)/2, 55, 275,275);
    self.circularSlider =[[CYCircularSlider alloc]initWithFrame:sliderFrame];
    self.circularSlider.delegate = self;
    [_circularSlider setAngleCurrent:80];
    [supView addSubview:self.circularSlider];
    
    UIImageView * tipsImgView = [UIImageView new];
    tipsImgView.image = [UIImage imageNamed:@"addWiFiLockConnectingIcon"];
    [supView addSubview:tipsImgView];
    [tipsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@180);
        make.centerX.equalTo(supView);
        make.center.equalTo(self.circularSlider);
    }];
    
    self.sliderValueLb = [UILabel new];
    self.sliderValueLb.text = [NSString stringWithFormat:@"%@%%",@"10"];
    self.sliderValueLb.textColor = UIColor.blackColor;
    self.sliderValueLb.textAlignment = NSTextAlignmentCenter;
    self.sliderValueLb.font = [UIFont systemFontOfSize:27];
    [supView addSubview:self.sliderValueLb];
    [self.sliderValueLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@25);
        make.centerX.equalTo(supView);
        make.center.equalTo(tipsImgView);
    }];
    UILabel * tipsLb = [UILabel new];
    tipsLb.text = @"loading...";
    tipsLb.textColor = KDSRGBColor(202, 202, 202);
    tipsLb.font = [UIFont systemFontOfSize:13];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    [supView addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sliderValueLb.mas_bottom).offset(5);
        make.centerX.equalTo(supView);
        make.height.equalTo(@15);
        
    }];
    
    UILabel * tipsLb1 = [UILabel new];
    tipsLb1.text = @"请将手机和设备尽量靠近路由器";
    tipsLb1.textColor = KDSRGBColor(31, 31, 31);
    tipsLb1.textAlignment = NSTextAlignmentCenter;
    tipsLb1.font = [UIFont systemFontOfSize:14];
    [supView addSubview:tipsLb1];
    [tipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.circularSlider.mas_bottom).offset(0);
        make.height.equalTo(@20);
        make.centerX.equalTo(supView);
    }];
    
    self.showTipsImg1 =[UIImageView new];
    self.showTipsImg1.image = [UIImage imageNamed:@"addWiFiLockStatusOpenImg"];
    [supView addSubview:self.showTipsImg1];
    [self.showTipsImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg1 =[UIImageView new];
    self.showHideImg1.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg1];
    self.showHideImg1.hidden = YES;
    [self.showHideImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 123 : 73);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb1 = [UILabel new];
    self.showTipsLb1.text = @"发送门锁管理员密码";
    self.showTipsLb1.textColor = KDSRGBColor(31, 31, 31);
    self.showTipsLb1.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb1.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb1];
    [self.showTipsLb1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb1.mas_bottom).offset(KDSScreenHeight > 667 ? 120 : 70);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showTipsLb1.mas_bottom).offset(0);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    UIView * line2 = [UIView new];
    line2.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line1.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg2 =[UIImageView new];
    self.showTipsImg2.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg2];
    [self.showTipsImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg2 =[UIImageView new];
    self.showHideImg2.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg2];
    self.showHideImg2.hidden = YES;
    [self.showHideImg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line2.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb2 = [UILabel new];
    self.showTipsLb2.text = @"门锁验证管理员密码";
    self.showTipsLb2.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb2.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb2.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb2];
    [self.showTipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line2.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    UIView * line3 = [UIView new];
    line3.backgroundColor = KDSRGBColor(240, 240, 240);
    [supView addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_bottom).offset(45);
        make.height.equalTo(@1);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(supView.mas_right).offset(-28);
    }];
    self.showTipsImg3 =[UIImageView new];
    self.showTipsImg3.image = [UIImage imageNamed:@"addWiFiLockStatusOffImg"];
    [supView addSubview:self.showTipsImg3];
    [self.showTipsImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showHideImg3 =[UIImageView new];
    self.showHideImg3.image = [UIImage imageNamed:@"addWiFiLockStatusYesImg"];
    [supView addSubview:self.showHideImg3];
    self.showHideImg3.hidden = YES;
    [self.showHideImg3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@21);
        make.bottom.equalTo(line3.mas_top).offset(-3);
        make.right.equalTo(supView.mas_right).offset(-20);
    }];
    self.showTipsLb3 = [UILabel new];
    self.showTipsLb3.text = @"门锁设备验证中";
    self.showTipsLb3.textColor = KDSRGBColor(205, 205, 205);
    self.showTipsLb3.textAlignment = NSTextAlignmentLeft;
    self.showTipsLb3.font = [UIFont systemFontOfSize:13];
    [supView addSubview:self.showTipsLb3];
    [self.showTipsLb3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line3.mas_bottom).offset(0);
        make.height.equalTo(@30);
        make.left.equalTo(supView.mas_left).offset(25);
        make.right.equalTo(self.showTipsImg1.mas_left).offset(-20);
    }];
    
}

// 开始旋转
- (void)startImgRotatingWidthImg:(UIImageView *)imgView {
    self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    self.rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    self.rotateAnimation.duration = 1.0;
    self.rotateAnimation.repeatCount = MAXFLOAT;
    [imgView.layer addAnimation:self.rotateAnimation forKey:nil];
    
}
// 停止旋转
- (void)stopImgRotatingWidthImg:(UIImageView *)imgView
{
    CFTimeInterval pausedTime = [self.showTipsImg1.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    imgView.layer.speed = 0.0;
    imgView.layer.timeOffset = pausedTime;
    self.rotateAnimation.removedOnCompletion = YES;
    self.rotateAnimation.fillMode = kCAFillModeRemoved;
}

#pragma mark senderValueChangeDelegate

-(void)senderVlueWithNum:(int)num{
    
    //    self.sliderValueLb.text = [NSString stringWithFormat:@"%d%%",num];
}

#pragma mark 控件点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)navBackClick
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"确定重新开始配网吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
                KDSAddBleAndWiFiLockStep1 *A =(KDSAddBleAndWiFiLockStep1 *)controller;
                [self.navigationController popToViewController:A animated:YES];
            }
        }
    }];
    [cancelAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
    [alerVC addAction:cancelAction];
    [alerVC addAction:okAction];
    [self presentViewController:alerVC animated:YES completion:nil];
}

-(void)getRandomCodeWidthAdminPwd:(NSString *)pwd resultData:(NSData *)data
{
    NSLog(@"配网过程将要开始pwd:%@,密码因子data:%@",pwd,data);
    if ([self.adminPwd isEqualToString:@"12345678"]) {
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"" message:@"门锁初始密码不能验证，\n 请修改门锁管理密码或重新输入" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * againInPutAction = [UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        UIAlertAction * changePasswordAction = [UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            KDSBleAndWiFiUpDataAdminiPwdVC * vc = [KDSBleAndWiFiUpDataAdminiPwdVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        [changePasswordAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
        [alerVC addAction:changePasswordAction];
        [alerVC addAction:againInPutAction];
        [self presentViewController:alerVC animated:YES completion:nil];
        return;
    }
    ///28字节的随机数A+4字节的CRC32+13字节的eSN（WF开头）+ 1字节功能集共45个字节
    NSData * eSN = [data subdataWithRange:NSMakeRange(32, 13)];
    NSString * wifiSN = [[NSString alloc] initWithData:eSN encoding:NSUTF8StringEncoding];
    NSString * string = @"";
    for (int i = 0; i<pwd.length; i ++) {
        NSString * temstring = [NSString ToHex:[pwd substringWithRange:NSMakeRange(i, 1)].integerValue];
        string  = [string stringByAppendingFormat:@"%02ld",(long)temstring.integerValue];
    }
    NSData * datastring = [KDSBleAssistant convertHexStrToData:string];
    NSString *aString = [[NSString alloc] initWithData:datastring encoding:NSUTF8StringEncoding];
    //key AES256后的值
    NSString * Haxi = [NSString sha256HashFor:aString];
    NSData *resultData = [[data subdataWithRange:NSMakeRange(0, 32)] aesWifiLock256_decryptData:[KDSBleAssistant convertHexStrToData:Haxi]];
    int crc = [NSString data2Int:[resultData subdataWithRange:NSMakeRange(28, 4)]];
    //测试数据：随机数A
    int32_t randomCode = [[resultData subdataWithRange:NSMakeRange(0, 28)] crc32];
    ///添加到服务器用到的随机数A
    NSString * randomCodeData = [KDSBleAssistant convertDataToHexStr:[resultData subdataWithRange:NSMakeRange(0, 28)]];
    //    u_int8_t tt;///ble+wifi的功能集是从蓝牙读取的，不用此方法
    //    [[data subdataWithRange:NSMakeRange(45, 1)] getBytes:&tt length:sizeof(tt)];
    long long int value = randomCode;
    Byte byte[4] = {};
    byte[3] =(Byte) ((value>>24) & 0xFF);
    byte[2] =(Byte) ((value>>16) & 0xFF);
    byte[1] =(Byte) ((value>>8) & 0xFF);
    byte[0] =(Byte) (value & 0xFF);
    //    NSData *adata = [[NSData alloc] initWithBytes:byte length:4];
    //    NSLog(@"%s-%@",byte,adata);
    if (randomCode != crc) {
        [self.ReceiveDataOutTimer invalidate];
        self.ReceiveDataOutTimer = nil;
        self.bleTool.checkNum --;
        [self.bleTool sendBleAndWiFiResponseInOrOutNet:0 tsn:self.tsn cmd:KDSBleAndWiFiCRCCheck value:1];
         NSLog(@"随机数生成的CRC：%d原始CRC：%d",randomCode,crc);
        NSString * messageStr = @"门锁管理员密码验证失败\n请重新输入";
        NSString *forgetPwdStr = @"忘记密码";
        NSString * inputAgainStr = @"重新输入";
        if (self.bleTool.checkNum == 2) {
            messageStr = @"门锁管理密码验证已失败3次，\n超过5次门锁将锁定";
        }else if (self.bleTool.checkNum == 1){
            messageStr = @"门锁管理密码验证已失败4次，\n超过5次门锁将锁定";
        }else if (self.bleTool.checkNum <= 0) {
            messageStr = @"门锁管理密码验证已失败5次，\n门锁将锁定 100 S";
            forgetPwdStr = @"";
            inputAgainStr = @"";
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction * forgetPwdAction = [UIAlertAction actionWithTitle:forgetPwdStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                ///忘记密码
                KDSBleAndWiFiForgetAdminPwdVC * vc = [KDSBleAndWiFiForgetAdminPwdVC new];
                vc.bleTool = self.bleTool;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            UIAlertAction * inputAgainAction = [UIAlertAction actionWithTitle:inputAgainStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [inputAgainAction setValue:KDSRGBColor(164, 164, 164) forKey:@"titleTextColor"];
            if (inputAgainStr.length > 0) {
                [alerVC addAction:inputAgainAction];
            }
            if (forgetPwdStr.length > 0) {
                [alerVC addAction:forgetPwdAction];
            }
            [self presentViewController:alerVC animated:YES completion:nil];
            if (self.bleTool.checkNum <=0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(dismiss:) withObject:alerVC afterDelay:0.1];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[KDSAddBleAndWiFiLockStep1 class]]) {
                            KDSAddBleAndWiFiLockStep1 *A =(KDSAddBleAndWiFiLockStep1 *)controller;
                            [self.navigationController popToViewController:A animated:YES];
                            return;
                        }
                    }
                    
                });
            }
        });
        
    }else{
        ///拿到随机码、wifiSN、绑定设备
        [self.bleTool sendBleAndWiFiResponseInOrOutNet:0 tsn:self.tsn cmd:KDSBleAndWiFiCRCCheck value:0];
        self.model = [KDSWifiLockModel new];
        self.model.wifiSN = wifiSN;
        self.model.lockNickname = wifiSN;
        self.model.isAdmin = @"1";
        self.model.randomCode = randomCodeData;
        self.model.functionSet = self.bleTool.connectedPeripheral.functionSet;//@(tt).stringValue;
        self.wifiSuccess = YES;
    }
}

///首页长按开锁密码输入框限制6-12位数字密码
-(void)textFieldTextDidChange:(UITextField *)sender{
    
    char pwd[13] = {0};
    int index = 0;
    NSString *text = sender.text.length > 12 ? [sender.text substringToIndex:12] : sender.text;
    for (NSInteger i = 0; i < text.length; ++i)
    {
        unichar c = [text characterAtIndex:i];
        if (c < '0' || c > '9') continue;
        pwd[index++] = c;
    }
    sender.text = @(pwd);
    
}
-(void)dealloc
{
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    [self stopImgRotatingWidthImg:self.showTipsImg3];
}

-(void)receiveDataOutTimer:(NSTimer *)receiceDataOutTimer
{
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    KDSAddWiFiLockFailVC * vc = [KDSAddWiFiLockFailVC new];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)replyBleAndWiFiACKWithValue:(int)value Cmd:(unsigned char)cmd tsn:(int)tsn
{
    [self.ReceiveDataOutTimer invalidate];
    self.ReceiveDataOutTimer = nil;
    if (value == 0 && cmd == KDSBleAndWiFiCRCCheck) {
        ///成功进行下一步操作
        self.showTipsImg2.hidden = YES;
        self.showHideImg2.hidden = NO;
        self.showTipsImg3.hidden = YES;
        self.showHideImg3.hidden = NO;
        self.showTipsLb3.textColor = KDSRGBColor(31, 31, 31);
        [self stopImgRotatingWidthImg:self.showTipsImg2];
        self.sliderValueLb.text = @"100%";
        [_circularSlider setAngleCurrent:200];
        //ble+wifi配网
        KDSInPutBleAndWiFiPwdVerificationVC * vc = [KDSInPutBleAndWiFiPwdVerificationVC new];
        self.model.productModel = self.bleTool.connectedPeripheral.lockModelType;
        vc.model = self.model;
        vc.bleTool = self.bleTool;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        ///失败
    }
}

- (void)dismiss:(UIAlertController *)alert{
    
    [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    [alert dismissViewControllerAnimated:YES completion:nil];
}



@end
