//
//  KDSAddPINProxyVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddPINProxyVC.h"
#import "Masonry.h"
#import "KDSTimelinessView.h"
#import "KDSDatePickerVC.h"
#import "KDSWeekPickerVC.h"
#import "KDSHttpManager+Ble.h"
#import "MBProgressHUD+MJ.h"
#import "KDSPINShareVC.h"
#import "UIView+Extension.h"

@interface KDSAddPINProxyVC () <UITextFieldDelegate>

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
@property (nonatomic, strong, readonly) NSDateFormatter *fmt;
///设置密码时返回的凭证。
@property (nonatomic, strong) NSString *receipt;

@end

@implementation KDSAddPINProxyVC

#pragma mark - getter setter
- (NSDateFormatter *)fmt
{
    NSDateFormatter *fmt = self.lock.bleTool.dateFormatter;
    fmt.dateFormat = @"HH:mm";
    return fmt;
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
    self.mask = 0x7f;
    [self setupUI];
}

- (void)dealloc
{
    [self.lock.bleTool cancelTaskWithReceipt:self.receipt];
}
- (void)setupUI
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.type==2 ? 561 : 598)];;
    self.tableView.tableHeaderView = headerView;
    
    UILabel *tipsLabel = [self createLabelWithText:Localized(@"addPINTips") color:KDSRGBColor(0x33, 0x33, 0x33) font:[UIFont systemFontOfSize:12]];
    tipsLabel.numberOfLines = 0;
    [headerView addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(17);
        make.left.equalTo(headerView).offset(33);
        make.right.equalTo(headerView).offset(-15);
    }];
    CGRect frame = headerView.frame;
    frame.size.height += (tipsLabel.bounds.size.height - 12);
    
    UIImageView *exclamationMarkIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exclamationMark"]];
    [headerView addSubview:exclamationMarkIV];
    [exclamationMarkIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(tipsLabel.mas_left).offset(-7);
        make.centerY.equalTo(tipsLabel);
        make.width.height.equalTo(@12);
    }];
    
    UIView *pwdCornerView = [self createPwdCornerView];
    [headerView addSubview:pwdCornerView];
    [pwdCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(exclamationMarkIV.mas_bottom).offset(33);
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
    
    UIView *pwdNameCornerView = [self createPwdNameCornerView];
    [headerView addSubview:pwdNameCornerView];
    [pwdNameCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(savePwdTipsLabel.mas_bottom).offset(25);
        make.left.equalTo(headerView).offset(15);
        make.right.equalTo(headerView).offset(-15);
        make.height.equalTo(@50);
    }];
    
    self.nicknameButtons = [self createNicknameButtonsWithSuperview:headerView constraintView:pwdNameCornerView];
    
    if (self.type == 0)
    {
        self.strategyButtons = [self createStrategyButtonsWithSuperview:headerView constraintView:self.nicknameButtons.lastObject];
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
            make.top.equalTo(self.nicknameButtons.lastObject.mas_bottom).offset(30);
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
        UILabel *tempPwdTipsLabel = [self createLabelWithText:Localized(@"tempPwdCanOnlyUseOnce") color:KDSRGBColor(0x99, 0x99, 0x99) font:[UIFont systemFontOfSize:12]];
        tempPwdTipsLabel.textAlignment = NSTextAlignmentCenter;
        tempPwdTipsLabel.numberOfLines = 0;
        [headerView addSubview:tempPwdTipsLabel];
        [tempPwdTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nicknameButtons.firstObject.mas_bottom).offset(96);
            make.left.right.equalTo(pwdCornerView);
            make.height.equalTo(@(ceil([tempPwdTipsLabel.text boundingRectWithSize:CGSizeMake(kScreenWidth - 30, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tempPwdTipsLabel.font} context:nil].size.height)));
        }];
    }
    
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
    if (!self.lock.bleTool.connectedPeripheral)
    {
        [MBProgressHUD showError:Localized(@"bleNotConnect")];
        return;
    }
    if ([KDSTool isSimplePasswordInLock:self.pwdTextField.text])
    {
        [MBProgressHUD showError:Localized(@"pleaseInputAtLeast6NumericsPwd")];
        return;
    }
    if (self.type == 1) {
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
    [self checkAllKeysAtLock:^(BOOL success, NSArray<KDSBleUserType *> * _Nullable users) {
        if (success)
        {
            [self checkConditionAndAddPasswordWithExistedPasswords:users];
        }
    }];
}

