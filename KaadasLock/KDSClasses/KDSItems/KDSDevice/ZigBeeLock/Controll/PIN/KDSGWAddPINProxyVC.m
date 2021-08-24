//
//  KDSGWAddPINProxyVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWAddPINProxyVC.h"
#import "KDSTimelinessView.h"
#import "KDSDatePickerVC.h"
#import "KDSWeekPickerVC.h"
#import "KDSHttpManager+Ble.h"
#import "MBProgressHUD+MJ.h"
#import "KDSPINShareVC.h"
#import "UIView+Extension.h"
#import "KDSDBManager+GW.h"
#import "KDSHttpManager+ZigBeeLock.h"
#import "KDSZigBeeLockInfoModel.h"

@interface KDSGWAddPINProxyVC () <UITextFieldDelegate>

///密码文本框。
@property (nonatomic, strong) UITextField *pwdTextField;
///密码名称文本框。
@property (nonatomic, strong) UITextField *pwdNameTextField;
///6个预设昵称的按钮数组。
@property (nonatomic, strong) NSArray<UIButton *> *nicknameButtons;
///时效密码时的3个策略按钮。
@property (nonatomic, strong) NSArray<UIButton *> *strategyButtons;
///时效密码的开始时间视图，周期密码的起止时间视图。
@property (nonatomic, strong) KDSTimelinessView *beginTimelinessView;
///时间密码的结束时间视图，周期密码的规则视图。
@property (nonatomic, strong) KDSTimelinessView *endTimelinessView;
///周期密码时显示周期规则的标签。
@property (nonatomic, strong) UILabel *ruleLabel;
///周期密码时，位域标记选中日期的变量，从低到高分别表示周日 ~ 周六，最高位保留0，1选中。
@property (nonatomic, assign) char mask;
///date formatter, format HH:mm
@property (nonatomic, strong) NSDateFormatter *fmt;
///设置密码时返回的凭证。
@property (nonatomic, strong) KDSMQTTTaskReceipt *receipt;

@end

@implementation KDSGWAddPINProxyVC

#pragma mark - getter setter
- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.dateFormat = @"HH:mm";
    }
    return _fmt;
}

- (void)setMask:(char)mask
{
    _mask = mask;
    NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
    NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    if (mask == 0x7f)
    {
        self.ruleLabel.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), Localized(@"everyday"), begin, end];
    }
    else
    {
        NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
        NSMutableString *ms = [NSMutableString string];
        NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
        for (int i = 0; i < 7; ++i)
        {
            !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
        }
        [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
        self.ruleLabel.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), ms, begin, end];
    }
}

#pragma mark - 生命周期、UI相关方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addPIN");
    self.mask = 0x7f;
    [self setupUI];
}

- (void)setupUI
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.type==2 ? 526 : 563)];;
    self.tableView.tableHeaderView = headerView;
    CGRect frame = headerView.frame;
    
    UIView *pwdCornerView = [self createPwdCornerView];
    [headerView addSubview:pwdCornerView];
    [pwdCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(26);
        make.left.equalTo(headerView).offset(15);
        make.right.equalTo(headerView).offset(-15);
        make.height.equalTo(@50);
    }];
    
    UILabel *savePwdTipsLabel = [self createLabelWithText:Localized(@"saveBlePwdTips") color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
    savePwdTipsLabel.numberOfLines = 0;
    [headerView addSubview:savePwdTipsLabel];
    [savePwdTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pwdCornerView.mas_bottom).offset(15);
        make.left.right.equalTo(pwdCornerView);
        make.height.equalTo(@(ceil([savePwdTipsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : savePwdTipsLabel.font} context:nil].size.height)));
    }];
    frame = headerView.frame;
    frame.size.height += (savePwdTipsLabel.bounds.size.height - 12);
    
    //密码昵称视图
    /*
     UIView *pwdNameCornerView = [self createPwdNameCornerView];
     //    [headerView addSubview:pwdNameCornerView];
     [pwdNameCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.equalTo(savePwdTipsLabel.mas_bottom).offset(25);
     make.left.equalTo(headerView).offset(15);
     make.right.equalTo(headerView).offset(-15);
     make.height.equalTo(@50);
     }];
     
     //6个默认昵称
     self.nicknameButtons = [self createNicknameButtonsWithSuperview:headerView constraintView:pwdNameCornerView];
     */
    
    UIButton *occurBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    occurBtn.layer.cornerRadius = 22;
    occurBtn.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    [occurBtn setTitle:Localized(@"ensureOccur") forState:UIControlStateNormal];
    [occurBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [occurBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    occurBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [occurBtn addTarget:self action:@selector(clickOccurBtnOccurPwd:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:occurBtn];
    [occurBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.bottom.equalTo(headerView).offset(-40);
    }];
    
    if (self.type == 0)
    {
        self.strategyButtons = [self createStrategyButtonsWithSuperview:headerView constraintView: savePwdTipsLabel /*self.nicknameButtons.lastObject*/];
        self.strategyButtons.lastObject.selected = YES;
        self.beginTimelinessView = [KDSTimelinessView viewWithTitle:Localized(@"effectiveDate") date:NSDate.date];
        [headerView addSubview:self.beginTimelinessView];
        [self.beginTimelinessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.strategyButtons.firstObject.mas_bottom).offset(18);
            make.centerX.equalTo(@0);
            make.size.mas_equalTo(self.beginTimelinessView.bounds.size);
        }];
        self.endTimelinessView = [KDSTimelinessView viewWithTitle:Localized(@"terminationDate") date:NSDate.date];
        [headerView addSubview:self.endTimelinessView];
        [self.endTimelinessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.beginTimelinessView.mas_bottom).offset(10);
            make.centerX.equalTo(@0);
            make.size.mas_equalTo(self.endTimelinessView.bounds.size);
        }];
        __weak typeof(self) weakSelf = self;
        self.beginTimelinessView.tapDateViewBlock = ^(UITapGestureRecognizer * _Nonnull sender) {
            [weakSelf tapBeginTimelinessViewAction:sender];
        };
        self.endTimelinessView.tapDateViewBlock = ^(UITapGestureRecognizer * _Nonnull sender) {
            [weakSelf tapEndTimelinessViewAction:sender];
        };
    }
    else if (self.type == 1)
    {
        self.beginTimelinessView = [KDSTimelinessView viewWithTitle:Localized(@"timeSetting") date:NSDate.date];
        self.beginTimelinessView.content = @"00:00  ~  23:59";
        [headerView addSubview:self.beginTimelinessView];
        [self.beginTimelinessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(/*self.nicknameButtons.lastObject*/savePwdTipsLabel.mas_bottom).offset(30);
            make.centerX.equalTo(@0);
            make.size.mas_equalTo(self.beginTimelinessView.bounds.size);
        }];
        self.endTimelinessView = [KDSTimelinessView viewWithTitle:Localized(@"ruleDuplicate") date:NSDate.date];
        self.endTimelinessView.content = Localized(@"everyday");
        [headerView addSubview:self.endTimelinessView];
        [self.endTimelinessView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.beginTimelinessView.mas_bottom).offset(10);
            make.centerX.equalTo(@0);
            make.size.mas_equalTo(self.endTimelinessView.bounds.size);
        }];
        __weak typeof(self) weakSelf = self;
        self.beginTimelinessView.tapDateViewBlock = ^(UITapGestureRecognizer * _Nonnull sender) {
            [weakSelf tapBeginTimelinessViewAction:sender];
        };
        self.endTimelinessView.tapDateViewBlock = ^(UITapGestureRecognizer * _Nonnull sender) {
            [weakSelf tapEndTimelinessViewAction:sender];
        };
        self.ruleLabel = [UILabel new];
        self.ruleLabel.numberOfLines = 0;
        self.ruleLabel.text = [NSString stringWithFormat:Localized(@"pwdRuleTips"), Localized(@"everyday"), @"00:00", @"23:59"];
        self.ruleLabel.textAlignment = NSTextAlignmentCenter;
        self.ruleLabel.font = [UIFont systemFontOfSize:12];
        self.ruleLabel.textColor = KDSRGBColor(0x99, 0x99, 0x99);
        [headerView addSubview:self.ruleLabel];
        [self.ruleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.endTimelinessView.mas_bottom).offset(15);
            make.left.right.equalTo(self.endTimelinessView);
        }];
    }
    else
    {
        UILabel *tempPwdTipsLabel = [self createLabelWithText:self.type==2 ? Localized(@"tempPwdCanOnlyUseOnce") : nil color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
        tempPwdTipsLabel.textAlignment = NSTextAlignmentCenter;
        tempPwdTipsLabel.numberOfLines = 0;
        [headerView addSubview:tempPwdTipsLabel];
        [tempPwdTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(/*self.nicknameButtons.firstObject*/savePwdTipsLabel.mas_bottom).offset(96);
            make.left.right.equalTo(pwdCornerView);
            make.height.equalTo(@(ceil([tempPwdTipsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tempPwdTipsLabel.font} context:nil].size.height)));
        }];
    }
}

