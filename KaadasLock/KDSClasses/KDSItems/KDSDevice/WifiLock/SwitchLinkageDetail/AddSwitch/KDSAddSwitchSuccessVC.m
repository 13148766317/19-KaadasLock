//
//  KDSAddSwitchSuccessVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddSwitchSuccessVC.h"
#import "UIView+Extension.h"
#import "KDSHttpManager+WifiLock.h"

@interface KDSAddSwitchSuccessVC ()

///一键位昵称父视图
@property (nonatomic,strong)UIView * firstView;
///一键昵称
@property (nonatomic,strong)UITextField * nameTf;
///二键位昵称父视图
@property (nonatomic,strong)UIView * twoView;
///二键昵称
@property (nonatomic,strong)UITextField * twoNameTf;
///三键位昵称父视图
@property (nonatomic,strong)UIView * threeView;
///三键昵称
@property (nonatomic,strong)UITextField * threeNameTf;
///四键位昵称父视图
@property (nonatomic,strong)UIView * fourView;
///四键昵称
@property (nonatomic,strong)UITextField * fourNameTf;
///单火开关的数据json数据
@property (nonatomic,strong)NSMutableDictionary * switchDict;
///开关按键数据信息数组
@property (nonatomic, strong)NSMutableArray<NSMutableDictionary *> * switchArray;

@end

@implementation KDSAddSwitchSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addSuccess");
    [self setUI];
}

-(void)setUI
{
    UIImageView * devIconImg = [UIImageView new];
    ///根据数据type显示不同的开关图片
    NSString * devImgName;
    if (self.switchType == 1) {
        devImgName = @"addSingleKeyIconImg";
    }else if (self.switchType == 2){
        devImgName = @"addTwoKeyIconImg";
    }else if (self.switchType == 3){
        devImgName = @"addThreeKeyIconImg";
    }else if (self.switchType == 4){
        devImgName = @"addfourThreeKeyIconimg";
    }
    devIconImg.image = [UIImage imageNamed:devImgName];
    [self.view addSubview:devIconImg];
    [devIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(46);
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(devIconImg.image.size));
    }];
    
    UILabel * tipsLb = [UILabel new];
    ///根据数据type显示具体是几键位开关
    tipsLb.text = [NSString stringWithFormat:@"您添加的是%ld键位开关，取个名字吧！",self.switchType];
    tipsLb.font = [UIFont systemFontOfSize:15];
    tipsLb.textAlignment = NSTextAlignmentCenter;
    tipsLb.textColor = KDSRGBColor(153, 153, 153);
    [self.view addSubview:tipsLb];
    [tipsLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(devIconImg.mas_bottom).offset(10);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
        
    }];
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"开关名称";
    tipsLb2.textColor = KDSRGBColor(51, 51, 51);
    tipsLb2.font = [UIFont systemFontOfSize:14];
    tipsLb.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLb.mas_bottom).offset(50);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.width.equalTo(@200);
        make.height.equalTo(@20);
        
    }];
    
    self.firstView = [UIView new];
    self.firstView.backgroundColor = UIColor.whiteColor;
    self.firstView.layer.cornerRadius = 4;
    self.firstView.layer.masksToBounds = YES;
    [self.view addSubview:self.firstView];
    [self.firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(tipsLb2.mas_bottom).offset(KDSScreenWidth <= 375 ? 10 : 20);
    }];

    UIImageView * editImg = [UIImageView new];
    editImg.image = [UIImage imageNamed:@"edit"];
    [self.firstView addSubview:editImg];
    [editImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(self.firstView.mas_centerY).offset(0);
        make.right.mas_equalTo(self.firstView.mas_right).offset(-15);
        
    }];
    
    self.nameTf = [UITextField new];
    self.nameTf.placeholder = @"请输入键位1开关名称";
    self.nameTf.textColor = UIColor.blackColor;
    self.nameTf.font = [UIFont systemFontOfSize:15];
    self.nameTf.textAlignment = NSTextAlignmentLeft;
    self.nameTf.borderStyle=UITextBorderStyleNone;
    [self.nameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.firstView addSubview:self.nameTf];
    [self.nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.firstView.mas_left).offset(10);
        make.right.mas_equalTo(editImg.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
       
    }];
    
    self.twoView = [UIView new];
    self.twoView.backgroundColor = UIColor.whiteColor;
    self.twoView.layer.cornerRadius = 4;
    self.twoView.layer.masksToBounds = YES;
    [self.view addSubview:self.twoView];
    [self.twoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(self.firstView.mas_bottom).offset(KDSScreenWidth <= 375 ? 10 : 20);
    }];

    UIImageView * twoEditImg = [UIImageView new];
    twoEditImg.image = [UIImage imageNamed:@"edit"];
    [self.twoView addSubview:twoEditImg];
    [twoEditImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(self.twoView.mas_centerY).offset(0);
        make.right.mas_equalTo(self.twoView.mas_right).offset(-15);
        
    }];
    
    self.twoNameTf = [UITextField new];
    self.twoNameTf.placeholder = @"请输入键位2开关名称";
    self.twoNameTf.textColor = UIColor.blackColor;
    self.twoNameTf.font = [UIFont systemFontOfSize:15];
    self.twoNameTf.textAlignment = NSTextAlignmentLeft;
    self.twoNameTf.borderStyle=UITextBorderStyleNone;
    [self.twoNameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.twoView addSubview:self.twoNameTf];
    [self.twoNameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.twoView.mas_left).offset(10);
        make.right.mas_equalTo(twoEditImg.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
       
    }];
    
    self.threeView = [UIView new];
    self.threeView.backgroundColor = UIColor.whiteColor;
    self.threeView.layer.cornerRadius = 4;
    self.threeView.layer.masksToBounds = YES;
    [self.view addSubview:self.threeView];
    [self.threeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(self.twoView.mas_bottom).offset(KDSScreenWidth <= 375 ? 10 : 20);
    }];

    UIImageView * threeEditImg = [UIImageView new];
    threeEditImg.image = [UIImage imageNamed:@"edit"];
    [self.threeView addSubview:threeEditImg];
    [threeEditImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(self.threeView.mas_centerY).offset(0);
        make.right.mas_equalTo(self.threeView.mas_right).offset(-15);
        
    }];
    
    self.threeNameTf = [UITextField new];
    self.threeNameTf.placeholder = @"请输入键位3开关名称";
    self.threeNameTf.textColor = UIColor.blackColor;
    self.threeNameTf.font = [UIFont systemFontOfSize:15];
    self.threeNameTf.textAlignment = NSTextAlignmentLeft;
    self.threeNameTf.borderStyle=UITextBorderStyleNone;
    [self.threeNameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.threeView addSubview:self.threeNameTf];
    [self.threeNameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.threeView.mas_left).offset(10);
        make.right.mas_equalTo(threeEditImg.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
       
    }];
    
    self.fourView = [UIView new];
    self.fourView.backgroundColor = UIColor.whiteColor;
    self.fourView.layer.cornerRadius = 4;
    self.fourView.layer.masksToBounds = YES;
    [self.view addSubview:self.fourView];
    [self.fourView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@50);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.top.equalTo(self.threeView.mas_bottom).offset(KDSScreenWidth <= 375 ? 10 : 20);
    }];

    UIImageView * fourEditImg = [UIImageView new];
    fourEditImg.image = [UIImage imageNamed:@"edit"];
    [self.fourView addSubview:fourEditImg];
    [fourEditImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(self.fourView.mas_centerY).offset(0);
        make.right.mas_equalTo(self.fourView.mas_right).offset(-15);
        
    }];
    
    self.fourNameTf = [UITextField new];
    self.fourNameTf.placeholder = @"请输入键位4开关名称";
    self.fourNameTf.textColor = UIColor.blackColor;
    self.fourNameTf.font = [UIFont systemFontOfSize:15];
    self.fourNameTf.textAlignment = NSTextAlignmentLeft;
    self.fourNameTf.borderStyle=UITextBorderStyleNone;
    [self.fourNameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.fourView addSubview:self.fourNameTf];
    [self.fourNameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.fourView.mas_left).offset(10);
        make.right.mas_equalTo(fourEditImg.mas_left).offset(-5);
        make.top.bottom.mas_equalTo(0);
       
    }];
    
    UIButton * completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    completeBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    completeBtn.layer.cornerRadius = 22;
    completeBtn.layer.masksToBounds = YES;
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [completeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:completeBtn];
    [completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenWidth < 375 ? -40 : -70);
    }];
    
    if (self.switchType == 1) {
        self.twoView.hidden = YES;
        self.threeView.hidden = YES;
        self.fourView.hidden = YES;
        return;
    }else if (self.switchType == 2)
    {
        self.threeView.hidden = YES;
        self.fourView.hidden = YES;
        return;
    }else if (self.switchType == 3)
    {
        self.fourView.hidden = YES;
        return;
    }
    
    
}

