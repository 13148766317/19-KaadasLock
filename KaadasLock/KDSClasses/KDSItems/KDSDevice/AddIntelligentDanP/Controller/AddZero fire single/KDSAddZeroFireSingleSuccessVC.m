//
//  KDSAddZeroFireSingleSuccessVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/17.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddZeroFireSingleSuccessVC.h"
#import "UIButton+Color.h"
#import "UIView+Extension.h"
#import "KDSHomeRoutersVC.h"



@interface KDSAddZeroFireSingleSuccessVC ()

///设备昵称
@property (nonatomic,strong)UITextField * nameTf;
///房间位置昵称
@property (nonatomic,strong)UITextField * positionNameTf;
///当前选择的设备昵称
@property (nonatomic,strong)UIButton * selectedBtn;
///当前选择的房间位置昵称
@property (nonatomic,strong)UIButton * roomSelectedBtn;


@end

@implementation KDSAddZeroFireSingleSuccessVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"addSuccess");
    [self setUI];
}


-(void)setUI{
    
    UIImageView * iconImg = [UIImageView new];
    iconImg.image = [UIImage imageNamed:@""];
    iconImg.backgroundColor = UIColor.yellowColor;
    [self.view addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(55);
        make.width.equalTo(@65);
        make.height.equalTo(@45);
        make.centerX.equalTo(self.view);
    }];
    
    UILabel * tipsLb2 = [UILabel new];
    tipsLb2.text = @"您已添加成功，取个名字吧！";
    tipsLb2.textColor = KDSRGBColor(153, 153, 153);
    tipsLb2.textAlignment = NSTextAlignmentCenter;
    tipsLb2.font = [UIFont systemFontOfSize:15];
    tipsLb2.numberOfLines = 0;
    [self.view addSubview:tipsLb2];
    [tipsLb2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(iconImg.mas_bottom).offset(20);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];

    UIView * inPutNameView = [UIView new];
    inPutNameView.backgroundColor = UIColor.whiteColor;
    inPutNameView.layer.masksToBounds = YES;
    inPutNameView.layer.cornerRadius = 4;
    [self.view addSubview:inPutNameView];
    [inPutNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.equalTo(@50);
        make.top.mas_equalTo(tipsLb2.mas_bottom).offset(30);
    }];
    
    UIImageView * tipsImg = [UIImageView new];
    tipsImg.image = [UIImage imageNamed:@"账号Hight"];
    [inPutNameView addSubview:tipsImg];
    [tipsImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@15.5);
        make.height.equalTo(@18);
        make.centerY.mas_equalTo(inPutNameView.mas_centerY).offset(0);
        make.left.mas_equalTo(inPutNameView.mas_left).offset(15);
        
    }];
    UIImageView * editImg = [UIImageView new];
    editImg.image = [UIImage imageNamed:@"edit"];
    [inPutNameView addSubview:editImg];
    [editImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(inPutNameView.mas_centerY).offset(0);
        make.right.mas_equalTo(inPutNameView.mas_right).offset(-15);
        
    }];
    
    _nameTf= [UITextField new];
    _nameTf.placeholder = @"手动输入或从下面已有名称选择";
    _nameTf.textColor = UIColor.blackColor;
    _nameTf.font = [UIFont systemFontOfSize:15];
    _nameTf.textAlignment = NSTextAlignmentLeft;
    _nameTf.borderStyle=UITextBorderStyleNone;
    [_nameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [inPutNameView addSubview:_nameTf];
    [_nameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsImg.mas_right).offset(10);
        make.right.mas_equalTo(inPutNameView.mas_right).offset(-10);
        make.top.bottom.mas_equalTo(0);
       
    }];
    
    UIButton * myHomeBtn = [UIButton new];
    [myHomeBtn setTitle:@"我的家" forState:UIControlStateNormal];
    [myHomeBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [myHomeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [myHomeBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [myHomeBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    myHomeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.selectedBtn = myHomeBtn;
    myHomeBtn.layer.masksToBounds = YES;
    myHomeBtn.layer.cornerRadius = 15;
    [myHomeBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myHomeBtn];
    [myHomeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@62);
        make.height.equalTo(@30);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        
    }];
    UIButton * bedroomBtn = [UIButton new];
    [bedroomBtn setTitle:@"卧室" forState:UIControlStateNormal];
    [bedroomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [bedroomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [bedroomBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [bedroomBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    bedroomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    bedroomBtn.layer.masksToBounds = YES;
    bedroomBtn.layer.cornerRadius = 15;
    [bedroomBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bedroomBtn];
    [bedroomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(myHomeBtn.mas_right).offset(10);
        
    }];
    UIButton * companyBtn = [UIButton new];
    [companyBtn setTitle:@"公司" forState:UIControlStateNormal];
    [companyBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [companyBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [companyBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [companyBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    companyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    companyBtn.layer.masksToBounds = YES;
    companyBtn.layer.cornerRadius = 15;
    [companyBtn addTarget:self action:@selector(selectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:companyBtn];
    [companyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(bedroomBtn.mas_right).offset(10);
        
    }];
    
    
    UIView * inPutPositionNameView = [UIView new];
    inPutPositionNameView.backgroundColor = UIColor.whiteColor;
    inPutPositionNameView.layer.masksToBounds = YES;
    inPutPositionNameView.layer.cornerRadius = 4;
    [self.view addSubview:inPutPositionNameView];
    [inPutPositionNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.height.equalTo(@50);
        make.top.mas_equalTo(inPutNameView.mas_bottom).offset(72);
    }];
    UIImageView * tipsImg1 = [UIImageView new];
    tipsImg1.image = [UIImage imageNamed:@"roomIconImg"];
    [inPutPositionNameView addSubview:tipsImg1];
    [tipsImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@25);
        make.height.equalTo(@25);
        make.centerY.mas_equalTo(inPutPositionNameView.mas_centerY).offset(0);
        make.left.mas_equalTo(inPutPositionNameView.mas_left).offset(10);
        
    }];
    UIImageView * editImg1 = [UIImageView new];
    editImg1.image = [UIImage imageNamed:@"edit"];
    [inPutPositionNameView addSubview:editImg1];
    [editImg1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@22.5);
        make.height.equalTo(@21.5);
        make.centerY.mas_equalTo(inPutPositionNameView.mas_centerY).offset(0);
        make.right.mas_equalTo(inPutPositionNameView.mas_right).offset(-15);
        
    }];
    
    _positionNameTf= [UITextField new];
    _positionNameTf.placeholder = @"添加房间名称";
    _positionNameTf.textColor = UIColor.blackColor;
    _positionNameTf.font = [UIFont systemFontOfSize:15];
    _positionNameTf.textAlignment = NSTextAlignmentLeft;
    _positionNameTf.borderStyle=UITextBorderStyleNone;
    [_positionNameTf addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [inPutPositionNameView addSubview:_positionNameTf];
    [_positionNameTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(tipsImg1.mas_right).offset(10);
        make.right.mas_equalTo(inPutPositionNameView.mas_right).offset(-10);
        make.top.bottom.mas_equalTo(0);
       
    }];
    UIButton * aLivingRoomBtn = [UIButton new];
    [aLivingRoomBtn setTitle:@"客厅" forState:UIControlStateNormal];
    [aLivingRoomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [aLivingRoomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [aLivingRoomBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [aLivingRoomBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    aLivingRoomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    self.roomSelectedBtn = aLivingRoomBtn;
    aLivingRoomBtn.layer.masksToBounds = YES;
    aLivingRoomBtn.layer.cornerRadius = 15;
    [aLivingRoomBtn addTarget:self action:@selector(roomSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aLivingRoomBtn];
    [aLivingRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutPositionNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        
    }];
    UIButton * masterBedroomBtn = [UIButton new];
    [masterBedroomBtn setTitle:@"主卧" forState:UIControlStateNormal];
    [masterBedroomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [masterBedroomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [masterBedroomBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [masterBedroomBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    masterBedroomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    masterBedroomBtn.layer.masksToBounds = YES;
    masterBedroomBtn.layer.cornerRadius = 15;
    [masterBedroomBtn addTarget:self action:@selector(roomSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:masterBedroomBtn];
    [masterBedroomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutPositionNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(aLivingRoomBtn.mas_right).offset(10);
        
    }];
    UIButton * supinePositionBtn = [UIButton new];
    [supinePositionBtn setTitle:@"次卧" forState:UIControlStateNormal];
    [supinePositionBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [supinePositionBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [supinePositionBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [supinePositionBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    supinePositionBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    supinePositionBtn.layer.masksToBounds = YES;
    supinePositionBtn.layer.cornerRadius = 15;
    [supinePositionBtn addTarget:self action:@selector(roomSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:supinePositionBtn];
    [supinePositionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutPositionNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(masterBedroomBtn.mas_right).offset(10);
        
    }];

    UIButton * studyRoomBtn = [UIButton new];
    [studyRoomBtn setTitle:@"书房" forState:UIControlStateNormal];
    [studyRoomBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    [studyRoomBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
    [studyRoomBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateNormal];
    [studyRoomBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    studyRoomBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    studyRoomBtn.layer.masksToBounds = YES;
    studyRoomBtn.layer.cornerRadius = 15;
    [studyRoomBtn addTarget:self action:@selector(roomSelectedClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:studyRoomBtn];
    [studyRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(inPutPositionNameView.mas_bottom).offset(10);
        make.width.equalTo(@50);
        make.height.equalTo(@30);
        make.left.mas_equalTo(supinePositionBtn.mas_right).offset(10);
        
    }];
    
    
    UIView *routerProtocolView = [UIView new];
    routerProtocolView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(supportedHomeRoutersClickTap:)];
    [routerProtocolView addGestureRecognizer:tap];
    [self.view addSubview:routerProtocolView];
    [routerProtocolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
        make.left.right.equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(28));
    }];
    
    UILabel * routerProtocolLb = [UILabel new];
    routerProtocolLb.text = @"查看门锁Wi-Fi支持家庭路由器";
    routerProtocolLb.textColor = KDSRGBColor(31, 150, 247);
    routerProtocolLb.textAlignment = NSTextAlignmentCenter;
    routerProtocolLb.font = [UIFont systemFontOfSize:14];
    [routerProtocolView addSubview:routerProtocolLb];
    NSRange strRange = {0,[routerProtocolLb.text length]};
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:routerProtocolLb.text];
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    routerProtocolLb.attributedText = str;
    [routerProtocolLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(routerProtocolView);
    }];
    
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.cornerRadius = 22;
    nextBtn.layer.masksToBounds = YES;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(routerProtocolView.mas_top).offset(-25);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@200);
        make.height.equalTo(@44);
    }];
}

#pragma mark 点击事件
-(void)selectedClick:(UIButton *)sender
{
    if (sender!= self.selectedBtn)
    {
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
    }else{
        self.selectedBtn.selected = YES;
    }
    self.nameTf.text = sender.titleLabel.text;
    
}
-(void)roomSelectedClick:(UIButton *)sender
{
    if (sender!= self.roomSelectedBtn)
    {
        self.roomSelectedBtn.selected = NO;
        sender.selected = YES;
        self.roomSelectedBtn = sender;
    }else{
        self.roomSelectedBtn.selected = YES;
    }
    self.positionNameTf.text = sender.titleLabel.text;
}

///锁昵称文本框文字改变后，限制长度不超过16个字符。
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}

-(void)supportedHomeRoutersClickTap:(UITapGestureRecognizer *)sender
{
    KDSHomeRoutersVC * VC = [KDSHomeRoutersVC new];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)nextBtnClick:(UIButton *)sender
{
    NSLog(@"完成的时候设备昵称：%@,设备所在位置：%@",self.nameTf.text,self.positionNameTf.text);
}

@end