///创建密码圆角视图。
- (UIView *)createPwdCornerView
{
    UIView *pwdCornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, 50)];
    pwdCornerView.layer.masksToBounds = YES;
    pwdCornerView.layer.cornerRadius = 4;
    pwdCornerView.backgroundColor = UIColor.whiteColor;
    
    UIImageView *pwdLockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"密码Hight"]];
    [pwdCornerView addSubview:pwdLockIV];
    [pwdLockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pwdCornerView).offset(15 * kScreenWidth / 375);
        make.centerY.equalTo(@0);
        make.size.mas_equalTo(pwdLockIV.image.size);
    }];
    
    UIButton *randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    randomBtn.backgroundColor = KDSRGBColor(0xcd, 0xe1, 0xf7);
    [randomBtn setTitle:Localized(@"randomOccur") forState:UIControlStateNormal];
    [randomBtn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
    randomBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [randomBtn addTarget:self action:@selector(clickRandomOccurBtnOccurRandomPassword:) forControlEvents:UIControlEventTouchUpInside];
    [pwdCornerView addSubview:randomBtn];
    [randomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(pwdCornerView);
        make.width.equalTo(@([randomBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : randomBtn.titleLabel.font}].width + 10));
    }];
    
    self.pwdTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.pwdTextField.placeholder = Localized(@"input6~12NumericPwd");
    self.pwdTextField.font = [UIFont systemFontOfSize:kScreenWidth<375 ? 13 : 15];
    self.pwdTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.pwdTextField.delegate = self;
    [self.pwdTextField addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [pwdCornerView addSubview:self.pwdTextField];
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(pwdCornerView);
        make.left.equalTo(pwdLockIV.mas_right).offset(10 * kScreenWidth / 375);
        make.right.equalTo(randomBtn.mas_left);
    }];
    
    return pwdCornerView;
}

///创建密码名称圆角视图。
- (UIView *)createPwdNameCornerView
{
    UIView *pwdNameCornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth - 30, 50)];
    pwdNameCornerView.layer.masksToBounds = YES;
    pwdNameCornerView.layer.cornerRadius = 4;
    pwdNameCornerView.backgroundColor = UIColor.whiteColor;
    
    UIImageView *personIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"editName"]];
    [pwdNameCornerView addSubview:personIV];
    [personIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pwdNameCornerView).offset(15 * kScreenWidth / 375);
        make.centerY.equalTo(@0);
        make.size.mas_equalTo(personIV.image.size);
    }];
    
    self.pwdNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.pwdNameTextField.placeholder = Localized(@"inputPwdName");
    self.pwdNameTextField.font = [UIFont systemFontOfSize:kScreenWidth<375 ? 13 : 15];
    [self.pwdNameTextField addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [pwdNameCornerView addSubview:self.pwdNameTextField];
    [self.pwdNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(pwdNameCornerView);
        make.left.equalTo(personIV.mas_right).offset(10 * kScreenWidth / 375);
        make.right.equalTo(pwdNameCornerView).offset(-15);
    }];
    
    return pwdNameCornerView;
}

