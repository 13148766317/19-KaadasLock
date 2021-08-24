//
//  KDSAddKeyVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/3/4.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAddKeyVC.h"
#import "Masonry.h"
#import "KDSHttpManager+Ble.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Extension.h"

@interface KDSAddKeyVC ()

///添加卡片、指纹时的编号。
@property (nonatomic, assign) int num;
//蓝牙未连接时用到的属性
///连接蓝牙时的动画视图。
@property (nonatomic, strong) UIImageView *animationIV;
///转圈动画定时器。
@property (nonatomic, strong) NSTimer *animationTimer;
///连接门锁蓝牙中状态提示标签。
@property (nonatomic, strong) UILabel *connectingLabel;
///连接(失败)按钮。
@property (nonatomic, strong) UIButton *connectBtn;
//正在添加、添加失败时时用到的属性。
///模型图片视图。
@property (nonatomic, strong) UIImageView *modelIV;
///步骤标签，仅失败时使用。
@property (nonatomic, strong) UILabel *stepLabel;
///步骤按钮。
@property (nonatomic, strong) UIButton *stepBtn;
///记录输入框设备名字的上一次名字
@property (nonatomic,copy)NSString  *lastDeviceInputeName;
//添加成功时使用到的属性。
///卡片/指纹图片。
@property (nonatomic, strong) UIImageView *figureIV;
///输入昵称的文本框。
@property (nonatomic, strong) UITextField *textField;
///6个预设昵称的按钮数组。
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
///保存按钮。
@property (nonatomic, strong) UIButton *saveBtn;
///添加指纹定时器。
@property (nonatomic, strong) NSTimer *addKeyTimer;

@end

@implementation KDSAddKeyVC

#pragma mark - getter setter
- (UIImageView *)animationIV
{
    if (!_animationIV)
    {
        _animationIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"connectingBLE"]];
        [self.view addSubview:_animationIV];
    }
    return _animationIV;
}

- (NSTimer *)animationTimer
{
    if (!_animationTimer)
    {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30 target:self selector:@selector(animationTimerAction:) userInfo:nil repeats:YES];
    }
    return _animationTimer;
}

- (UILabel *)connectingLabel
{
    if (!_connectingLabel)
    {
        _connectingLabel = [self createLabelWithText:Localized(@"connectingLock") color:KDSRGBColor(0x14, 0x14, 0x14) font:[UIFont systemFontOfSize:18]];
        _connectingLabel.textAlignment = NSTextAlignmentCenter;
        _connectingLabel.numberOfLines = 0;
        [self.view addSubview:_connectingLabel];
    }
    return _connectingLabel;
}

- (UIButton *)connectBtn
{
    if (!_connectBtn)
    {
        _connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _connectBtn.layer.cornerRadius = 22;
        _connectBtn.backgroundColor = KDSRGBColor(0xff, 0x3b, 0x30);
        [_connectBtn setTitle:Localized(@"connectBLEFailed") forState:UIControlStateNormal];
        _connectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_connectBtn addTarget:self action:@selector(clickConnectBtnReconnect:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_connectBtn];
        [_connectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(kScreenHeight<667 ? -20 : -48);
            make.width.equalTo(@200);
            make.height.equalTo(@44);
        }];
    }
    return _connectBtn;
}

- (UIImageView *)modelIV
{
    if (!_modelIV)
    {
        _modelIV = [[UIImageView alloc] init];
        _modelIV.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_modelIV];
    }
    return _modelIV;
}

