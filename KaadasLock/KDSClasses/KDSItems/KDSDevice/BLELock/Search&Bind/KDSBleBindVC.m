//
//  KDSBleBindVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/12.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBleBindVC.h"
#import "Masonry.h"
#import "KDSHttpManager+Ble.h"
#import "MBProgressHUD+MJ.h"
#import "KDSBLEBindHelpVC.h"
#import "UIView+Extension.h"
#import "KDSBleAssistant.h"

@interface KDSBleBindVC ()

///步骤提示标签。
@property (nonatomic, strong) UILabel *stepLabel;
///提示图片。
@property (nonatomic, strong) UIImageView *tipsIV;
///步骤、保存按钮。
@property (nonatomic, strong) UIButton *stepBtn;
///锁型号，当代理执行时记录锁的型号。
@property (nonatomic, strong) NSString *lockModel;
///pwd1，根据蓝牙返回的序列号从服务器获取，鉴权时用。
@property (nonatomic, strong) NSString *pwd1;
///记录是否绑定成功，如果绑定成功创建一个设备对象，跳到第三步是否锁定stepBtn按钮和发送通知时使用。
@property (nonatomic, strong) MyDevice *bindedDevice;
///输入锁昵称的文本框。
@property (nonatomic, strong) UITextField *textField;
///6个预设昵称的按钮数组。
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
///连接蓝牙超时（提示框消失）
@property (nonatomic,strong) NSTimer * overTimer;

@end

@implementation KDSBleBindVC

#pragma mark - getter setter
- (UILabel *)stepLabel
{
    if (!_stepLabel)
    {
        _stepLabel = [UILabel new];
        _stepLabel.numberOfLines = 0;
        [self.view addSubview:_stepLabel];
        [_stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(kScreenHeight<667 ? 20 : 44);
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
        }];
    }
    return _stepLabel;
}