#pragma mark - 蓝牙工具接口相关方法。
///如果获取成功且密码未满，则回调执行参数为YES，否则回调执行参数为NO且提示失败原因。
- (void)checkAllKeysAtLock:(nullable void(^)(BOOL success, NSArray<KDSBleUserType *> * _Nullable users))completion
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview.superview animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    [self getAllKeys:KDSBleKeyTypePIN times:3 completion:^(KDSBleError error, NSArray<KDSBleUserType *> * _Nullable users) {
        
        [hud hideAnimated:NO];
        if (error != KDSBleErrorSuccess)
        {
            !completion ?: completion(NO, nil);
            [MBProgressHUD showError:Localized(@"anErrorOccur,pleaseRetryLater")];
            return;
        }
        int schedule = 0, temp = 0;
        NSString *warning = nil;
        for (KDSBleUserType *user in users)
        {
            if (self.isSupport20setsPasswords) {
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
                    schedule++;
                }
                else if (user.userId != 9)
                {
                    temp++;
                }
                if (schedule == 5 && (self.type == 0 || self.type == 1))
                {
                    warning = Localized(@"timelinessAndPeriodPwdUpperLimit");
                }
                else if (temp == self.lock.bleTool.connectedPeripheral.maxUsers - 6 && self.type == 2)
                {
                    warning = Localized(@"temporaryPwdUpperLimit");
                }
            }
        }
        if (warning)
        {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:warning message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:nil];
            [ac addAction:okAction];
            [self presentViewController:ac animated:YES completion:nil];
        }
        !completion ?: completion(!warning, !warning ? users : nil);
    }];
}

///获取已设置的所有密码、卡片、指纹，调用时times传0，最多3次，3次都失败就算失败，completion是获取操作完毕后的回调，成功时users才有意义。
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

///检查输入条件，如果通过则调用添加密码接口，否则提示失败。
- (void)checkConditionAndAddPasswordWithExistedPasswords:(NSArray<KDSBleUserType *> *)users
{
    if (self.receipt) return;
    if (self.type == 0 && self.strategyButtons[2].selected){
        if ((self.endTimelinessView.date.timeIntervalSince1970 - self.beginTimelinessView.date.timeIntervalSince1970) < 1)
        {
            [MBProgressHUD showError:Localized(@"lessThanEndTime")];
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    /**************永久密码：00～04，临时密码：05～08，胁迫密码：09************/
    int num;
    NSMutableArray * userIds = [NSMutableArray array];
    for (KDSBleUserType *user in users) {
        if ([users containsObject: user]) {
            [userIds addObject:@(user.userId)];
        }
    }
    int UserCount = [KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@24] ? 20 : 10;
    if (self.type != 2) {
        num = [self setNumWitchUserId:userIds AndUserCound:UserCount];
    }else{
        num = [self setTempNumWitchUserId:userIds AndUserCound:UserCount];
    }
   /*
    if ([KDSLockFunctionSet[self.lock.lockFunctionSet] containsObject:@24]) {//20组密码
        ///时效：24小时、自定义、周期密码编号0～4
        if ((self.type == 0 && (self.strategyButtons[2].selected || self.strategyButtons[1].selected)) || self.type == 1) {
            
            if ((num >= 10 && num <= 19) || (num >=5 && num <=8)) {
                [MBProgressHUD showError:@"只有编号0～4才可以添加策略密码"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view.superview.superview];
                });
                return;
            }
        }
    }
    */
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview.superview animated:YES];
    hud.labelText = Localized(@"settingPwd");
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    self.receipt = [self setPwdInLock:self.pwdTextField.text PwdNumber:num completion:^(KDSBleError error) {
        
        [MBProgressHUD hideHUDForView:weakSelf.view.superview.superview];
        if (error == KDSBleErrorSuccess)
        {
            weakSelf.receipt = nil;
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            KDSPwdListModel *m = [KDSPwdListModel new];
            m.num = [NSString stringWithFormat:@"%02d", num];
            [weakSelf addPasswordToServer:m];
            m.pwd = weakSelf.pwdTextField.text;
            KDSPINShareVC *vc = [KDSPINShareVC new];
            vc.model = m;
            vc.lock = weakSelf.lock;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            weakSelf.receipt = nil;
            [MBProgressHUD hideHUDForView:weakSelf.view];
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
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

///根据密码和密码编号设置密码，完毕执行completion回调。
- (NSString *)setPwdInLock:(NSString *)pwd PwdNumber:(int)number completion:(void(^)(KDSBleError error))completion
{
    __weak typeof(self) weakSelf = self;
    KDSBluetoothTool *tool = self.lock.bleTool;
    return [tool manageKeyWithPwd:pwd userId:@(number).stringValue action:KDSBleKeyManageActionSet keyType:KDSBleKeyTypePIN completion:^(KDSBleError error) {
        
        if (error == KDSBleErrorSuccess)
        {
            if ((weakSelf.type==0 && weakSelf.strategyButtons.firstObject.selected) || weakSelf.type==2)
            {
                !completion ?: completion(error);
            }
            else if (weakSelf.type==0 && !weakSelf.strategyButtons.firstObject.selected)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf scheduleYMDWithNumber:number completion:completion];
                    NSLog(@"-----设置年月日----");
                });
                
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf scheduleWeeklyWithNumber:number completion:completion];
                    NSLog(@"-----设置重复周期----");
                });
                
            }
        }
        else
        {
            !completion ?: completion(error);
        }
    }];
}