///创建预设的6个昵称按钮，根据密码名称圆角视图添加约束。最后返回按钮数组。
- (NSArray<UIButton *> *)createNicknameButtonsWithSuperview:(UIView *)superview constraintView:(UIView *)constraintView
{
    NSArray *names = @[Localized(@"father"), Localized(@"mother"), Localized(@"oldBrother"), Localized(@"youngBrother"), Localized(@"oldSister"), Localized(@"other")];
    NSMutableArray<NSNumber *> *lengths = [NSMutableArray arrayWithCapacity:names.count];//文字宽度
    CGFloat totalLength = 0;
    CGFloat maxWidth = 0;//最大文字宽度。
    NSMutableArray<UIButton *> *btns = [NSMutableArray arrayWithCapacity:names.count];
    UIFont *font = [UIFont systemFontOfSize:12];
    for (int i = 0; i < names.count; ++i)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 15;
        btn.backgroundColor = UIColor.whiteColor;
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
        btn.titleLabel.font = font;
        [btn addTarget:self action:@selector(selectNickname:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = [names[i] sizeWithAttributes:@{NSFontAttributeName : font}].width;
        totalLength  += width;
        maxWidth = MAX(maxWidth, width);
        [lengths addObject:@(width)];
        [superview addSubview:btn];
        [btns addObject:btn];
    }
    btns.firstObject.selected = YES;
    btns.firstObject.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    self.nicknameButtons = btns.copy;
    CGFloat topOffset = 15;
    //正常的按钮高30，间距最小5。
    if (totalLength + 26*btns.count + 30 + btns.count*5-5 < kScreenWidth)//一行
    {
        CGFloat space = (kScreenWidth - 30 - totalLength - 26*btns.count) / 5;
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(constraintView.mas_bottom).offset(topOffset);
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
            make.top.equalTo(constraintView.mas_bottom).offset(topOffset);
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
        CGRect frame = superview.frame;
        frame.size.height += (30 + topOffset);
        superview.frame = frame;
    }
    else//3行
    {
        [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(constraintView.mas_bottom).offset(topOffset);
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
        CGRect frame = superview.frame;
        frame.size.height += (30 + topOffset) * 2;
        superview.frame = frame;
    }
    
    return btns.copy;
}

///创建3个策略按钮，根据预设昵称按钮添加约束。最后返回按钮数组。
- (NSArray<UIButton *> *)createStrategyButtonsWithSuperview:(UIView *)superview constraintView:(UIView *)constraintView
{
    NSArray *names = @[Localized(@"forever"), Localized(@"24Hours"), Localized(@"custom")];
    NSMutableArray<NSNumber *> *lengths = [NSMutableArray arrayWithCapacity:names.count];//文字宽度
    CGFloat totalLength = 0;
    NSMutableArray<UIButton *> *btns = [NSMutableArray arrayWithCapacity:names.count];
    UIFont *font = [UIFont systemFontOfSize:15];
    UIImage *normalImg = [UIImage imageNamed:@"未选择"];
    UIImage *selectedImg = [UIImage imageNamed:@"选择"];
    for (int i = 0; i < names.count; ++i)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:normalImg forState:UIControlStateNormal];
        [btn setImage:selectedImg forState:UIControlStateSelected];
        [btn setTitle:names[i] forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x33, 0x33, 0x33) forState:UIControlStateNormal];
        btn.titleLabel.font = font;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [btn addTarget:self action:@selector(selectStrategy:) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = ceil([names[i] sizeWithAttributes:@{NSFontAttributeName : font}].width);
        totalLength  += width;
        [lengths addObject:@(width)];
        [superview addSubview:btn];
        [btns addObject:btn];
    }
    CGFloat space = (kScreenWidth - totalLength - names.count * (10 + normalImg.size.width)) / 4;
    [btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(constraintView.mas_bottom).offset(29);
        make.left.equalTo(superview).offset(space);
        make.width.equalTo(@(lengths[0].intValue + 10 + normalImg.size.width));
    }];
    [btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(constraintView.mas_bottom).offset(29);
        make.left.equalTo(btns[0].mas_right).offset(space);
        make.width.equalTo(@(lengths[1].intValue + 10 + normalImg.size.width));
    }];
    [btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(constraintView.mas_bottom).offset(29);
        make.left.equalTo(btns[1].mas_right).offset(space);
        make.width.equalTo(@(lengths[2].intValue + 10 + normalImg.size.width));
    }];
    
    return btns.copy;
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
///点击随机生成按钮生成随机密码。
- (void)clickRandomOccurBtnOccurRandomPassword:(UIButton *)sender
{
    NSInteger count = arc4random() % 7 + 6;
    NSMutableString *ms = [NSMutableString stringWithCapacity:count];
    for (int i = 0; i < count; ++i)
    {
        [ms appendString:@(arc4random() % 10).stringValue];
    }
    self.pwdTextField.text = ms.copy;
}

///密码、密码名称文本框输入变化。
- (void)textFieldTextChanged:(UITextField *)sender
{
    if (sender == self.pwdNameTextField)
    {
        [sender trimTextToLength:-1];
    }
}

///选择名称时更改8个按钮的背景色等。
- (void)selectNickname:(UIButton *)sender
{
    for (UIButton *btn in self.nicknameButtons)
    {
        if (btn.selected && btn == sender)
        {
            self.pwdNameTextField.text = sender.currentTitle;
            return;
        }
        btn.backgroundColor = UIColor.whiteColor;
        btn.selected = NO;
    }
    sender.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    sender.selected = YES;
    self.pwdNameTextField.text = sender.currentTitle;
}

