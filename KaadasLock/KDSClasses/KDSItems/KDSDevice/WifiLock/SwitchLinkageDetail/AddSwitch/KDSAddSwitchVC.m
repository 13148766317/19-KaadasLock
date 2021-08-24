//
//  KDSAddSwitchVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddSwitchVC.h"
#import "KDSAddSwitchStep2VC.h"
#import "KDSMQTTManager+SmartHome.h"

@interface KDSAddSwitchVC ()

@property (nonatomic,strong)UIImageView * addSwitchImgView;

@end

@implementation KDSAddSwitchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"添加开关";
    [self setUI];
    [self startAnimation4Connection];
}

-(void)setUI
{
    UIView * supView = [UIView new];
     supView.backgroundColor = UIColor.whiteColor;
     [self.view addSubview:supView];
     [supView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.bottom.equalTo(self.view);
         make.top.equalTo(self.view.mas_top).offset(3);
     }];
     
     ///第一步
     UILabel * tipMsgLabe1 = [UILabel new];
     tipMsgLabe1.text = @"开关配网";
     tipMsgLabe1.font = [UIFont systemFontOfSize:18];
     tipMsgLabe1.textColor = UIColor.blackColor;
     tipMsgLabe1.textAlignment = NSTextAlignmentLeft;
     [self.view addSubview:tipMsgLabe1];
     [tipMsgLabe1 mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(self.view.mas_top).offset(KDSScreenHeight > 667 ? 51 : 20);
         make.height.mas_equalTo(20);
         make.left.mas_equalTo(self.view.mas_left).offset(30);
         make.right.mas_equalTo(self.view.mas_right).offset(-10);
     }];
    
     UILabel *tipMsgLabe = [self createLabelWithText:@"① 开启电源总闸，按下开关面板按键，可正常 控制灯光，表示开关工作正常" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth-60];
     tipMsgLabe.textAlignment = NSTextAlignmentLeft;
    [self setLabelSpace:tipMsgLabe withSpace:5 withFont:[UIFont systemFontOfSize:14]];
    [self.view addSubview:tipMsgLabe];
    [tipMsgLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipMsgLabe1.mas_bottom).offset(KDSScreenHeight < 667 ? 20 : 35);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
    }];
    UILabel *tipMsg1Labe = [self createLabelWithText:@"② 长按开关任意按键5s以上，红色LED 快闪，表示开关已进入配网模式" color:KDSRGBColor(102, 102, 102) font:[UIFont systemFontOfSize:14] width:kScreenWidth-60];
     tipMsg1Labe.textAlignment = NSTextAlignmentLeft;
     [self setLabelSpace:tipMsg1Labe withSpace:5 withFont:[UIFont systemFontOfSize:14]];
     [self.view addSubview:tipMsg1Labe];
     [tipMsg1Labe mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(tipMsgLabe.mas_bottom).offset(5);
         make.left.mas_equalTo(self.view.mas_left).offset(30);
         make.right.mas_equalTo(self.view.mas_right).offset(-30);
     }];
     
     ///添加门锁的logo
     self.addSwitchImgView = [UIImageView new];
     self.addSwitchImgView.image = [UIImage imageNamed:@"addSwithImg1.png"];
     [self.view addSubview:self.addSwitchImgView];
     [self.addSwitchImgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(tipMsg1Labe.mas_bottom).offset(KDSScreenHeight < 667 ? 30 : 65);
         make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
         make.height.equalTo(@235);
         make.width.equalTo(@163);
         
     }];
     
    UIButton * nextBtn = [UIButton new];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.backgroundColor = KDSRGBColor(31, 150, 247);
    nextBtn.layer.masksToBounds = YES;
    nextBtn.layer.cornerRadius = 20;
    [self.view addSubview:nextBtn];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@200);
        make.height.equalTo(@44);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(KDSScreenHeight <= 667 ? -45 : -65);
    }];
}

- (UILabel *)createLabelWithText:(NSString *)text color:(nullable UIColor *)color font:(nullable UIFont *)font width:(CGFloat)width
{
    color = color ?: KDSRGBColor(0x33, 0x33, 0x33);
    font = font ?: [UIFont systemFontOfSize:13];
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.text = text;
    label.textColor = color;
    label.font = font;
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    label.bounds = CGRectMake(0, 0, width, ceil(size.height));
    return label;
}

-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

//NSArray *_arrayImages4Connecting; 几张图片按顺序切换
- (void)startAnimation4Connection {
    NSArray * _arrayImages4Connecting = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"addSwithImg1.png"],
                                         [UIImage imageNamed:@"addSwithImg2.png"],
                                         nil];
    [self.addSwitchImgView setAnimationImages:_arrayImages4Connecting];
    [self.addSwitchImgView setAnimationRepeatCount:0];
    [self.addSwitchImgView setAnimationDuration:2.0f];
    [self.addSwitchImgView startAnimating];

}

//停止删除
-(void)imgAnimationStop{
    [self.addSwitchImgView.layer removeAllAnimations];
}

-(void)dealloc
{
    [self imgAnimationStop];
}

#pragma mark 点击事件
-(void)nextBtnClick:(UIButton *)btn
{
    KDSAddSwitchStep2VC * vc = [KDSAddSwitchStep2VC new];
    vc.lock = self.lock;
    vc.actionSting = @"AddSwitch";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
