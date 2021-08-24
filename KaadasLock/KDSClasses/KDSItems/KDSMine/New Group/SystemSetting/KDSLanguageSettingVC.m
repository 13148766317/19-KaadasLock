//
//  KDSLanguageSettingVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSLanguageSettingVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMineViewController.h"


@interface KDSLanguageSettingVC ()

///简体中文选择按钮。
@property (nonatomic, strong) UIButton *zhsBtn;
///繁体中文选择按钮。
@property (nonatomic, strong) UIButton *zhtBtn;
///英语中文选择按钮。
@property (nonatomic, strong) UIButton *enBtn;
///泰语选择按钮。
@property (nonatomic, strong) UIButton *thBtn;

@end

@implementation KDSLanguageSettingVC

#pragma mark - 生命周期和UI方法。
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationTitleLabel.text = Localized(@"languageSetting");
    UIView *zhsView = [self createSubviewWithImage:@"语言设置-中文" text:@"简体中文" containSingleLine:YES];
    self.zhsBtn = [zhsView viewWithTag:123];
    [self.view addSubview:zhsView];
    
    UIView *zhtView = [self createSubviewWithImage:@"zhTraditional" text:@"繁體中文" containSingleLine:YES];
    CGRect frame = zhtView.frame;
    frame.origin.y += 75;
    zhtView.frame = frame;
    self.zhtBtn = [zhtView viewWithTag:123];
    [self.view addSubview:zhtView];
    
    UIView *enView = [self createSubviewWithImage:@"语言设置-英语" text:@"English" containSingleLine:YES];
    frame = enView.frame;
    frame.origin.y += 150;
    enView.frame = frame;
    self.enBtn = [enView viewWithTag:123];
    [self.view addSubview:enView];
    
    UIView *thView = [self createSubviewWithImage:@"语言设置-泰语" text:@"ภาษาไทย" containSingleLine:NO];
    frame = thView.frame;
    frame.origin.y += 225;
    thView.frame = frame;
    self.thBtn = [thView viewWithTag:123];
    [self.view addSubview:thView];
    
    NSString *language = [KDSTool getLanguage];
    if ([language hasPrefix:JianTiZhongWen])
    {//开头匹配简体中文
        self.zhsBtn.selected = YES;
    }
    else if ([language hasPrefix:FanTiZhongWen])
    {//开头匹配繁体中文
        self.zhtBtn.selected = YES;
    }
    else if ([language hasPrefix:Thailand])
    {
        self.thBtn.selected = YES;
    }
    else
    {//其他一律设置为英文
        self.enBtn.selected = YES;
    }
    
    //确认按钮
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.layer.cornerRadius = 22;
    doneBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [doneBtn setTitle:Localized(@"ok") forState:UIControlStateNormal];
    [doneBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(setSystemLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneBtn];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-80);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

///创建一个语言子视图，返回的view中tag=122的是标签，tag=123的是按钮。
- (UIView *)createSubviewWithImage:(NSString *)imgName text:(NSString *)text containSingleLine:(BOOL)contain
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 75)];
    view.backgroundColor = UIColor.whiteColor;
    UIImageView * imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:imgName];
    [view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(24);
        make.centerY.equalTo(@0);
    }];
    UIImage *normalImg = [UIImage imageNamed:@"未选择"];
    UIImage *selectedImg = [UIImage imageNamed:@"选择"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 123;
    [btn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [btn setBackgroundImage:selectedImg forState:UIControlStateSelected];
    btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [btn addTarget:self action:@selector(selectSystemLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-17);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@22);
    }];
    UIFont *font = [UIFont systemFontOfSize:15];
    UILabel *label = [[UILabel alloc] init];
    label.tag = 122;
    label.text = text;
    label.font = font;
    label.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view);
        make.left.equalTo(view).offset(71);
        make.right.equalTo(btn.mas_left).offset(-27);
    }];
    if (contain)
    {
        UIView *separactor = [[UIView alloc] initWithFrame:(CGRect){20, 74, kScreenWidth - 20, 1}];
        separactor.backgroundColor = KDSRGBColor(0xf0, 0xf0, 0xf0);
        [view addSubview:separactor];
    }
    
    return view;
}

#pragma mark - 控件等事件方法。
///选择语言
- (void)selectSystemLanguage:(UIButton *)sender
{
    self.zhsBtn.selected = self.zhtBtn.selected = self.enBtn.selected = self.thBtn.selected = NO;
    sender.selected = YES;
}

///设置语言
- (void)setSystemLanguage:(UIButton *)sender
{
    if (self.zhsBtn.selected)///简体中文
    {
        [KDSTool setLanguage:JianTiZhongWen];
    }
    else if (self.zhtBtn.selected)///繁体中文
    {
        [KDSTool setLanguage:FanTiZhongWen];
    }
    else if (self.enBtn.selected)///英语
    {
        [KDSTool setLanguage:English];
    }
    else
    { ///泰语
        [KDSTool setLanguage:Thailand];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    self.navigationTitleLabel.text = Localized(@"languageSetting");
    [sender setTitle:Localized(@"ok") forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
       
    });
}


@end