- (UITextField *)textField
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] init];
        _textField.textColor = KDSRGBColor(0x33, 0x33, 0x33);
        _textField.placeholder = Localized(@"inputOrSelectAName");
        [_textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

#pragma mark - 生命周期和界面设置方法
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.step = 0;
        self.bindedDevice = nil;
    }
    return self;
}
-(void)navBackClick
{
    NSLog(@"--{Kaadas}--self.stepBtn.tag==%ld",self.stepBtn.tag);
    if (self.stepBtn.tag == 3) {
      
        self.stepBtn.hidden = NO;
        self.stepBtn.enabled = YES;
        self.stepBtn.tag = 2;
        [self setupStep2UI];
        
    }else if (self.stepBtn.tag == 4) {
        //未保存昵称就退出
        [self alterLockNickname];

    }
    else{
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addBLEDoorLock");
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.tipsIV = [[UIImageView alloc] init];
    [self.view addSubview:self.tipsIV];
    [self.tipsIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
    }];
    
    self.stepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stepBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [self.stepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.stepBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    self.stepBtn.layer.cornerRadius = 22;
    [self.stepBtn addTarget:self action:@selector(stepBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stepBtn];
    [self.stepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-50);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
    
    if (self.step == 1)
    {
        self.stepBtn.tag = 1;
        [self stepBtnAction:self.stepBtn];
    }
    else
    {
        [self setStepLabelAttributeTextAtStep:1];
        self.tipsIV.image = [UIImage imageNamed:@"添加网关智能锁1"];
        [self.tipsIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset((kScreenHeight - kStatusBarHeight - kNavBarHeight - self.tipsIV.image.size.height) * 6.0 / 13);
            make.size.mas_equalTo(self.tipsIV.image.size);
        }];
    }
    
    //导航栏帮助按钮。
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"questionMark"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showDeviceBleSearchHelp:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleTool.isBinding = !self.hasBinded;
    //锁被重置时跳进来已经有序列号了。
    if (self.destPeripheral.serialNumber.length)
    {
        //由于解密退网收到的数据的时候要使用密码1+<00 00 00 00>，不能使用密码1+密码2，否则解密的数据不对，因此这里要置空密码2
        self.bleTool.pwd2 = nil;
        self.bleTool.pwd3 = nil;
        [self didGetDeviceSN:self.destPeripheral.serialNumber];
    }
    
    if (!self.bleTool.connectedPeripheral && self.step == 1)
    {
        [MBProgressHUD showMessage:Localized(@"connectingLock") toView:self.view];
        NSLog(@"--{Kaadas}--beginConnectPeripheral--BleBindVC11");
        [self.bleTool beginConnectPeripheral:self.destPeripheral];
        NSLog(@"----self.destPeripheral---%@",self.destPeripheral.functionSet);
        self.overTimer = [NSTimer scheduledTimerWithTimeInterval:80.0 target:self selector:@selector(animationTimerActionOverTimer:) userInfo:nil repeats:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.bleTool.isBinding = NO;
    [self.bleTool endConnectPeripheral:self.destPeripheral];
    [self.overTimer invalidate];
    self.overTimer = nil;
}

- (void)dealloc
{
    if (self.bleTool.connectedPeripheral)
    {
        [self.bleTool endConnectPeripheral:self.bleTool.connectedPeripheral];
    }
    if (self.bindedDevice)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLockHasBeenAddedNotification object:nil userInfo:@{@"device" : self.bindedDevice}];
    }
}

///设置第二步提示界面。
- (void)setupStep2UI
{
    self.stepBtn.hidden = NO;
    [self setStepLabelAttributeTextAtStep:2];
    self.tipsIV.image = [UIImage imageNamed:@"添加网关智能锁2"];
    CGFloat top = (kScreenHeight - kStatusBarHeight - kNavBarHeight - self.tipsIV.image.size.height) * 6.0 / 13;
    if (kScreenHeight < 667)
    {
        CGRect bounds = [self.stepLabel.attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (bounds.size.height + 20 + 20 > top) top = bounds.size.height + 20 + 20;
    }
    [self.tipsIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.size.mas_equalTo(self.tipsIV.image.size);
    }];
    UIView *view = [UIView new];
    view.tag = 2019;
    [self.view addSubview:view];
    UILabel *label = [self createLabelWithText:Localized(@"initialAdminPwd1-8") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    label.numberOfLines = 0;
    [view addSubview:label];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamationMark"]];
    [view addSubview:iv];
    if (iv.image.size.width + 7 + label.width > kScreenWidth - 40)
    {
        CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.width / 2, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil];
        label.bounds = (CGRect){0, 0, ceil(bounds.size.width), ceil(bounds.size.height)};
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.center.equalTo(label);
            make.height.equalTo(@(label.height));
        }];
    }
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsIV.mas_bottom).offset(kScreenHeight<667 ? 20 : 45);
        make.centerX.equalTo(self.view).offset(iv.image.size.width / 2 + 3.5);
        make.size.mas_equalTo(label.size);
    }];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(label);
        make.right.equalTo(label.mas_left).offset(-7);
        make.size.mas_equalTo(iv.image.size);
    }];
}

///移除第二步提示界面的管理密码。
- (void)removeStep2UI
{
    UIView *view = [self.view viewWithTag:2019];
    [view removeFromSuperview];
}

///设置第三步提示界面。
- (void)setupStep3UI
{
    [self removeStep2UI];
    self.stepBtn.hidden = YES;
    [self setStepLabelAttributeTextAtStep:3];
    if (kScreenHeight < 667)
    {
        CGFloat top = (kScreenHeight - kStatusBarHeight - kNavBarHeight - self.tipsIV.image.size.height) * 6.0 / 13;
        [self.tipsIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(top);
            make.size.mas_equalTo(self.tipsIV.image.size);
        }];
    }
}

