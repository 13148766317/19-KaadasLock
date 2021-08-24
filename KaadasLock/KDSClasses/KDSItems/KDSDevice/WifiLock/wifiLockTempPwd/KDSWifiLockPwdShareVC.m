//
//  KDSWifiLockPwdShareVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/17.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWifiLockPwdShareVC.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+MJ.h"
//#import <WechatOpenSDK/WXApi.h>
#import "UIView+Extension.h"
#import "NSString+extension.h"
#import "KDSBleAssistant.h"

@interface KDSWifiLockPwdShareVC ()<MFMessageComposeViewControllerDelegate>

///label for displaying pin name.
@property (nonatomic, strong) UILabel *editNicknameLabel;
///当前密码标签（胁迫密码的时候会用到）
@property (nonatomic ,strong) NSString * numStr;

@end

@implementation KDSWifiLockPwdShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    [self creatOfflinePwd];
    self.navigationTitleLabel.text = Localized(@"tempPassword");
    if (self.model.num.intValue == 9) {
        self.numStr = Localized(@"menacePIN");
    }else{
        self.numStr = @"";
    }
    [self setupUI];
}
-(void)creatOfflinePwd
{
    ///随机数 + eSN + 时间戳 哈希运算取前4字节，取余 10e6 ，即是临时密码（即生成起30分钟内生效）
    NSString * randomCode = [self.lock.wifiDevice.randomCode uppercaseString];
    NSString * wifiSN = [self.lock.wifiDevice.wifiSN uppercaseString];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    int temp = (int)([datenow timeIntervalSince1970])/5/60;//把utc时间转换成 刻度
    NSString * currentStr = @"";
    currentStr = [currentStr stringByAppendingFormat:@"%@%@%d",wifiSN,randomCode,temp];
    //测试数据
    // currentStr = @"WF01193810001000000000000000000000000000000000000000000000000000000005156785";
    NSString * haxi = [NSString sha256HashFor:currentStr];
    NSData * zifuc16 = [KDSBleAssistant convertHexStrToData:haxi];
    Byte * byttt = (Byte *)[zifuc16 bytes];
    Byte uiu[4] = {};
    uiu[0] = byttt[0];
    uiu[1] = byttt[1];
    uiu[2] = byttt[2];
    uiu[3] = byttt[3];
    long long int zxphr = (long long int)[NSString bytesToIntWithBytes:uiu offset:0];
    NSString * pwd = [NSString stringWithFormat:@"%06ld",(long)zxphr%1000000];
    NSLog(@"%lld",zxphr);
    KDSPwdListModel * model = [KDSPwdListModel new];
    model.pwd = pwd;
    model.createTime = [datenow timeIntervalSince1970];
    self.model = model;
}

