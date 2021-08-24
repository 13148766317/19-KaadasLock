//
//  KDSIntelligentDanpVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/1/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSIntelligentDanpVC.h"
#import "KDSIntelligentDetailVC.h"
#import "KDSIntelligentDanpTimingVC.h"

@interface KDSIntelligentDanpVC ()<UINavigationControllerDelegate>

///导航栏位置的标题标签。
@property (nonatomic, weak) UILabel *titleLabel;
///锁型号标签。
@property (nonatomic, weak) UILabel *modelLabel;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;

@end

@implementation KDSIntelligentDanpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

- (void)setupUI
{
    UIImageView *bgIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topBgImgIcon"]];
    [self.view addSubview:bgIV];
    [bgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(KDSScreenHeight - 170));
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"whiteBack"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *seeMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [seeMoreBtn setImage:[UIImage imageNamed:@"seeMoreWither"] forState:UIControlStateNormal];
    seeMoreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    seeMoreBtn.frame = CGRectMake(KDSScreenWidth-54, kStatusBarHeight, 44, 44);
    [seeMoreBtn addTarget:self action:@selector(seeMoreBtnBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:seeMoreBtn];
    
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = UIColor.whiteColor;
    titleLabel.text = @"智能设备详情";// self.lock.device.lockNickName;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwitchLampImg"]];
    [self.view insertSubview:lockIV belowSubview:titleLabel];
    [lockIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bgIV);
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(kScreenHeight<=667 ? 200 : 236));
    }];
    
    UILabel *modelLabel = [UILabel new];
    modelLabel.font = [UIFont systemFontOfSize:13];
    modelLabel.textColor = UIColor.whiteColor;
    modelLabel.text = @"电源开关智能灯";//self.lock.device.lockNickName;
    modelLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:modelLabel];
    [modelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bgIV.mas_bottom).offset(-26);
        make.centerX.equalTo(self.view);
        make.left.mas_equalTo(self.view.mas_left).offset(10);
        make.right.mas_equalTo(self.view.mas_right).offset(-10);
    }];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgIV.mas_bottom).offset(0);
        make.left.bottom.right.equalTo(self.view);
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.backgroundColor = UIColor.whiteColor;
    cornerView.layer.cornerRadius = 4;
    cornerView.clipsToBounds = YES;
    [grayView addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(grayView).offset(16);
        make.left.equalTo(grayView).offset(15);
        make.right.equalTo(grayView).offset(-15);
        make.height.equalTo(@130);
    }];
    
    UIView *timingView = [self createSubfuncViewWithImageName:@"timing" subfunc:Localized(@"timing") quantity:@"" tapAction:@selector(tapTimingSubfuncViewAction:)];
    [cornerView addSubview:timingView];
    [timingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(cornerView);
        make.size.mas_equalTo(timingView.bounds.size);
    }];
    
    UIView *vLineView1 = [UIView new];
    vLineView1.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [cornerView addSubview:vLineView1];
    [vLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(timingView.mas_right);
        make.top.bottom.equalTo(cornerView);
        make.width.equalTo(@1);
    }];
    
    UIView *shareView = [self createSubfuncViewWithImageName:@"memberShare" subfunc:Localized(@"deviceShare") quantity:@"" tapAction:@selector(tapDeviceShareSubfuncViewAction:)];
    [cornerView addSubview:shareView];
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView);
        make.left.equalTo(vLineView1.mas_right);
        make.size.mas_equalTo(shareView.bounds.size);
    }];
}

///创建子功能视图。
- (UIView *)createSubfuncViewWithImageName:(NSString *)name subfunc:(NSString *)title quantity:(NSString *)quantity tapAction:(SEL)action
{
    CGFloat height = 130;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (kScreenWidth - 32) / 2.0, height)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:tap];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:iv];
    [iv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(view.mas_centerY);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@30);
    }];
    
    UILabel *subfuncLabel = [UILabel new];
    subfuncLabel.text = title;
    subfuncLabel.font = [UIFont systemFontOfSize:13];
    subfuncLabel.textAlignment = NSTextAlignmentCenter;
    subfuncLabel.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    [view addSubview:subfuncLabel];
    [subfuncLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_centerY).offset(14);
        make.centerX.equalTo(@0);
    }];
    return view;
}

#pragma mark - 控件等事件方法。
///点击返回按钮。
- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
///点击定时子视图。
- (void)tapTimingSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    KDSIntelligentDanpTimingVC * vc = [KDSIntelligentDanpTimingVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

///点击设备共享子视图。
-(void)tapDeviceShareSubfuncViewAction:(UITapGestureRecognizer *)sender
{
    
}
///设备详情
-(void)seeMoreBtnBtnAction:(UIButton *)sender
{
    KDSIntelligentDetailVC * vc = [KDSIntelligentDetailVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];//!iOS 9
}

@end