///选择策略时更改策略按钮的图片等。
- (void)selectStrategy:(UIButton *)sender
{
    //    for (UIButton *btn in self.strategyButtons)
    //    {
    //        if (btn.selected && btn == sender) return;
    //        btn.selected = NO;
    //    }
    //    sender.selected = YES;
    //    NSUInteger index = [self.strategyButtons indexOfObject:sender];
    //    BOOL enable = index != 0;
    //    self.beginTimelinessView.userInteractionEnabled = self.endTimelinessView.userInteractionEnabled = enable;
    //    if (index == 1)
    //    {
    //        self.endTimelinessView.date = [self.beginTimelinessView.date dateByAddingTimeInterval:24 * 3600];
    //    }
    
    
    UIButton *selectedBtn;
    for (UIButton *btn in self.strategyButtons)
    {
        if (btn.selected && btn == sender) return;
        if (btn.selected) selectedBtn = btn;
        btn.selected = NO;
    }
    sender.selected = YES;
    UIView *header = self.tableView.tableHeaderView;
    CGRect bounds = header.bounds;
    CGFloat height = self.beginTimelinessView.bounds.size.height + self.endTimelinessView.bounds.size.height;
    if (sender == self.strategyButtons.lastObject)
    {
        bounds.size.height += height;
        self.beginTimelinessView.hidden = self.endTimelinessView.hidden = NO;
    }
    else
    {
        bounds.size.height -= height;
        self.beginTimelinessView.hidden = self.endTimelinessView.hidden = YES;
    }
    if (selectedBtn==self.strategyButtons.lastObject || sender==self.strategyButtons.lastObject)
    {
        header.bounds = bounds;
        [self.tableView reloadData];
    }
    
}