#pragma mark - 初始化、UI相关方法。
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.type = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationTitleLabel.text = Localized(self.type==0 ? @"addCard" : @"addFingerprint");
    self.view.backgroundColor = UIColor.whiteColor;
    if (!self.lock.bleTool.connectedPeripheral)
    {
        [self setupConnectingUI];
    }
    else
    {
        [self setupSettingKeyUI];
    }
    __weak typeof(self) weakSelf = self;
    //----------如果断电之后需要继续添加指纹、卡片就保留次代码，反之注释-------------------------
    self.authenticateSuccess = ^{///蓝牙断电重新连接后，如果还在次页面会继续执行上次命令
        if (![weakSelf.view viewWithTag:2019]) {
            [weakSelf setupSettingKeyUI];
            weakSelf.addKeyTimer = [NSTimer scheduledTimerWithTimeInterval:80.0 target:weakSelf selector:@selector(animationTimerActionStopAddKeyIfFail:) userInfo:nil repeats:NO];
        }
    };
    //-----------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lockDidReportOperationResult:) name:KDSLockDidReportNotification object:nil];
    self.addKeyTimer = [NSTimer scheduledTimerWithTimeInterval:80.0 target:self selector:@selector(animationTimerActionStopAddKeyIfFail:) userInfo:nil repeats:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.lock.bleTool.connectedPeripheral && _animationIV)
    {
        //[self.animationTimer fire];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_animationTimer.isValid)
    {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
    if (_addKeyTimer.isValid) {
        [_addKeyTimer invalidate];
        _addKeyTimer = nil;
    }
}

///设置未连接蓝牙时的界面。
- (void)setupConnectingUI
{
    [self.animationIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(126);
        make.size.mas_equalTo(self.animationIV.image.size);
    }];
    [self.connectingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.animationIV.mas_bottom).offset(25);
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 11;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"connectingLock") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:KDSRGBColor(0x99, 0x99, 0x99), NSParagraphStyleAttributeName:style}];
    [mAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:Localized(@"openBleAndStandByDoorLock") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11], NSForegroundColorAttributeName:KDSRGBColor(0x99, 0x99, 0x99), NSParagraphStyleAttributeName:style}]];
    self.connectingLabel.attributedText = mAttrStr;
}

///设置正在添加门卡或指纹时的界面。
- (void)setupSettingKeyUI
{
    //----------如果断电之后需要继续添加指纹、卡片的话，次代码保留,反之注释-----------
    if ([self.view viewWithTag:2020]) {
        [[self.view viewWithTag:2020] removeFromSuperview];
    }
    if (self.stepBtn) {
        [self.stepBtn removeFromSuperview];
    }
    //-------------------------------------------------------------------
    [_animationTimer invalidate];
    _animationTimer = nil;
    [_animationIV removeFromSuperview];
    _animationIV = nil;
    [_connectingLabel removeFromSuperview];
    _connectingLabel = nil;
    UILabel *label = [self createLabelWithText:Localized((self.type==0 ? @"addCardTips" : @"addFingerprintTips")) color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:17]];
    label.tag = 2019;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 42 : 72);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    NSString *name = self.type==0 ? @"collectCard" :@"collectFingerprint";
    UIImage *img = [UIImage imageNamed:name];
    self.modelIV.image = img;
    [self.modelIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset((kScreenHeight<667 ? (self.type==0 ? 82 : 41) : (self.type==0 ? 132 : 81)));
        make.centerX.equalTo(self.view).offset(self.type==0 ? (kScreenWidth - img.size.width) * 20 / 247 : 0);
        make.size.mas_equalTo(img.size);
    }];
    __weak typeof(self) weakSelf = self;
    KDSBleKeyType type = self.type==0 ? KDSBleKeyTypeRFID : KDSBleKeyTypeFingerprint;
    [self getAllKeys:type times:0 completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
        if (error == KDSBleErrorSuccess)
        {
            int num = (int)users.count;//序号
            for (int i = 0; i < users.count; ++i)
            {
                if (users[i].userId != i)
                {
                    num = i;
                    break;
                }
            }
            weakSelf.num = num;
            [weakSelf setKey:type userId:num];
        }
        else
        {
            [weakSelf setupFailedUI];
            [MBProgressHUD showError:[@"error" stringByAppendingFormat:@": %ld", (long)error]];
        }
    }];
}