///设置绑定成功的界面。
- (void)setupBindSuccessUI
{
    [self.stepLabel removeFromSuperview];
    [self removeStep2UI];
    self.view.backgroundColor = KDSRGBColor(248, 248, 248);
    self.stepBtn.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    [self.stepBtn setTitle:Localized(@"save") forState:UIControlStateNormal];
    self.tipsIV.image = [UIImage imageNamed:@"deviceBindDone"];
    [self.tipsIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(34);
        make.size.mas_equalTo(self.tipsIV.image.size);
    }];
    UILabel *label = [self createLabelWithText:Localized(@"nameBindedLock") color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:15]];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsIV.mas_bottom).offset(26);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(37);
        make.left.right.equalTo(label);
        make.height.equalTo(@50);
    }];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"editName"]];
    [cornerView addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0);
        make.left.equalTo(cornerView).offset(15);
        make.size.mas_equalTo(iv.image.size);
    }];
    [cornerView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.equalTo(iv.mas_right).offset(10);
        make.right.equalTo(cornerView).offset(-15);
    }];
    
    NSArray *names = @[Localized(@"father"), Localized(@"mother"), Localized(@"oldBrother"), Localized(@"youngBrother"), Localized(@"oldSister"), Localized(@"other")];
    NSMutableArray<NSNumber *> *lengths = [NSMutableArray arrayWithCapacity:6];//文字宽度
    CGFloat totalLength = 0;
    CGFloat maxWidth = 0;//最大文字宽度。
    NSMutableArray<UIButton *> *btns = [NSMutableArray arrayWithCapacity:6];
    UIFont *font = [UIFont systemFontOfSize:12];
    for (int i = 0; i < 6; ++i)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 15;
        btn.backgroundColor = i==0 ? KDSRGBColor(0x1f, 0x96, 0xf7) : UIColor.whiteColor;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        btn.titleLabel.font = font;
        [btn addTarget:self action:@selector(selectLockNickname:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [names[i] sizeWithAttributes:@{NSFontAttributeName : font}].width;
        totalLength  += width;
        maxWidth = MAX(maxWidth, width);
        [lengths addObject:@(width)];
        [self.view addSubview:btn];
        [btns addObject:btn];
    }
    btns.firstObject.selected = YES;
    self.buttons = btns.copy;
    CGFloat topOffset = 16;
    //正常的按钮高30，间距最小5。
    if (totalLength + 26*btns.count + 30 + btns.count*5-5 < kScreenWidth)//一行
    {
        CGFloat space = (kScreenWidth - 30 - totalLength - 26*btns.count) / 5;
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView.mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@(lengths[0].intValue + 26));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[0].mas_right).offset(space);
            make.width.equalTo(@(lengths[1].intValue + 26));
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[1].mas_right).offset(space);
            make.width.equalTo(@(lengths[2].intValue + 26));
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[2].mas_right).offset(space);
            make.width.equalTo(@(lengths[3].intValue + 26));
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.left.equalTo(btns[3].mas_right).offset(space);
            make.width.equalTo(@(lengths[4].intValue + 26));
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(btns[0]);
            make.right.equalTo(self.view).offset(-15);
            make.width.equalTo(@(lengths[5].intValue + 26));
        }];
    }
    else if ((maxWidth + 26) * 3 + 30 + 10 < kScreenWidth)//2行，宽按最大文字宽度+26
    {
        CGFloat space = (kScreenWidth - (maxWidth + 26) * 3 - 30) / 2;
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView.mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@(maxWidth + 26));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.left.equalTo(btns[0].mas_right).offset(space);
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.left.equalTo(btns[1].mas_right).offset(space);
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[0].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[3]);
            make.left.equalTo(btns[3].mas_right).offset(space);
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[3]);
            make.left.equalTo(btns[1].mas_right).offset(space);
        }];
    }
    else//3行
    {
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cornerView.mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.equalTo(@((kScreenWidth - 60) / 2));
            make.height.equalTo(@30);
        }];
        [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[0]);
            make.right.equalTo(self.view).offset(-15);
        }];
        [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[0].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[3] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[2]);
            make.right.equalTo(self.view).offset(-15);
        }];
        [btns[4] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btns[2].mas_bottom).offset(topOffset);
            make.left.equalTo(self.view).offset(15);
            make.width.height.equalTo(btns[0]);
        }];
        [btns[5] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.width.height.equalTo(btns[4]);
            make.right.equalTo(self.view).offset(-15);
        }];
    }
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

