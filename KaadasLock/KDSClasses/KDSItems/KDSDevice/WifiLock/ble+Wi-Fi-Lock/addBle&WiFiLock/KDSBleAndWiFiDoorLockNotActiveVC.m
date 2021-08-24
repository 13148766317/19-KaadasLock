//
//  KDSBleAndWiFiDoorLockNotActiveVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAndWiFiDoorLockNotActiveVC.h"
#import "KDSAddBleAndWiFiLockStep3.h"
#import "KDSWifiLockHelpVC.h"
#import "MBProgressHUD+MJ.h"
#import "XMUtil.h"
#import "KDSDBManager+XMMediaLock.h"

@interface KDSBleAndWiFiDoorLockNotActiveVC ()<UIActionSheetDelegate>

@property (nonatomic,strong)UIImage * tempImage;

@end

@implementation KDSBleAndWiFiDoorLockNotActiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addDoorLock");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [self setUI];
}


-(void)setUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(3);
    }];
    
    ///第一步
    UILabel * tipMsgLabe1 = [UILabel new];
    tipMsgLabe1.text = @"第二步：门锁激活 ";
    tipMsgLabe1.font = [UIFont systemFontOfSize:18];
    tipMsgLabe1.textColor = UIColor.blackColor;
    tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe1];
    [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsgLabe = [UILabel new];
    tipMsgLabe.text = @"①微信搜索【凯迪仕智能锁】公众号并关注";
    tipMsgLabe.font = [UIFont systemFontOfSize:14];
    tipMsgLabe.textColor = KDSRGBColor(102, 102, 102);
    tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg1Labe = [UILabel new];
    tipMsg1Labe.text = @"②进入公众号－【售后服务】，点击【产品激活】";
    tipMsg1Labe.font = [UIFont systemFontOfSize:14];
    tipMsg1Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg1Labe];
    [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg2Labe = [UILabel new];
    tipMsg2Labe.text = @"③扫描包装盒产品序列号，获取激活码";
    tipMsg2Labe.font = [UIFont systemFontOfSize:14];
    tipMsg2Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg2Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg2Labe];
    [tipMsg2Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    UILabel * tipMsg3Labe = [UILabel new];
    tipMsg3Labe.text = @"④唤醒门锁，输入激活码，按“＃”确认";
    tipMsg3Labe.font = [UIFont systemFontOfSize:14];
    tipMsg3Labe.textColor = KDSRGBColor(102, 102, 102);
    tipMsg3Labe.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipMsg3Labe];
    [tipMsg3Labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg2Labe.mas_bottom).offset(10);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.view.mas_left).offset(KDSScreenHeight < 667 ? 30 : 50);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    ///添加门锁的logo
    UIImageView * addZigBeeLocklogoImg = [UIImageView new];
    addZigBeeLocklogoImg.userInteractionEnabled = YES;
    addZigBeeLocklogoImg.image = [UIImage imageNamed:@"kaadasWXOfficialAccountImg"];
    [self.view addSubview:addZigBeeLocklogoImg];
    UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imglongTapClick:)];
    [addZigBeeLocklogoImg addGestureRecognizer:longTap];
    addZigBeeLocklogoImg.backgroundColor = UIColor.yellowColor;
    [addZigBeeLocklogoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsg3Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 30 : 52);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
        make.width.height.equalTo(@158);
    }];
    
    UILabel * tipsMsg4Lb = [UILabel new];
    tipsMsg4Lb.text = @"长按保存二维码";
    tipsMsg4Lb.textColor = KDSRGBColor(143, 143, 143);
    tipsMsg4Lb.font = [UIFont systemFontOfSize:17];
    tipsMsg4Lb.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipsMsg4Lb];
    [tipsMsg4Lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addZigBeeLocklogoImg.mas_bottom).offset(23);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton * connectBtn = [UIButton new];
    [connectBtn setTitle:@"门锁已激活" forState:UIControlStateNormal];
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
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight < 667 ? -42 : -62);
    }];
        
}
#pragma mark 点击事件

-(void)navRightClick
{
    KDSWifiLockHelpVC * vc = [KDSWifiLockHelpVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

//门锁已激活
-(void)connectBtnClick:(UIButton * )sender
{
    KDSAddBleAndWiFiLockStep3 * vc = [KDSAddBleAndWiFiLockStep3 new];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)imglongTapClick:(UILongPressGestureRecognizer *)tap
{
    if(tap.state == UIGestureRecognizerStateBegan){
       UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:nil otherButtonTitles:@"保存图片",nil];
       actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [actionSheet showInView:self.view];
        UIImageView *imgView = (UIImageView*)[tap view];
        _tempImage = imgView.image;
    }
}

#pragma - mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex ==0) {
        if(_tempImage){
       UIImageWriteToSavedPhotosAlbum(_tempImage,self,@selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:),nil);
            
        }else{
            [MBProgressHUD showError:@"保存失败"];
        }
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage*)image didFinishSavingWithError: (NSError*)error contextInfo:(void*)contextInfo
{
    NSString*message =@"";
    if(!error) {
        message =@"成功保存到相册";
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"message:message delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
        [alert show];
        
    }else{
        message = [error description];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示"message:message delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
        [alert show];
        
    }
}

@end