///设置添加成功时的界面。
- (void)setupSuccessUI
{
    if (self.addKeyTimer) {
        [self.addKeyTimer invalidate];
        self.addKeyTimer = nil;
    }
    [self.modelIV removeFromSuperview];
    self.modelIV = nil;
    if ([self.view viewWithTag:2019]) {
        [[self.view viewWithTag:2019] removeFromSuperview];
    }
    self.view.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    UIImage *img = [UIImage imageNamed:self.type==0 ? @"bigCard" : @"bigFingerprint"];
    self.figureIV = [[UIImageView alloc] initWithImage:img];
    self.figureIV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.figureIV];
    [self.figureIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(40);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@40);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.numberOfLines = 0;
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
    tipsLabel.font = [UIFont systemFontOfSize:15];
    tipsLabel.text = [NSString stringWithFormat:Localized(self.type==0 ? @"cardAddSuccessTips": @"fingerpringAddSuccessTips"), self.num];
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.figureIV.mas_bottom).offset(25);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(ceil([tipsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 40, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tipsLabel.font} context:nil].size.height));
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLabel.mas_bottom).offset(37);
        make.centerX.equalTo(self.view);
        make.left.equalTo(self.view).offset(15);
        make.height.equalTo(@50);
    }];
    UIImage *leftImg = [UIImage imageNamed:@"editName"];
    UIImageView *leftIV = [[UIImageView alloc] initWithImage:leftImg];
    [cornerView addSubview:leftIV];
    [leftIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cornerView).offset(15);
        make.centerY.equalTo(@0);
        make.size.mas_equalTo(leftImg.size);
    }];
    self.textField = [[UITextField alloc] init];
    self.textField.placeholder = Localized(@"inputOrSelectAName");
    self.textField.font = [UIFont systemFontOfSize:15];
    [self.textField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cornerView addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cornerView);
        make.left.equalTo(leftIV.mas_right).offset(10);
        make.right.equalTo(cornerView).offset(-10);
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
        btn.backgroundColor = UIColor.whiteColor;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        btn.titleLabel.font = font;
        [btn addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [names[i] sizeWithAttributes:@{NSFontAttributeName : font}].width;
        totalLength  += width;
        maxWidth = MAX(maxWidth, width);
        [lengths addObject:@(width)];
        [self.view addSubview:btn];
        [btns addObject:btn];
    }
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
    
    self.saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    self.saveBtn.layer.cornerRadius = 22;
    [self.saveBtn setTitle:Localized(@"save") forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.saveBtn addTarget:self action:@selector(saveBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-KDSSSALE_HEIGHT(50));
        make.size.mas_equalTo(CGSizeMake(200, 44));
    }];
}