///根据不同步骤，设置步骤标签不同内容。
- (void)setStepLabelAttributeTextAtStep:(int)step
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 7;
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *steps = @{@1:@"theFirstStep", @2:@"theSecondStep", @3:@"theThirdStep"};
    NSDictionary *stepsTip = @{@1:@"theFirstStepTips", @2:@"theSecondStepTips", @3:(self.hasBinded ? @"bindBleQuitNetTips" : @"bindBleEnterNetTips")};
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:Localized(steps[@(step)]) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:KDSRGBColor(0x33, 0x33, 0x33), NSParagraphStyleAttributeName:style}];
    [mAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:Localized(stepsTip[@(step)]) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:KDSRGBColor(0x66, 0x66, 0x66), NSParagraphStyleAttributeName:style}]];
    self.stepLabel.attributedText = mAttrStr;
    self.stepLabel.tag = step;
}

#pragma mark - 控件等事件。
///点击下一步或入网按钮，更改提示语和图片等界面。
- (void)stepBtnAction:(UIButton *)sender
{
    NSLog(@"--{Kaadas}--sender.tag==%ld",(long)sender.tag);

    sender.tag = (sender.tag + 1) % 5;
    switch (sender.tag)
    {
        case 0://添加且取名完成。
            sender.tag = 4;
            [self alterLockNickname];
            break;
            
        case 1://第一步搜索蓝牙页面
        {
            KDSBleSearchTableVC *vc = [[KDSBleSearchTableVC alloc] init];
            vc.model = self.model;
            sender.tag = 0;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 2:
        {
            [self setupStep2UI];
        }
            break;
            
        case 3:
        {
            [self setupStep3UI];
        }
            break;
            
        case 4://完成界面，删除之前的子视图，添加完成子视图。
        {
//            self.stepBtn.hidden = NO;
//            [self setupBindSuccessUI];
        }
            break;
            
        default:
            break;
    }
}

///显示设备蓝牙搜索帮助界面。
- (void)showDeviceBleSearchHelp:(UIButton *)sender
{
    KDSBLEBindHelpVC *vc = [[KDSBLEBindHelpVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

///锁昵称文本框文字改变后，限制长度不超过16个字符。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

///绑定成功后，点击6个昵称按钮，设置锁昵称。
- (void)selectLockNickname:(UIButton *)sender
{
    for (UIButton *btn in self.buttons)
    {
        if (btn == sender)
        {
            sender.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
            sender.selected = YES;
            self.textField.text = sender.currentTitle;
            continue;
        }
        btn.backgroundColor = UIColor.whiteColor;
        btn.selected = NO;
    }
}

#pragma mark - 网络请求相关方法。
/**
 *@abstract 根据蓝牙返回的SN获取pwd1。
 *@param sn 蓝牙返回的序列号。
 */
- (void)getPwd1WithSN:(NSString *)sn
{
    NSLog(@"--{Kaadas}--获取SN=%@",sn);
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"fetchingInfo,pleaseWait") toView:self.view];
    [[KDSHttpManager sharedManager] getPwd1WithSN:sn success:^(NSString * _Nonnull pwd1) {
        self.pwd1 = pwd1;
        NSLog(@"--{Kaadas}--http获取self.pwd1=%@",self.pwd1);
        self.bleTool.pwd1 = pwd1;
        [hud hideAnimated:NO];
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        if (error.code == 419) {
            //无法查找设备,蓝牙未经过产测
//            [MBProgressHUD showError:Localized(@"not passed production")];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:Localized(@"not passed production,please call") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"call") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                  NSString *number = @"400-800-5919";
                   NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",number]];
                   [[UIApplication sharedApplication] openURL:url];
               }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

               }];
            [ac addAction:cancelAction];
            [ac addAction:okAction];
            
            [self presentViewController:ac animated:YES completion:nil];
            
        }else{
            [MBProgressHUD showError:Localized(@"fetchingInfoFailed")];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        NSLog(@"--{Kaadas}--failure获取门锁信息失败");
        [MBProgressHUD showError:error.localizedDescription];
    }];
}

