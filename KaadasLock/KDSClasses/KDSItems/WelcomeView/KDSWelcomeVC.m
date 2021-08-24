//
//  KDSWelcomeVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/26.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSWelcomeVC.h"
#import "KDSLoginViewController.h"
#import "AppDelegate.h"
#import "KSDWelcomePageControl.h"

#define kTitleKey      @"title"
#define kDescKey       @"desc"
#define kImageNameKey  @"imageName"

@interface KDSWelcomeVC ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSArray       *dataSource;
@property (nonatomic,strong) KSDWelcomePageControl * pageControl;
@end

@implementation KDSWelcomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    for (int i =0; i<3; i++) {
        NSDictionary *item = self.dataSource[i];
        UIView * supView = [[UIImageView alloc]initWithFrame:CGRectMake(KDSScreenWidth * i, 0, KDSScreenWidth, KDSScreenHeight)];
        supView.userInteractionEnabled = YES;
        [self.scrollView addSubview:supView];
        
        UIImageView * imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:item[kImageNameKey]];
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        [supView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(supView.mas_left).offset(20);
            make.right.mas_equalTo(supView.mas_right).offset(-20);
            make.height.mas_equalTo(imgV.mas_width).multipliedBy(0.69);
            make.top.mas_equalTo(supView.mas_top).offset(KDSSSALE_HEIGHT(160));
        }];
        
        UILabel * titlLb = [[UILabel alloc] init];
        titlLb.text = item[kTitleKey];
        titlLb.font = [UIFont fontWithName:@"Helvetica-Bold" size:KDSScreenHeight< 667?22:27];
        titlLb.textColor = KDSRGBColor(51, 51, 51);
        titlLb.textAlignment = NSTextAlignmentCenter;
        [supView addSubview:titlLb];
        [titlLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(supView.mas_left).offset(20);
            make.right.mas_equalTo(supView.mas_right).offset(-20);
            make.height.mas_equalTo(KDSSSALE_HEIGHT(26));
            make.top.mas_equalTo(imgV.mas_bottom).offset(KDSSSALE_HEIGHT(74));
        }];
        
        UILabel * descLb = [UILabel new];
        descLb.text = item[kDescKey];
        descLb.font = [UIFont systemFontOfSize:KDSSSALE_WIDTH(15)];
        descLb.textColor = KDSRGBColor(102, 102, 102);
        descLb.textAlignment = NSTextAlignmentCenter;
        descLb.numberOfLines = 0;
        [supView addSubview:descLb];
        [descLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(supView.mas_left).offset(20);
            make.right.mas_equalTo(supView.mas_right).offset(-20);
            make.top.mas_equalTo(titlLb.mas_bottom).offset(KDSSSALE_HEIGHT(18));
        }];
        UIButton * jumpBtn = [UIButton new];
        [jumpBtn setTitle:@"跳过" forState:UIControlStateNormal];
        [jumpBtn setTitleColor:KDSRGBColor(63, 196, 255) forState:UIControlStateNormal];
        jumpBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        jumpBtn.layer.borderWidth = 1;
        jumpBtn.layer.borderColor = KDSRGBColor(63, 196, 255).CGColor;
        jumpBtn.layer.masksToBounds = YES;
        jumpBtn.layer.cornerRadius = 9.8;
        [jumpBtn addTarget:self action:@selector(jumpClick:) forControlEvents:UIControlEventTouchUpInside];
        [supView addSubview:jumpBtn];
        [jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.mas_equalTo(43);
            make.height.mas_equalTo(20);
            make.right.mas_equalTo(supView.mas_right).offset(-20);
            make.top.mas_equalTo(supView.mas_top).offset(kStatusBarHeight+20);
        }];
        if (i == 2) {//第三张图上放一个“立即体验按钮”
            UIButton * expressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [expressBtn setTitle:@"立即体验" forState:UIControlStateNormal];
            [expressBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            expressBtn.backgroundColor = KDSRGBColor(76, 204, 255);
            [expressBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            expressBtn.titleLabel.font = [UIFont systemFontOfSize:16];
            [expressBtn addTarget:self action:@selector(experienceBtn:) forControlEvents:UIControlEventTouchUpInside];
            expressBtn.layer.masksToBounds = YES;
            expressBtn.layer.cornerRadius = 5;
            [supView addSubview:expressBtn];
            [expressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.width.mas_equalTo(150);
                make.height.mas_equalTo(40);
                make.centerX.mas_equalTo(supView.mas_centerX).offset(0);
                make.top.mas_equalTo(titlLb.mas_bottom).offset(KDSSSALE_HEIGHT(106));
            }];
        }
        
    }
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(KDSSSALE_HEIGHT(605));
        make.height.mas_equalTo(KDSSSALE_HEIGHT(16));
    }];
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.contentSize = CGSizeMake(KDSScreenWidth * 3, KDSScreenHeight);
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

-(void)jumpClick:(UIButton *)btn
{
//    KDSLoginViewController * login = [KDSLoginViewController new];
  AppDelegate *del =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del setRootViewController];
}

-(void)experienceBtn:(UIButton *)sender
{
    AppDelegate *del =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    [del setRootViewController];
}
#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    if (index == 2) {
       self.pageControl.hidden = YES;
    }else{
        self.pageControl.hidden = NO;
    }
    self.pageControl.currentPage = index;
}
#pragma mark -- lazy load
- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = ({
            
            NSDictionary *item1 = @{kTitleKey:@"智能解锁",kDescKey:@"指纹、卡片、密码等多重开锁，安全快捷",kImageNameKey:@"qidong1"};
            NSDictionary *item2 = @{kTitleKey:@"一键即开",kDescKey:@"指纹识别，解锁开门，一步到位",kImageNameKey:@"qidong2"};
            NSDictionary *item3 = @{kTitleKey:@"远程监控",kDescKey:@"实时了解门锁动态，守护您的家",kImageNameKey:@"qidong3"};
            NSArray *arr = @[item1,item2,item3];
            arr;
        });
    }
    return _dataSource;
}
- (KSDWelcomePageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = ({
            KSDWelcomePageControl * p = [KSDWelcomePageControl new];
            //设置点的总个数
            p.numberOfPages = 3;
            p.currentPage = 0;
            if (@available(iOS 14.0, *)) {
                p.currentPageIndicatorTintColor = KDSRGBColor(52, 196, 255);
                p.pageIndicatorTintColor = KDSRGBColor(160, 197, 212);
            } else {
                 //  向下兼容
            }
            p;
        });
    }
    return _pageControl;
}

@end