///设置添加失败时的界面。
- (void)setupFailedUI
{
    if ([self.view viewWithTag:2019]) {
        [[self.view viewWithTag:2019] removeFromSuperview];
    }
    self.stepLabel = [UILabel new];
    self.stepLabel.numberOfLines = 0;
    self.stepLabel.tag = 2020;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 11;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"theFirstStep") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:KDSRGBColor(0x33, 0x33, 0x33), NSParagraphStyleAttributeName:style}];
    [mAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:Localized(@"bleAddKeyFailedTipsStep1") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:KDSRGBColor(0x66, 0x66, 0x66), NSParagraphStyleAttributeName:style}]];
    self.stepLabel.attributedText = mAttrStr;
    [self.view addSubview:self.stepLabel];
    CGFloat top = kScreenHeight<667 ? 25 : 44;
    CGFloat bottom = kScreenHeight<667 ? 30 : 48;
    CGFloat textHeight = ceil([mAttrStr boundingRectWithSize:CGSizeMake(kScreenWidth - 40, 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    self.modelIV.image = [UIImage imageNamed:@"DKSLockBlue"];
    CGSize size = self.modelIV.image.size;
    CGFloat rate = kScreenHeight<667 ? 1.4 : 1.75;
    while ((kScreenHeight - kStatusBarHeight - kNavBarHeight - top - textHeight - bottom - 44 - size.height * rate) / 2 < 25 && rate>=1)
    {
        rate -= 0.1;
    }
    size = (CGSize){size.width * rate, size.height * rate};
    [self.modelIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stepLabel.mas_bottom).offset((kScreenHeight - kStatusBarHeight - kNavBarHeight - top - textHeight - bottom - 44 - size.height) / 2);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(size);
    }];
    
    self.stepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stepBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    self.stepBtn.layer.cornerRadius = 22;
    [self.stepBtn setTitle:Localized(@"nextStep") forState:UIControlStateNormal];
    [self.stepBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.stepBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.stepBtn addTarget:self action:@selector(stepBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.stepBtn];
    [self.stepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-bottom);
        make.size.mas_equalTo(CGSizeMake(200, 44));
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

#pragma mark - 控件等事件方法。
///定时器执行改变转置矩阵做动画，蓝牙未连接时使用。
- (void)animationTimerAction:(NSTimer *)timer
{
    self.animationIV.transform = CGAffineTransformRotate(self.animationIV.transform, M_PI / 30);
}

///连接失败时，点击显示的失败按钮重新搜索连接。
- (void)clickConnectBtnReconnect:(UIButton *)sender
{
    sender.hidden = YES;
    _connectingLabel.text = Localized(@"connectingLock");
    [self.lock.bleTool beginScanForPeripherals];
}

///添加成功后输入名称的文本框文字发送改变，限制名称长度16.添加成功时使用。
- (void)textFieldTextDidChange:(UITextField *)sender
{
//    NSData *data = [KDSTool getTranscodingStringDataWithString:sender.text];
//    if ([data length] > 16) {
//        sender.text = self.lastDeviceInputeName;
//    }else{
//        self.lastDeviceInputeName = sender.text;
//    }
    [sender trimTextToLength:-1];

}

///选择名称时更改8个按钮的背景色并更改名称，添加成功时使用。
- (void)selectBtn:(UIButton *)sender
{
    for (UIButton *btn in self.buttons)
    {
        btn.backgroundColor = UIColor.whiteColor;
        btn.selected = NO;
    }
    sender.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    sender.selected = YES;
    self.textField.text = sender.currentTitle;
}

///点击保存按钮保存卡片、指纹昵称，添加成功时使用。
- (void)saveBtnAction:(UIButton *)sender
{
    NSString *name = self.textField.text;
    if (!name.length)
    {
        for (UIButton *btn in self.buttons)
        {
            if (btn.selected)
            {
                name = btn.currentTitle;
                break;
            }
        }
    }
    KDSPwdListModel *m = [KDSPwdListModel new];
    //同步的时候编号的不足两位前面补充0格式，所以为了保证密码编号不会出现0/01重复问题，数据格式保证一致
    m.num = [NSString stringWithFormat:@"%02d", self.num];//@(self.num).stringValue;
    m.nickName = name.length ? name : [NSString stringWithFormat:@"%02d", m.num.intValue];
    m.pwdType = self.type==0 ? KDSServerKeyTpyeCard : KDSServerKeyTpyeFingerprint;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [[KDSHttpManager sharedManager] addBlePwds:@[m] withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:^{
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        !self.keyAddSuccessBlock ?: self.keyAddSuccessBlock(m);
        //接口异步处理的，所以添加完成马上返回上个页面去查的话，会出现查不到的情况，所以延迟0.5秒
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:Localized(@"saveFailed")];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@， %@", Localized(@"saveFailed"), error.localizedDescription]];
    }];
}

///点击下一步按提示用户在锁上添加卡片、指纹，添加失败时使用。
- (void)stepBtnAction:(UIButton *)sender
{
    sender.tag += 1;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 11;
    style.alignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mAttrStr = [[NSMutableAttributedString alloc] initWithString:Localized((sender.tag==1 ? @"theSecondStep" : @"theThirdStep")) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:KDSRGBColor(0x33, 0x33, 0x33), NSParagraphStyleAttributeName:style}];
    [mAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:Localized((sender.tag==1 ? (self.type==0 ? @"bleAddCardFailedStep2" : @"bleAddFingerprintFailedStep2") : (self.type==0 ? @"bleAddCardFailedStep3" : @"bleAddFingerprintFailedStep3"))) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13], NSForegroundColorAttributeName:KDSRGBColor(0x66, 0x66, 0x66), NSParagraphStyleAttributeName:style}]];
    self.stepLabel.attributedText = mAttrStr;
    if (sender.tag == 1)
    {
        self.modelIV.image = [UIImage imageNamed:@"lockOperateKeyboard"];
    }
    else if (sender.tag == 2)
    {
        [sender setTitle:Localized(@"done") forState:UIControlStateNormal];
        [sender setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        sender.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
        self.modelIV.image = [UIImage imageNamed:self.type==0 ? @"collectCard" : @"collectFingerprint"];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 通知。
///锁上报操作结果，从数据中提取添加操作是否成功。
- (void)lockDidReportOperationResult:(NSNotification *)noti
{
    CBPeripheral *peripheral = noti.userInfo[@"peripheral"];
    NSData *data = noti.userInfo[@"data"];
    const Byte * bytes = data.bytes;

    if (peripheral == self.lock.bleTool.connectedPeripheral && data.length == 20 && bytes[4] == 2)
    {
        if ((bytes[5] == 3 && bytes[6] == 5 && self.type == 0) || (bytes[5] == 4 && bytes[6] == 7 && self.type == 1))
        {
            [self setupSuccessUI];
        }
    }
}

-(void)animationTimerActionStopAddKeyIfFail:(NSTimer *)ti{
    
    [self setupFailedUI];
}

#pragma mark - 蓝牙功能相关方法。
///获取已设置的所有卡片、指纹，调用时times传0，最多3次，3次都失败就算失败，completion是获取操作完毕后的回调，成功时users才有意义。
- (void)getAllKeys:(KDSBleKeyType)type times:(int)times completion:(void(^)(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users))completion
{
    KDSBluetoothTool *tool = self.lock.bleTool;
    __weak typeof(self) weakSelf = self;
    [tool getAllUsersWithKeyType:type completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
        if (error == KDSBleErrorSuccess)
        {
            !completion ?: completion(error, users);
        }
        else if (times < 2)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf getAllKeys:type times:times + 1 completion:completion];
            });
        }
        else
        {
            !completion ?: completion(error, users);
        }
    }];
}

