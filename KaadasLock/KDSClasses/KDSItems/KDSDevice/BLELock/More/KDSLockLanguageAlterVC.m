//
//  KDSLockLanguageAlterVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/16.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSLockLanguageAlterVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSAlertController.h"

@interface KDSLockLanguageAlterVC ()

///中文选择按钮。
@property (nonatomic, strong) UIButton *zhBtn;
///英文选择按钮。
@property (nonatomic, strong) UIButton *enBtn;

@end

@implementation KDSLockLanguageAlterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"lockLanguage");
    [self setUI];
}

- (void)setUI
{
    UIView *cornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 151)];
    cornerView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:cornerView];
    
    UIFont *font = [UIFont systemFontOfSize:15];
    UIColor *color = KDSRGBColor(0x33, 0x33, 0x33);
    UIImage *normalImg = [UIImage imageNamed:@"unselected22x22"];
    UIImage *selectedImg = [UIImage imageNamed:@"selected22x22"];
    
    UIImageView *zhIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"语言设置-中文"]];
    zhIV.frame = CGRectMake(24, 27.5, 20, 20);
    [cornerView addSubview:zhIV];
    
    NSString *zh = Localized(@"languageChinese");
    UILabel *zhLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 0, 200, 75)];
    zhLabel.text = zh;
    zhLabel.textColor = color;
    zhLabel.font = font;
    [cornerView addSubview:zhLabel];
    
    self.zhBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.zhBtn setImage:normalImg forState:UIControlStateNormal];
    [self.zhBtn setImage:selectedImg forState:UIControlStateSelected];
    self.zhBtn.frame = CGRectMake(cornerView.bounds.size.width - 17 - 22, 26.5, 22, 22);
    
    [self.zhBtn addTarget:self action:@selector(selectLockLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:self.zhBtn];
    
    UIView *separactor = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(zhLabel.frame), cornerView.bounds.size.width - 20, 1)];
    separactor.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
    [cornerView addSubview:separactor];
    
    UIImageView *enIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"语言设置-英语"]];
    enIV.frame = CGRectMake(24, 27.5 + 76, 20, 20);
    [cornerView addSubview:enIV];
    
    NSString *en = Localized(@"languageEnglish");
    UILabel *enLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, CGRectGetMaxY(separactor.frame), 200, 75)];
    enLabel.text = en;
    enLabel.textColor = color;
    enLabel.font = font;
    [cornerView addSubview:enLabel];
    
    self.enBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.enBtn setImage:normalImg forState:UIControlStateNormal];
    [self.enBtn setImage:selectedImg forState:UIControlStateSelected];
    self.enBtn.frame = CGRectMake(cornerView.bounds.size.width - 17 - 22, 102.5, 22, 22);
    
    [self.enBtn addTarget:self action:@selector(selectLockLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [cornerView addSubview:self.enBtn];
    
    //保存按钮
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.layer.cornerRadius = 22;
    doneBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    [doneBtn setTitle:Localized(@"save") forState:UIControlStateNormal];
    [doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake((kScreenWidth - 200) / 2, kScreenHeight - kStatusBarHeight - kNavBarHeight - 44 - 48, 200, 44);
    [doneBtn addTarget:self action:@selector(setLockLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    
    if (self.lock.gwDevice) {
        MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"Synchronizing Lock Language") toView:self.view];
        [[KDSMQTTManager sharedManager] dlGetLanguage:self.lock.gwDevice completion:^(NSError * _Nullable error, NSString * _Nullable language) {
            [hud hideAnimated:YES];
            if (language)
            {
                self.zhBtn.selected = [language isEqualToString:zh] || [language isEqualToString:@"zh"];
                self.enBtn.selected = [language isEqualToString:en] || [language isEqualToString:@"en"];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //回调或者说是通知主线程刷新，
                    [MBProgressHUD showError:Localized(@"getLockLanguageFailed")];
                });
            }
        }];
    }else if (self.lock.wifiDevice){
        self.zhBtn.selected = [self.language isEqualToString:zh] || [self.language isEqualToString:@"zh"];
        self.enBtn.selected = [self.language isEqualToString:en] || [self.language isEqualToString:@"en"];
        if (!self.language.length)
        {
            [MBProgressHUD showError:Localized(@"getLockLanguageFailed")];
        }
    }else{
        self.zhBtn.selected = [self.language isEqualToString:zh] || [self.language isEqualToString:@"zh"];
        self.enBtn.selected = [self.language isEqualToString:en] || [self.language isEqualToString:@"en"];
        if (!self.language.length)
        {
            [MBProgressHUD showError:Localized(@"getLockLanguageFailed")];
        }
    }
    
}
#pragma mark - 控件等事件方法。
///中文/英文按钮选择切换语言
- (void)selectLockLanguage:(UIButton *)sender
{
    self.zhBtn.selected = self.enBtn.selected = NO;
    sender.selected = YES;
}

///点击完成按钮设置锁语言。
- (void)setLockLanguage:(UIButton *)sender
{
    NSString *language = self.zhBtn.selected ? Localized(@"languageChinese") : Localized(@"languageEnglish");
    NSString *isoLan = self.zhBtn.selected ? @"zh" : @"en";
    if ([language isEqualToString:self.language] || [isoLan isEqualToString:self.language]){
        [MBProgressHUD showError:Localized(@"您未切换选中语言，请选择切换")];
        return;
    }
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"settingLockLanguage")];
    if (self.lock.gwDevice)
    {
        [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setLanguage:isoLan completion:^(NSError * _Nullable error, BOOL success) {
            [hud hideAnimated:YES];
            if (success)
            {
                [MBProgressHUD showSuccess:Localized(@"setLockLanguageSuccess")];
                //                !weakSelf.lockLanguageDidAlterBlock ?: weakSelf.lockLanguageDidAlterBlock(language);
                //                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [MBProgressHUD showError:Localized(@"setLockLanguageFailed")];
            }
        }];
        return;
    }if (self.lock.wifiDevice) {//wifi锁不可以设置
        ///wifi锁/ble+wifi
        KDSAlertController *alert = [KDSAlertController alertControllerWithTitle:@"App不可设置，请在锁端设置" message:nil];
        [self presentViewController:alert animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:^{
            }];
        });
        return;
    }
    [self.lock.bleTool setLockLanguage:isoLan completion:^(KDSBleError error) {
        [hud hideAnimated:YES];
        if (error == KDSBleErrorSuccess)
        {
            weakSelf.lock.bleTool.connectedPeripheral.language = self.zhBtn.selected ? @"zh" : @"en";
            [MBProgressHUD showSuccess:Localized(@"setLockLanguageSuccess")];
            !weakSelf.lockLanguageDidAlterBlock ?: weakSelf.lockLanguageDidAlterBlock(language);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [MBProgressHUD showError:[Localized(@"setLockLanguageFailed") stringByAppendingFormat:@": %ld", (long)error]];
        }
    }];
}


@end
