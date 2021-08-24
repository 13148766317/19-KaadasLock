//
//  KDSSearchSwithVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSearchSwithVC.h"
#import "KDSMQTTManager+SmartHome.h"
#import "KDSAddSwitchSuccessVC.h"
#import "KDSAddSwitchFailVC.h"

@interface KDSSearchSwithVC ()

@property (nonatomic,strong)UIImageView * img;
@property (nonatomic,strong)CABasicAnimation * rotateAnimation;

@end

@implementation KDSSearchSwithVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = @"搜索设备";
    [self setUI];
    [self startImgRotatingWidthImg:self.img];
    
    [[KDSMQTTManager sharedManager] addSwitchWithWf:self.lock.wifiDevice completion:^(NSError * _Nullable error, BOOL success, NSInteger typeValue, NSString * _Nonnull macaddr, NSTimeInterval switchBindTime) {
        if (success) {
            KDSAddSwitchSuccessVC * vc = [KDSAddSwitchSuccessVC new];
            vc.switchType = typeValue;
            vc.lock = self.lock;
            vc.macaddr = macaddr;
            vc.switchBindTime = switchBindTime;
           [self.navigationController pushViewController:vc animated:YES];

        }else{
            KDSAddSwitchFailVC * vc = [KDSAddSwitchFailVC new];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

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
    UILabel * lb = [UILabel new];
    lb.text = @"正在搜索附近的智能开关";
    lb.textColor = KDSRGBColor(125, 125, 125);
    lb.textAlignment = NSTextAlignmentCenter;
    lb.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(35);
        make.height.equalTo(@20);
        make.centerX.equalTo(self.view);
    }];
    
    self.img = [UIImageView new];
    self.img.image = [UIImage imageNamed:@"searchBluToothImg"];
    [self.view addSubview:self.img];
    [self.img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lb.mas_bottom).offset(50);
        make.width.height.equalTo(@280);
        make.centerX.equalTo(self.view);
    }];
    
}

// 开始旋转
- (void)startImgRotatingWidthImg:(UIImageView *)imgView {
    self.rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    self.rotateAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    self.rotateAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    self.rotateAnimation.duration = 1.0;
    self.rotateAnimation.repeatCount = MAXFLOAT;
    [imgView.layer addAnimation:self.rotateAnimation forKey:nil];
}
// 停止旋转
- (void)stopImgRotatingWidthImg:(UIImageView *)imgView
{
    CFTimeInterval pausedTime = [imgView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    imgView.layer.speed = 0.0;
    imgView.layer.timeOffset = pausedTime;
    self.rotateAnimation.removedOnCompletion = NO;
    self.rotateAnimation.fillMode = kCAFillModeRemoved;
}
-(void)dealloc
{
    [self stopImgRotatingWidthImg:self.img];
}

@end