///点击时效图执行的事件。
- (void)tapBeginTimelinessViewAction:(UITapGestureRecognizer *)sender
{
    if (self.type == 0)
    {
        KDSDatePickerVC *vc = [[KDSDatePickerVC alloc] init];
        vc.beginDate = self.beginTimelinessView.date;
        vc.didPickupDateBlock = ^(NSDate * _Nonnull beginDate, NSDate * _Nullable endDate) {
            self.beginTimelinessView.date = beginDate;
            if (self.strategyButtons[1].selected)
            {
                self.endTimelinessView.date = [beginDate dateByAddingTimeInterval:24 * 3600];
            }
            else if (self.strategyButtons.lastObject.selected)
            {
                if ([beginDate laterDate:self.endTimelinessView.date] == beginDate)
                {
                    self.endTimelinessView.date = beginDate;
                }
            }
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        KDSDatePickerVC *vc = [[KDSDatePickerVC alloc] init];
        vc.mode = 1;
        self.lock.bleTool.dateFormatter.dateFormat = @"HH:mm";
        NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
        vc.beginDate = [self.fmt dateFromString:[comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]];
        vc.endDate = [self.fmt dateFromString:[comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet]];
        vc.didPickupDateBlock = ^(NSDate * _Nonnull beginDate, NSDate * _Nullable endDate) {
            self.beginTimelinessView.content = [NSString stringWithFormat:@"%@  ~  %@", [self.fmt stringFromDate:beginDate], [self.fmt stringFromDate:endDate]];
            self.mask = self.mask;
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}

///点击时效图执行的事件。
- (void)tapEndTimelinessViewAction:(UITapGestureRecognizer *)sender
{
    if (self.type == 0)
    {
        KDSDatePickerVC *vc = [[KDSDatePickerVC alloc] init];
        vc.beginDate = self.endTimelinessView.date;
        vc.didPickupDateBlock = ^(NSDate * _Nonnull beginDate, NSDate * _Nullable endDate) {
            self.endTimelinessView.date = beginDate;
            if (self.strategyButtons[1].selected)
            {
                self.beginTimelinessView.date = [beginDate dateByAddingTimeInterval:-24 * 3600];
            }
            else if (self.strategyButtons.lastObject.selected)
            {
                if ([beginDate earlierDate:self.beginTimelinessView.date] == beginDate)
                {
                    self.beginTimelinessView.date = beginDate;
                }
            }
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        KDSWeekPickerVC *vc = [KDSWeekPickerVC new];
        vc.mask = self.mask;
        vc.didSelectWeekBlock = ^(char mask) {
            if (mask == 0x7f)
            {
                self.endTimelinessView.content = Localized(@"everyday");
            }
            else
            {
                NSArray *days = @[Localized(@"everySunday"), Localized(@"everyMonday"), Localized(@"everyTue"),  Localized(@"everyWed"), Localized(@"everyThu"), Localized(@"everyFri"), Localized(@"everySat")];
                NSMutableString *ms = [NSMutableString string];
                NSString *separator = [[KDSTool getLanguage] containsString:@"en"] ? @", " : @"、";
                for (int i = 0; i < 7; ++i)
                {
                    !((mask>>i) & 0x1) ?: [ms appendFormat:@"%@%@", days[i], separator];
                }
                [ms deleteCharactersInRange:NSMakeRange(ms.length - separator.length, separator.length)];
                self.endTimelinessView.content = ms;
            }
            self.mask = mask;
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

///点击生成密码按钮发送命令在锁中添加密码。
- (void)clickOccurBtnOccurPwd:(UIButton *)sender
{
    if (self.receipt) return;
    
    if ([KDSTool isSimplePasswordInLock:self.pwdTextField.text])
    {
        [MBProgressHUD showError:Localized(@"pleaseInputAtLeast6NumericsPwd")];
        return;
    }
    if (self.type == 1) {//周期密码
        NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
        NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];;
        NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        NSString * startTime = @([self.fmt dateFromString:begin].timeIntervalSince1970).stringValue;
        NSString * endTime = @([self.fmt dateFromString:end].timeIntervalSince1970).stringValue;
        if ((endTime.intValue - startTime.intValue) < 1) {
            [MBProgressHUD showError:Localized(@"lessThanEndTime")];
            return;
        }
    }
    if (self.strategyButtons.lastObject.selected)
    {//时间段
        if ((self.endTimelinessView.date.timeIntervalSince1970 - self.beginTimelinessView.date.timeIntervalSince1970) < 1) {
            [MBProgressHUD showError:Localized(@"lessThanEndTime")];
            return;
        }
    }
    //    if (!self.pwdNameTextField.text.length)
    //    {
    //        [MBProgressHUD showError:Localized(@"pleaseInputPwdName")];
    //        return;
    //    }
    [self getExistedPasswords];
}

#pragma mark - MQTT工具接口相关方法。
///获取已存在的密码。
- (void)getExistedPasswords
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"settingPwd") toView:self.view.superview.superview];
    //暂时只使用密码。
    [[KDSHttpManager sharedManager] getZigBeeInfoWithGwSN:self.lock.gwDevice.gwId uid:[KDSUserManager sharedManager].user.uid zigbeeSN:self.lock.gwDevice.deviceId success:^(id responseObject) {
        NSArray *  pwdListArr = [KDSPwdListModel mj_objectArrayWithKeyValuesArray:responseObject[@"pwdList"] ?: @[]];
        [hud hideAnimated:NO];
        NSArray * infoaaa = [responseObject objectForKey:@"endpointList"];
        KDSZigBeeLockInfoModel * lockInfo = [KDSZigBeeLockInfoModel mj_objectWithKeyValues: infoaaa[0][@"outputClusters"][@"doorLockInfo"][@"lockInfo"]];
        NSLog(@"%d",lockInfo.numberOfPINUsersSupported);
        NSMutableArray *container = [NSMutableArray arrayWithCapacity:lockInfo.numberOfPINUsersSupported];
        NSUInteger menaceNum = 0;//胁迫密码编号是9
        for (KDSPwdListModel * pwdModel in pwdListArr) {
            KDSBleUserType * user = [KDSBleUserType new];
            user.userId = pwdModel.userId;
            [container addObject:user];
        }
        for (KDSBleUserType *user in container)
        {
            if (user.userId == lockInfo.numberOfPINUsersSupported)
            {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
                return;
            }
            if (user.userId == 9) menaceNum = 9;
        }
        if (container.count == lockInfo.numberOfPINUsersSupported || (menaceNum != 9 && container.count == lockInfo.numberOfPINUsersSupported-1 && self.type != 3))
        {
            [hud hideAnimated:NO];
            [MBProgressHUD showError:Localized(@"passwordUpperLimit")];
            return;
        }
        int schedule = 0, temp = 0;
        NSString *warning = nil;
        for (KDSBleUserType *user in container)
        {
            if (lockInfo.numberOfPINUsersSupported == 20) {
                if (user.userId < 5 || (user.userId > 9 && user.userId <= 19))
                {
                    schedule++;
                }
                else if (user.userId >=5 && user.userId <= 8)
                {
                    temp++;
                }
                if (schedule == 15 && (self.type == 0 || self.type == 1))
                {
                    warning = Localized(@"timelinessAndPeriodPwdUpperLimit");
                }
                else if (temp == /*self.lock.bleTool.connectedPeripheral.maxUsers*/20 - 16 && self.type == 2)
                {
                    warning = Localized(@"temporaryPwdUpperLimit");
                }
                
            }else{
                if (user.userId < 5)
                {
                    schedule ++;
                }
                else if (user.userId != 9)
                {
                    temp++;
                }
                if (schedule == 5 && self.type == 0)
                {
                    warning = Localized(@"timelinessAndPeriodPwdUpperLimit");
                }
                else if (temp == lockInfo.numberOfPINUsersSupported - 6 && self.type == 2)
                {
                    warning = Localized(@"temporaryPwdUpperLimit");
                }
            }
        }
        if (warning)
        {
            [hud hideAnimated:NO];
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:warning message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];
        }
        else
        {
            int num = self.type==0 ? 0 : 5;
            NSMutableArray * userIds = [NSMutableArray array];
            for (KDSBleUserType *user in container)
            {
                if ([container containsObject: user]) {
                    [userIds addObject:@(user.userId)];
                }
            }
            if (self.type != 2) {
                num = [self setNumWitchUserId:userIds AndUserCound:lockInfo.numberOfPINUsersSupported];
            }else{
                num = [self setTempNumWitchUserId:userIds AndUserCound:lockInfo.numberOfPINUsersSupported];
            }
            num = self.type==3 ? 9 : num;//胁迫密码的编号固定为9
            //先设置密码->再设置计划->再设置用户类型
            self.receipt = [self setPwdInLock:self.pwdTextField.text PwdNumber:num];
            //                    if ((self.type==0 && !self.strategyButtons.firstObject.selected) || self.type==1)
            //                    {
            //                        //先设置计划->再设置密码->再设置用户类型
            //                        self.receipt = [self setPwdInLockNewScheme:self.pwdTextField.text PwdNumber:num];
            //                    }
            //                    else{
            //                        //设置密码
            //                        self.receipt = [self setPwdInLock:self.pwdTextField.text PwdNumber:num];
            //                    }
        }
        
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:Localized(@"synchronizeFailed")];
        
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:NO];
        [MBProgressHUD showError:Localized(@"synchronizeFailed")];
    }];
    
    //Mqtt递归查询密码是否存在
    /*
    [[KDSMQTTManager sharedManager] dlGetKeyInfo:self.lock.gwDevice completion:^(NSError * _Nullable error, KDSGWLockKeyInfo * _Nullable info) {
            if (!info || info.maxpwdusernum==0)
            {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
            }
            else
            {
                [self recursiveGetKeys:self.keyType from:0 to:(unsigned)info.maxpwdusernum recursiveCount:0 container:container completion:^{
                [hud hideAnimated:NO];
                NSUInteger menaceNum = 0;//胁迫密码编号是9
                for (KDSBleUserType *user in container)
                {
                if (user.userId == info.maxpwdusernum)
                {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
                return;
                }
                if (user.userId == 9) menaceNum = 9;
                }
                if (container.count == info.maxpwdusernum || (menaceNum != 9 && container.count == info.maxpwdusernum-1 && self.type != 3))
                {
                [hud hideAnimated:NO];
                [MBProgressHUD showError:Localized(@"passwordUpperLimit")];
                return;
                }
                int schedule = 0, temp = 0;
                NSString *warning = nil;
                for (KDSBleUserType *user in container)
                {
                if (info.maxpwdusernum == 20) {
                if (user.userId < 5 || (user.userId > 9 && user.userId <= 19))
                {
                schedule++;
                }
                else if (user.userId >=5 && user.userId <= 8)
                {
                temp++;
                }
                if (schedule == 15 && (self.type == 0 || self.type == 1))
                {
                warning = Localized(@"timelinessAndPeriodPwdUpperLimit");
                }
                else if (temp ==20 - 16 && self.type == 2)
                {
                warning = Localized(@"temporaryPwdUpperLimit");
                }
                
                }else{
                if (user.userId < 5)
                {
                schedule ++;
                }
                else if (user.userId != 9)
                {
                temp++;
                }
                if (schedule == 5 && self.type == 0)
                {
                warning = Localized(@"timelinessAndPeriodPwdUpperLimit");
                }
                else if (temp == info.maxpwdusernum - 6 && self.type == 2)
                {
                warning = Localized(@"temporaryPwdUpperLimit");
                }
                }
                }
                if (warning)
                {
                [hud hideAnimated:NO];
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:warning message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
                [ac addAction:okAction];
                [self presentViewController:ac animated:YES completion:nil];
                }
                else
                {
                int num = self.type==0 ? 0 : 5;
                NSMutableArray * userIds = [NSMutableArray array];
                for (KDSBleUserType *user in container)
                {
                if ([container containsObject: user]) {
                [userIds addObject:@(user.userId)];
                }
                }
                if (self.type != 2) {
                num = [self setNumWitchUserId:userIds AndUserCound:(int)info.maxpwdusernum];
                }else{
                num = [self setTempNumWitchUserId:userIds AndUserCound:(int)info.maxpwdusernum];
                }
                num = self.type==3 ? 9 : num;//胁迫密码的编号固定为9
                //先设置密码->再设置计划->再设置用户类型
                self.receipt = [self setPwdInLock:self.pwdTextField.text PwdNumber:num];
//                if ((self.type==0 && !self.strategyButtons.firstObject.selected) || self.type==1)
//                {
//                    //先设置计划->再设置密码->再设置用户类型
//                    self.receipt = [self setPwdInLockNewScheme:self.pwdTextField.text PwdNumber:num];
//                }
//                else{
//                    //设置密码
//                    self.receipt = [self setPwdInLock:self.pwdTextField.text PwdNumber:num];
//                }
                    
    
            }
        }];
    */
}