#pragma mark 点击事件

///完成按钮
-(void)completeBtnClick:(UIButton *)btn
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    NSMutableArray * switchNicknameArr = [[NSMutableArray alloc] init];
    NSDictionary * dict;
    for (int i = 0; i < self.switchType; i ++) {
        if (i+1 == 1) {
           dict = @{@"type":@(1),@"nickname":self.nameTf.text};
           [switchNicknameArr addObject:dict];
        }else if (i +1 == 2){
            dict = @{@"type":@(2),@"nickname":self.twoNameTf.text};
            [switchNicknameArr addObject:dict];
        }else if (i +1 == 3){
            dict = @{@"type":@(3),@"nickname":self.threeNameTf.text};
            [switchNicknameArr addObject:dict];
        }else if (i +1 == 4){
            dict = @{@"type":@(4),@"nickname":self.fourNameTf.text};
            [switchNicknameArr addObject:dict];
        }
    }
    [[KDSHttpManager sharedManager] updateSwitchNickname:switchNicknameArr withUid:[KDSUserManager sharedManager].user.uid wifiModel:self.lock.wifiDevice success:^{
        [hud hideAnimated:NO];
        [MBProgressHUD showSuccess:Localized(@"saveSuccess")];
        [self.navigationController popToRootViewControllerAnimated:NO];
        UITabBarController *vc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        if ([vc isKindOfClass:UITabBarController.class] && vc.viewControllers.count)
        {
            vc.selectedIndex = 0;
        }
    } error:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
    } failure:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:[Localized(@"saveFailed") stringByAppendingString:error.localizedDescription]];
    }];
    
}

///单火开关键位昵称
-(void)textFieldTextDidChange:(UITextField *)sender
{
     [sender trimTextToLength:-1];
}

#pragma mark --Lazy load

- (NSMutableArray<NSMutableDictionary *> *)switchArray
{
    if (!_switchArray) {
        _switchArray = [NSMutableArray array];
    }
    return _switchArray;
}
- (NSMutableDictionary *)switchDict
{
    if (!_switchDict) {
        _switchDict = [[NSMutableDictionary alloc] init];
    }
    return _switchDict;
}

@end