///根据密码编号设置年月日计划，完毕执行completion回调。先设置计划->再设置用户类型->最后获取一下是否存在计划。
- (void)scheduleYMDWithNumber:(int)number completion:(void(^)(KDSBleError error))completion
{
    __weak KDSBluetoothTool *tool = self.lock.bleTool;
    tool.dateFormatter.dateFormat = @"yyyyMMddHHmm";
    NSString *begin = [tool.dateFormatter stringFromDate:self.strategyButtons.lastObject.selected ?  self.beginTimelinessView.date : NSDate.date];
    NSString *end = [tool.dateFormatter stringFromDate:self.strategyButtons.lastObject.selected ?  self.endTimelinessView.date : [NSDate dateWithTimeIntervalSinceNow:24*3600]];
    [tool scheduleYMDWithScheduleId:number userId:number keyType:KDSBleKeyTypePIN begin:begin end:end completion:^(KDSBleError error) {
       
        if (error == KDSBleErrorSuccess)
        {
            [tool setUserTypeWithId:@(number).stringValue KeyType:KDSBleKeyTypePIN userType:KDSBleSetUserTypeSchedule completion:^(KDSBleError error) {
                
                if (error == KDSBleErrorSuccess)
                {
                    [tool getScheduleWithScheduleId:number completion:^(KDSBleError error, KDSBleScheduleModel * _Nullable model) {
                        
                        !completion ?: completion([model isKindOfClass:KDSBleYMDModel.class] ? KDSBleErrorSuccess : (error==KDSBleErrorSuccess ? KDSBleErrorFailure : error));
                    }];
                }else{
                    !completion ?: completion(error);
                }
            }];
        }
        else
        {
            !completion ?: completion(error);
        }
    }];
}

///根据密码编号设置周计划，完毕执行completion回调。先设置计划->再设置用户类型->最后获取一下是否存在计划。
- (void)scheduleWeeklyWithNumber:(int)number completion:(void(^)(KDSBleError error))completion
{
    __weak KDSBluetoothTool *tool = self.lock.bleTool;
    NSArray<NSString *> *comps = [self.beginTimelinessView.content componentsSeparatedByString:@"~"];
    NSString *begin = [comps.firstObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];;
    NSString *end = [comps.lastObject stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    int bh = [begin componentsSeparatedByString:@":"].firstObject.intValue;
    int bm = [begin componentsSeparatedByString:@":"].lastObject.intValue;
    int eh = [end componentsSeparatedByString:@":"].firstObject.intValue;
    int em = [end componentsSeparatedByString:@":"].lastObject.intValue;
    [tool scheduleWeeklyWithScheduleId:number userId:number keyType:KDSBleKeyTypePIN weekMask:self.mask beginHour:bh beginMin:bm endHour:eh endMin:em completion:^(KDSBleError error) {
        
        if (error == KDSBleErrorSuccess)
        {
            [tool setUserTypeWithId:@(number).stringValue KeyType:KDSBleKeyTypePIN userType:KDSBleSetUserTypeSchedule completion:^(KDSBleError error) {
                
                if (error == KDSBleErrorSuccess)
                {
                    [tool getScheduleWithScheduleId:number completion:^(KDSBleError error, KDSBleScheduleModel * _Nullable model) {
                        
                        !completion ?: completion([model isKindOfClass:KDSBleWeeklyModel.class] ? KDSBleErrorSuccess : (error==KDSBleErrorSuccess ? KDSBleErrorFailure : error));
                        
                    }];
                }
                else
                {
                    !completion ?: completion(error);
                }
            }];
        }
        else
        {
            !completion ?: completion(error);
        }
    }];
}

#pragma mark - 网络请求相关方法。
/**
 *@brief 将密码信息上传到服务器。
 *@param m 根据相关信息生成的密码模型，此参数只需设置密码编号，剩下的参数在方法内会设置。
 */
- (void)addPasswordToServer:(KDSPwdListModel *)m
{
    m.nickName = self.pwdNameTextField.text.length ? self.pwdNameTextField.text : self.nicknameButtons.firstObject.currentTitle;
    if (self.type == 0)
    {
        m.pwdType = KDSServerKeyTpyePIN;
        m.type = self.strategyButtons.firstObject.selected ? KDSServerCycleTpyeForever : (self.strategyButtons.lastObject.selected ? KDSServerCycleTpyePeriod : KDSServerCycleTpyeTwentyfourHours);
        if (self.strategyButtons.lastObject.selected)//自定义
        {
            m.startTime = @(self.beginTimelinessView.date.timeIntervalSince1970).stringValue;
            m.endTime = @(self.endTimelinessView.date.timeIntervalSince1970).stringValue;
        }
        else//24小时，永久不用管。
        {
            NSDate *date = NSDate.date;
            m.startTime = @(date.timeIntervalSince1970).stringValue;
            m.endTime = @(date.timeIntervalSince1970 + 24 * 3600).stringValue;
        }
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
    [[KDSHttpManager sharedManager] addBlePwds:@[m] withUid:[KDSUserManager sharedManager].user.uid bleName:self.lock.device.lockName success:nil error:nil failure:nil];
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