-(int)setNumWitchUserId:(NSArray *)userIds AndUserCound:(int)count
{
    int userNum = 0;
    for (int i = 0; i < count; i ++) {
        if (!(i > 4 && i < 10)) {
            if (![userIds containsObject:@(i)]) {
                userNum = i;
                return userNum;
            }
        }
    }
    return userNum;
}
-(int)setTempNumWitchUserId:(NSArray *)userIds AndUserCound:(int)count
{
    int userNum = 5;
    for (int i = 0; i < count; i ++) {
        if ((4 < i && i < 9)) {
            if (![userIds containsObject:@(i)]) {
                userNum = i;
                return userNum;
            }
        }
    }
    return userNum;
}

/**
 *@brief 递归获取[index1, index2)编号的密匙信息。不包含index2的编号，如果index1=index2，则递归结束。
 *@param type 密匙类型。
 *@param index1 起始密匙编号。
 *@param index2 结束密匙编号。
 *@param count 当某个编号获取失败时，继续获取该编号的最大递归次数。如果此值>=3，则不再继续获取。除首次外其它的递归次数最大都为3.
 *@param container 由使用者负责初始化的可变数组，每个编号递归结束后，结果(当成功时，编号小于index2，当失败时，编号等于index2)会存入此数组中。暂时使用蓝牙的用户类型，只用到编号。
 *@param completion 递归结束执行的回调。如果有一个编号获取失败或者全部编号获取完毕后执行。
 */