///绑定设备。
- (void)bindDevice
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSString *peripheralName = self.destPeripheral.advDataLocalName;
    NSMutableString *ms = [NSMutableString stringWithCapacity:self.bleTool.pwd2.length * 2];
    for (int i = 0; i < self.bleTool.pwd2.length; ++i)
    {
        [ms appendFormat:@"%02x", ((const unsigned char*)self.bleTool.pwd2.bytes)[i]];
    }
    NSString *pwd2 = ms.copy;
//    NSLog(@"--{Kaadas}--软件版本号=%@",self.bleTool.connectedPeripheral.softwareVer);
    MyDevice *dev = [MyDevice new];
    dev.password1 = self.pwd1 ?: self.bleTool.pwd1;
    dev.password2 = pwd2;
    dev.lockName = dev.lockName = peripheralName;
    dev.softwareVersion = self.bleTool.connectedPeripheral.softwareVer;
    dev.deviceSN = self.bleTool.connectedPeripheral.serialNumber;
    dev.peripheralId =  self.bleTool.connectedPeripheral.identifier.UUIDString;
    dev.deviceType = self.destPeripheral.name;
    dev.is_admin = @"1";
    dev.open_purview = @"3";
    dev.isAutoLock = @"0";
    dev.devmac = self.destPeripheral.mac;
    dev.model = self.lockModel;
    dev.functionSet = self.bleTool.connectedPeripheral.functionSet;
    dev.bleVersion = @(self.destPeripheral.bleVersion).stringValue;
    
    [[KDSHttpManager sharedManager] bindBleDevice:dev uid:uid success:^{
        [MBProgressHUD showSuccess:Localized(@"bindDeviceSuccess")];
        self.stepBtn.enabled = YES;
        self.stepBtn.hidden = NO;
        self.bindedDevice = dev;
        self.stepBtn.tag = 4;
        [self setupBindSuccessUI];
        [self.bleTool sendInOrOutNetSuccessFrame];
    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:Localized(@"bindDeviceFailed")];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:[Localized(@"bindDeviceFailed") stringByAppendingString:error.localizedDescription]];
    }];
}

//MARK:解绑(重置)已绑定的设备。
- (void)unbindDevice
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSString *peripheralName = self.destPeripheral.advDataLocalName;
    [[KDSHttpManager sharedManager] unbindBleDeviceWithBleName:peripheralName uid:uid success:^{
        //解绑成功后，pwd1传给蓝牙工具，操作绑定时蓝牙工具收到绑定请求会自动去鉴权。
        self.hasBinded = NO;
        if (self.stepLabel.tag == 3)
        {
            [self setStepLabelAttributeTextAtStep:3];
        }
        self.bleTool.isBinding = YES;
        [self.bleTool sendInOrOutNetSuccessFrame];
        [MBProgressHUD showSuccess:Localized(@"resetBindedDeviceSuccess")];
        self.bleTool.pwd1 = self.pwd1 ?: self.bleTool.pwd1;
        NSLog(@"--{Kaadas}--解绑(重置)已绑定的设备self.bleTool.pwd1=%@",self.bleTool.pwd1);

    } error:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:[Localized(@"resetBindedDeviceFailed") stringByAppendingFormat:@":%ld", (long)error.code]];
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:[Localized(@"resetBindedDeviceFailed") stringByAppendingString:error.localizedDescription]];
    }];
}

- (void)alterLockNickname
{
    NSString *uid = [KDSUserManager sharedManager].user.uid;
    NSString *peripheralName = self.destPeripheral.advDataLocalName;
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"alteringLockNickname") toView:self.view];
    NSString *nickname = self.textField.text;
    if (!nickname.length)
    {
        nickname = self.buttons.firstObject.currentTitle;
    }
    [[KDSHttpManager sharedManager] alterBindedDeviceNickname:nickname withUid:uid bleName:peripheralName success:^{
        [hud hideAnimated:YES];
        self.bindedDevice.lockNickName = self.bindedDevice.lockNickName = nickname;
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        [self.navigationController popToRootViewControllerAnimated:NO];
        UITabBarController *vc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([vc isKindOfClass:UITabBarController.class] && vc.viewControllers.count)
        {
            vc.selectedIndex = 0;
        }
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingFormat:@"%ld", (long)error.localizedDescription]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
    }];
}