- (void)setupUI
{
    UILabel *label = [self createLabelWithText:@"" color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];//validation description
    label.text = Localized(@"pwd valid for 30 minutes");
    NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
    KDSPwdListModel *m = self.model;
    m.pwd = self.model.pwd;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    self.model.schedule = label.text;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 25 : 52);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    NSMutableString *ms = [NSMutableString stringWithCapacity:m.pwd.length * 2 - 2];
    for (int i = 0; i < m.pwd.length; ++i)
    {
        [ms appendFormat:@"%c%@", m.pwd.UTF8String[i], i==m.pwd.length-1 ? @"" : @"   "];
    }
    UILabel *pwdLabel = [self createLabelWithText:ms color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:25]];
    pwdLabel.textAlignment = NSTextAlignmentCenter;
    if (pwdLabel.bounds.size.width > kScreenWidth - 40)
    {
        pwdLabel.font = [UIFont systemFontOfSize:19 * (kScreenWidth - 40) / pwdLabel.bounds.size.width];
    }
    [self.view addSubview:pwdLabel];
    [pwdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 76 : 126);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.equalTo(@(pwdLabel.bounds.size.height));
    }];
    
    UIView * cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    cornerView.layer.masksToBounds = YES;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pwdLabel.mas_bottom).offset(KDSSSALE_HEIGHT(70));
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@50);
    }];
    
    UILabel *tLabel = [self createLabelWithText:Localized(@"authTime") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:15]];//显示”授权时间“
    [cornerView addSubview:tLabel];
    [tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(@0);
        make.left.equalTo(cornerView).offset(26);
        make.width.equalTo(@(tLabel.bounds.size.width));
        make.height.equalTo(@50);
    }];
    
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
//    NSTimeInterval serverTimer = [KDSHttpManager sharedManager].serverTime;
//    NSDate *date = serverTimer>0 ? [NSDate dateWithTimeIntervalSince1970:serverTimer] : NSDate.date;
    UILabel *timeLabel = [self createLabelWithText:[fmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.model.createTime]] color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    [cornerView addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(@0);
        make.left.equalTo(tLabel.mas_right).offset(kScreenWidth<375 ? 26 : 37);
        make.right.equalTo(cornerView).offset(kScreenWidth<375 ? 26 : 37);
        make.height.equalTo(@50);
    }];
    
    NSArray<UIButton *> *btns = [self createShareButtonsWithTitles:@[Localized(@"shortMessage"), Localized(@"weixin"), Localized(@"copy")] images:@[@"shortMessage", @"weixin", @"pasteboard"]];
    UIButton *weixinBtn = btns[1];
    CGFloat space = (kScreenWidth - weixinBtn.bounds.size.width*3) / 4;
    [weixinBtn addTarget:self action:@selector(clickWeixinBtnShareToWeixin:) forControlEvents:UIControlEventTouchUpInside];
    [weixinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(92));
        make.centerX.equalTo(@0);
        make.size.mas_equalTo(weixinBtn.bounds.size);
    }];
    
    UIButton *msgBtn = btns.firstObject;
    [msgBtn addTarget:self action:@selector(clickShortMessageBtnSendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [msgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weixinBtn);
        make.right.equalTo(weixinBtn.mas_left).offset(-space);
        make.size.mas_equalTo(msgBtn.bounds.size);
    }];
    
    UIButton *cpyBtn = btns.lastObject;
    [cpyBtn addTarget:self action:@selector(clickCopyBtnCopyToPasteboard:) forControlEvents:UIControlEventTouchUpInside];
    [cpyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weixinBtn);
        make.left.equalTo(weixinBtn.mas_right).offset(space);
        make.size.mas_equalTo(cpyBtn.bounds.size);
    }];
    
    UILabel *tipsLabel = [self createLabelWithText:Localized(@"save or share your password with the guests") color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.numberOfLines = 0;
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weixinBtn.mas_top).offset(-24);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    
}

- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

- (NSArray<UIButton *> *)createShareButtonsWithTitles:(NSArray<NSString *> *)titles images:(NSArray<NSString *> *)imgNames
{
    CGFloat tWidth = 0;
    UIFont *font = [UIFont systemFontOfSize:12];
    for (NSString *title in titles)
    {
        tWidth = MAX(tWidth, ceil([title sizeWithAttributes:@{NSFontAttributeName : font}].width));
    }
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:titles.count];
    for (int i = 0; i < titles.count; ++i)
    {
        NSString *title = titles[i];
        NSString *imgName = i<imgNames.count ? imgNames[i] : nil;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateHighlighted];
        [btn setTitleColor:KDSRGBColor(0x99, 0x99, 0x99) forState:UIControlStateNormal];
        
        btn.titleLabel.font = font;
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : font}];
        CGFloat iWidth = btn.currentImage.size.width;
        CGFloat width = MAX(iWidth, tWidth);
        btn.bounds = CGRectMake(0, 0, width, iWidth + 7 + ceil(size.height));
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, (width - iWidth) * 0.5, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(iWidth + 7, -iWidth + (width - ceil(size.width)) * 0.5, 0, 0);
        [btns addObject:btn];
        [self.view addSubview:btn];
    }
    
    return btns.copy;
}

#pragma mark - 控件等事件方法。

///点击短信按钮，短信发送。
- (void)clickShortMessageBtnSendMessage:(UIButton *)sender
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc]init];
        NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
        controller.body = string;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"notSupportShortMessage") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }

}

///点击微信按钮分享。
- (void)clickWeixinBtnShareToWeixin:(UIButton *)sender
{
    if (![WXApi isWXAppInstalled])
    {
        [MBProgressHUD showError:Localized(@"wechatIsNotInstalled")];
        return;
    }
    NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = YES;
    req.text = string;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
   
}

///点击复制按钮复制密码到剪贴板。
- (void)clickCopyBtnCopyToPasteboard:(UIButton *)sender
{
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    NSString *string = [NSString stringWithFormat:@"【凯迪仕智能】密码: %@。此密码只能用于凯迪仕智能锁验证开门,%@%@。",self.model.pwd,self.numStr,self.model.schedule];
    [pab setString:string];
    if (pab == nil) {
        [MBProgressHUD showSuccess:Localized(@"copySuccess")];
    }else
    {
        [MBProgressHUD showSuccess:Localized(@"hasCopy")];
    }

}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}



@end