- (void)recursiveGetKeys:(KDSGWKeyType)type from:(unsigned)index1 to:(unsigned)index2 recursiveCount:(int)count container:(NSMutableArray<KDSBleUserType *> *)container completion:(void(^)(void))completion
{
    if (index1 == index2)
    {
        !completion ?: completion();
        return;
    }
    if (self.type == 2) {//临时密码
        if (index1 > 4 && index1 < 9) {
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:index1 type:(int)type completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
                BOOL finished = success;
                if (success)
                {
                    KDSBleUserType *user = [KDSBleUserType new];
                    user.userId = index1;
                    [container addObject:user];
                }
                else if (error && error.code == 0)
                {
                    finished = YES;
                }
                else if (count >= 3)
                {
                    KDSBleUserType *user = [KDSBleUserType new];
                    user.userId = index2;
                    [container addObject:user];
                    !completion ?: completion();
                    return;
                }
                [self recursiveGetKeys:type from:(count>=3 || finished) ? index1 + 1 : index1 to:index2 recursiveCount:count>=3 ? 0 : count + 1 container:container completion:completion];
                
            }];
        }else{
            
            [self recursiveGetKeys:type from: index1 + 1  to:index2 recursiveCount:count>=3 ? 0 : count + 1 container:container completion:completion];
        }
    }else{
        
        if (!(index1 > 4 && index1 <9)) {
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:1 withPwd:nil number:index1 type:(int)type completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
                BOOL finished = success;
                if (success)
                {
                    KDSBleUserType *user = [KDSBleUserType new];
                    user.userId = index1;
                    [container addObject:user];
                }
                else if (error && error.code == 0)
                {
                    finished = YES;
                }
                else if (count >= 3)
                {
                    KDSBleUserType *user = [KDSBleUserType new];
                    user.userId = index2;
                    [container addObject:user];
                    !completion ?: completion();
                    return;
                }
                [self recursiveGetKeys:type from:(count>=3 || finished) ? index1 + 1 : index1 to:index2 recursiveCount:count>=3 ? 0 : count + 1 container:container completion:completion];
            }];
        }else{
            
            [self recursiveGetKeys:type from: index1 + 1  to:index2 recursiveCount:count>=3 ? 0 : count + 1 container:container completion:completion];
        }
    }
}
#pragma mark - 设置时间密码方案2：先计划->再密码>再用户类型。
///根据密码和密码编号设置密码。先设置计划->-再设置密码>再设置用户类型->最后获取一下是否存在计划(最后一步可选)。
- (KDSMQTTTaskReceipt *)setPwdInLockNewScheme:(NSString *)pwd PwdNumber:(int)number
{
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = Localized(@"settingPwd");
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    
    return [weakSelf scheduleWithNumberNewScheme:number completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:NO];
        NSLog(@"设置锁密码策略是否成功：%d",success);
        weakSelf.receipt = nil;
        
        if (success)
        {
            
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:0 withPwd:pwd number:number type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
                weakSelf.receipt = nil;
                if (success)
                {
                    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setPwdType:1 withPwdNum:number completion:^(NSError * _Nullable error, BOOL success) {
                        
                        if (success)
                        {
                            KDSPwdListModel *m = [KDSPwdListModel new];
                            m.num = [NSString stringWithFormat:@"%02d", number];
                            m.pwd = pwd;
                            m.nickName = self.pwdNameTextField.text;
                            NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
                            
                            if (weakSelf.type == 1)
                            {//周期密码
                                m.type = KDSServerCycleTpyeCycle;
                                NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
                                NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];;
                                NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                                m.startTime = @([self.fmt dateFromString:begin].timeIntervalSince1970).stringValue;
                                m.endTime = @([self.fmt dateFromString:end].timeIntervalSince1970).stringValue;
                                
                                NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
                                for (int i = 0; i < 7; ++i)
                                {
                                    [items addObject:@((weakSelf.mask >> i) & 0x1)];
                                }
                                m.items = items.copy;
                            }
                            else
                            {
                                if (weakSelf.strategyButtons.lastObject.selected) {
                                    //时间段
                                    m.type =KDSServerCycleTpyePeriod;
                                    m.startTime = @((NSInteger)self.beginTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
                                    m.endTime = @((NSInteger)self.endTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
                                    
                                }else{
                                    //24小时
                                    m.type =KDSServerCycleTpyeTwentyfourHours;
                                    NSInteger interval = NSDate.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT;
                                    m.startTime = @(interval).stringValue;
                                    m.endTime = @(interval + 24 * 3600).stringValue;
                                }
                                
                            }
                            
                            m.pwdType = KDSServerKeyTpyePIN;
                            [[KDSDBManager sharedManager] insertPasswords:@[m] withLock:self.lock.gwDevice];
                            
                            KDSPINShareVC *vc = [KDSPINShareVC new];
                            vc.model = m;
                            vc.lock = weakSelf.lock;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }
                        else{
                            [hud hideAnimated:NO];
                            [MBProgressHUD showError:Localized(@"addFail")];
                        }
                    }];
                    
                }
                else{
                    [hud hideAnimated:NO];
                    [MBProgressHUD showError:Localized(@"addFail")];
                }
                
            }];
        }
        else
        {
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
    
}
#pragma mark - 设置时间密码方案1：先密码->再计划>再用户类型。
///根据密码和密码编号设置密码。先设置密码->再设置计划->再设置用户类型->最后获取一下是否存在计划(最后一步可选)。
- (KDSMQTTTaskReceipt *)setPwdInLock:(NSString *)pwd PwdNumber:(int)number
{
    __weak typeof(self) weakSelf = self;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.label.text = Localized(@"settingPwd");
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    return [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice manageKey:0 withPwd:pwd number:number type:1 completion:^(NSError * _Nullable error, BOOL success, NSString * _Nullable status, NSString * _Nullable userType) {
        weakSelf.receipt = nil;
        if (success)
        {
            KDSPwdListModel *m = [KDSPwdListModel new];
            m.num = [NSString stringWithFormat:@"%02d", number];
            m.pwd = pwd;
            m.nickName = self.pwdNameTextField.text;
            NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
            //[weakSelf addPasswordToServer:m];
            if ((weakSelf.type==0 && !weakSelf.strategyButtons.firstObject.selected) || weakSelf.type==1)
            {
                [weakSelf scheduleWithNumber:number completion:^(NSError * _Nullable error, BOOL success) {
                    [hud hideAnimated:NO];
                    NSLog(@"设置锁密码策略是否成功：%d",success);
                    if (success)
                    {
                        if (weakSelf.type == 1)
                        {//周期密码
                            m.type = KDSServerCycleTpyeCycle;
                            NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
                            NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];;
                            NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
                            m.startTime = @([self.fmt dateFromString:begin].timeIntervalSince1970).stringValue;
                            m.endTime = @([self.fmt dateFromString:end].timeIntervalSince1970).stringValue;
                            
                            NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
                            for (int i = 0; i < 7; ++i)
                            {
                                [items addObject:@((weakSelf.mask >> i) & 0x1)];
                            }
                            m.items = items.copy;
                        }
                        else
                        {
                            if (weakSelf.strategyButtons.lastObject.selected) {
                                //时间段
                                m.type =KDSServerCycleTpyePeriod;
                                m.startTime = @((NSInteger)self.beginTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
                                m.endTime = @((NSInteger)self.endTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
                                
                            }else{
                                //24小时
                                m.type =KDSServerCycleTpyeTwentyfourHours;
                                NSInteger interval = NSDate.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT;
                                m.startTime = @(interval).stringValue;
                                m.endTime = @(interval + 24 * 3600).stringValue;
                            }
                            
                        }
                        
                        m.pwdType = KDSServerKeyTpyePIN;
                        [[KDSDBManager sharedManager] insertPasswords:@[m] withLock:self.lock.gwDevice];
                        KDSPINShareVC *vc = [KDSPINShareVC new];
                        vc.model = m;
                        vc.lock = weakSelf.lock;
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    }
                    else
                    {
                        [MBProgressHUD showError:Localized(@"setFailed")];
                    }
                }];
                return;
            }
            else if (weakSelf.type == 2)//临时密码
            {
                m.pwdType = KDSServerKeyTpyeTempPIN;
                
            }
            else //永久密码
            {
                m.type = KDSServerCycleTpyeForever;
                m.pwdType = KDSServerKeyTpyePIN;
            }
            [hud hideAnimated:NO];
            
            [[KDSDBManager sharedManager] insertPasswords:@[m] withLock:self.lock.gwDevice];
            
            KDSPINShareVC *vc = [KDSPINShareVC new];
            vc.model = m;
            vc.lock = weakSelf.lock;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [hud hideAnimated:NO];
            [MBProgressHUD showError:Localized(@"addFail")];
        }
    }];
}
#pragma mark - 设置时间密码方案1：再计划>再用户类型。
///根据密码编号设置年月日、周计划，完毕执行completion回调。先设置计划->再设置用户类型->最后获取一下是否存在计划(最后一步可选)。
- (void)scheduleWithNumber:(int)number completion:(void(^)(NSError * _Nullable error, BOOL success))completion
{
    KDSGWLockSchedule *schedule = [KDSGWLockSchedule new];
    schedule.scheduleId = schedule.userId = number;
    if (self.type==0)
    {
        NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
        schedule.yearAndWeek = @"year";
        if (self.strategyButtons.lastObject.selected)
        {//时间段
            schedule.beginTime = @((NSInteger)self.beginTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
            schedule.endTime = @((NSInteger)self.endTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
        }
        else
        {//24小时
            NSInteger interval = NSDate.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT;
            schedule.beginTime = @(interval).stringValue;
            schedule.endTime = @(interval + 24 * 3600).stringValue;
        }
    }
    else
    {//周期
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"HH:mm";
        NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
        NSArray<NSString *> *begins = [comps.firstObject componentsSeparatedByString:@":"];
        NSArray<NSString *> *ends = [comps.lastObject componentsSeparatedByString:@":"];
        schedule.mask = self.mask;
        schedule.yearAndWeek = @"week";
        schedule.beginH = begins.firstObject.intValue;
        schedule.beginMin = begins.lastObject.intValue;
        schedule.endH = ends.firstObject.intValue;
        schedule.endMin = ends.lastObject.intValue;
    }
    [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:0 withSchedule:schedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
        NSLog(@"设置密码周计划策略是否成功：%d-%@-%d" ,success,schedule,self.type);
        if (success)
        {
            [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice setPwdType:1 withPwdNum:number completion:^(NSError * _Nullable error, BOOL success) {
                !completion ?: completion(error, success);
            }];
        }
        else
        {
            !completion ?: completion(error, NO);
        }
    }];
}
#pragma mark - 设置时间密码方案2：单纯时间策略。
///根据密码编号设置年月日、周计划，完毕执行completion回调。
- (KDSMQTTTaskReceipt *)scheduleWithNumberNewScheme:(int)number completion:(void(^)(NSError * _Nullable error, BOOL success))completion
{
    
    KDSGWLockSchedule *schedule = [KDSGWLockSchedule new];
    schedule.scheduleId = schedule.userId = number;
    if (self.type==0)
    {
        NSTimeInterval secondsFromGMT = [NSTimeZone localTimeZone].secondsFromGMT;
        schedule.yearAndWeek = @"year";
        if (self.strategyButtons.lastObject.selected)
        {//时间段
            schedule.beginTime = @((NSInteger)self.beginTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
            schedule.endTime = @((NSInteger)self.endTimelinessView.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT).stringValue;
        }
        else
        {//24小时
            NSInteger interval = NSDate.date.timeIntervalSince1970 - MQTTFixedTime + secondsFromGMT;
            schedule.beginTime = @(interval).stringValue;
            schedule.endTime = @(interval + 24 * 3600).stringValue;
        }
    }
    else
    {//周期
        NSDateFormatter *fmt = [KDSUserManager sharedManager].dateFormatter;
        fmt.dateFormat = @"HH:mm";
        NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
        NSArray<NSString *> *begins = [comps.firstObject componentsSeparatedByString:@":"];
        NSArray<NSString *> *ends = [comps.lastObject componentsSeparatedByString:@":"];
        schedule.mask = self.mask;
        schedule.yearAndWeek = @"week";
        schedule.beginH = begins.firstObject.intValue;
        schedule.beginMin = begins.lastObject.intValue;
        schedule.endH = ends.firstObject.intValue;
        schedule.endMin = ends.lastObject.intValue;
    }
    return [[KDSMQTTManager sharedManager] dl:self.lock.gwDevice scheduleAction:0 withSchedule:schedule completion:^(NSError * _Nullable error, BOOL success, KDSGWLockSchedule * _Nullable schedule) {
        NSLog(@"设置密码周计划策略是否成功：%d-%@-%d" ,success,schedule,self.type);
        if (success)
        {
            !completion ?: completion(error, success);
        }
        else
        {
            !completion ?: completion(error, NO);
        }
    }];
}

#pragma mark - 网络请求相关方法。
/**
 *@brief 将密码信息上传到服务器。@note 原为蓝牙使用，网关锁先不使用此接口。
 *@param m 根据相关信息生成的密码模型，此参数只需设置密码编号，剩下的参数在方法内会设置。
 */
- (void)addPasswordToServer:(KDSPwdListModel *)m
{
    m.nickName = self.pwdNameTextField.text ?: self.nicknameButtons.firstObject.currentTitle;
    if (self.type == 0)
    {
        m.pwdType = KDSServerKeyTpyePIN;
        m.type = self.strategyButtons.firstObject.selected ? KDSServerCycleTpyeForever : (self.strategyButtons.lastObject.selected ? KDSServerCycleTpyePeriod : KDSServerCycleTpyeTwentyfourHours);
        m.startTime = @(self.beginTimelinessView.date.timeIntervalSince1970).stringValue;
        m.endTime = @(self.endTimelinessView.date.timeIntervalSince1970).stringValue;
    }
    else if (self.type == 1)
    {
        m.pwdType = KDSServerKeyTpyePIN;
        m.type = KDSServerCycleTpyeCycle;
        NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
        NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];;
        NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        m.startTime = @([self.fmt dateFromString:begin].timeIntervalSince1970).stringValue;
        m.endTime = @([self.fmt dateFromString:end].timeIntervalSince1970).stringValue;
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:7];
        for (int i = 0; i < 7; ++i)
        {
            [items addObject:@((self.mask >> i) & 0x1)];
        }
        m.items = items.copy;
    }
    else
    {
        m.pwdType = KDSServerKeyTpyeTempPIN;
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;
    if (string.length != strlen(string.UTF8String)) return NO;
    if (string.length + textField.text.length > 12) return NO;
    for (int i = 0; i < string.length; ++i)
    {
        if (string.UTF8String[i]<'0' || string.UTF8String[i]>'9') return NO;
    }
    return YES;
}


@end