///设置卡片、指纹，userId是卡片或指纹的编号。设置成功后，如果用户不点击保存直接退出控制器，不保存资料到本地和服务器。
- (void)setKey:(KDSBleKeyType)type userId:(int)userId
{
    KDSBluetoothTool *tool = self.lock.bleTool;
    __weak typeof(self) weakSelf = self;
    [tool manageKeyWithPwd:@"" userId:@(userId).stringValue action:KDSBleKeyManageActionSet keyType:type completion:^(KDSBleError error) {
        if (error != KDSBleErrorSuccess)
        {
            [weakSelf setupFailedUI];
        }
    }];
}

#pragma mark - KDSBluetoothToolDelegate
- (void)discoverManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:Localized(@"pleaseOpenBle") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [ac addAction:action];
        [self presentViewController:ac animated:YES completion:^{
            [self.animationTimer invalidate];
            self.animationTimer = nil;
        }];
    }
}

- (void)centralManagerDidStopScan:(CBCentralManager *)cm
{
    if (!self.lock.bleTool.connectedPeripheral)
    {
        self.connectBtn.hidden = NO;
        self.connectingLabel.text = Localized(@"connectBLEFailed");
    }
}

- (void)dealloc
{
    [self.addKeyTimer invalidate];
    self.addKeyTimer = nil;
    NSLog(@"执行了dealloc---palyback");
}
@end