#pragma mark - KDSBluetoothToolDelegate
- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    if (!self.bleTool.connectedPeripheral)
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"connectFailed") message:Localized(@"clickOKReconnect") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MBProgressHUD showMessage:Localized(@"connectingLock") toView:self.view];
            NSLog(@"--{Kaadas}--beginConnectPeripheral--BleBindVC22");
            [self.bleTool beginConnectPeripheral:self.destPeripheral];
        }];
        [ac addAction:cancel];
        [ac addAction:ok];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)didConnectPeripheral:(CBPeripheral *)peripheral
{
    /**保存蓝牙uuid*/
    //[LoginTool saveBleDeviceUUIDWithPeripheral:peripheral];
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self centralManagerDidStopScan:central];
}

- (void)didDisConnectPeripheral:(CBPeripheral *)peripheral
{
    /*
     在绑定界面，当蓝牙断开自动连接蓝牙
     //    [MBProgressHUD showMessage:[Localized(@"bleNotConnect") stringByAppendingFormat:@", %@", Localized(@"connectingLock")] toView:self.view];
     //[self.bleTool beginConnectPeripheral:self.destPeripheral];
     */
    /*
     在绑定界面，当蓝牙断开，返回搜索页面
     */
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"tips") message:Localized(@"UnableToBind") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:KDSBLEBindHelpVC.class]) {
                    //帮助页面不上推
                    return;
                }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
    
}

- (void)didGetDeviceSN:(NSString *)deviceSN
{
    NSLog(@"--{Kaadas}--deviceSN==%@",deviceSN);
    if (!deviceSN.length)
    {
        [self.bleTool getDeviceInfoWithDevType:DeviceInfoSerialNum];
        return;
    }
    //根据SN去请求pwd1，赋值给bleTool的pwd1
    [self getPwd1WithSN:deviceSN];
}
- (void)noFunctionSet:(NSString *)FunctionSetKey{
    
    //到此处就要判断蓝牙的bleversion、功能集，当bleversion==3且有功能集的情况才允许绑定
    int a = self.destPeripheral.functionSet.intValue;
    u_int8_t ttt;
    NSData *data = [NSData dataWithBytes:&a length:sizeof(ttt)];
    NSString * funSetStr = [NSString stringWithFormat:@"0x%@",[KDSBleAssistant convertDataToHexStr:data]];
    if (self.destPeripheral.bleVersion == 3 &&( self.destPeripheral.functionSet == nil || [self.destPeripheral.functionSet isEqualToString:@"255"] || !KDSLockFunctionSet[funSetStr])) {
        [MBProgressHUD showError:[NSString stringWithFormat:Localized(@"no%@FunctionSet"),funSetStr]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristicOfLockModel:(NSString *)model
{
    self.lockModel = model;
//    if ([model containsString:@"X5"])
//    {
//        self.model = KDSDeviceModelX5;
//    }
//    else
//    {
//        self.model = KDSDeviceModelT5;
//    }
}

- (void)didReceiveInNetOrOutNetCommand:(BOOL)inNet
{
    if (inNet)//入网，如果已绑定还没有解绑，那么蓝牙工具的pwd2为空(退网时isBinding为NO，不记录pwd2)，是不可能鉴权成功去绑定的。
    {
        //如果已绑定就直接入网，提示先退网。此条件好像不必要，暂时留着。
        if (self.hasBinded)
        {
            [MBProgressHUD showError:Localized(@"thisDeviceHasBeenBindedTips")];
        }
        else
        {
            [self bindDevice];
        }
    }
    else
    {
        [self unbindDevice];
    }
}

-(void)animationTimerActionOverTimer:(NSTimer *)overTimer
{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
}

@end
