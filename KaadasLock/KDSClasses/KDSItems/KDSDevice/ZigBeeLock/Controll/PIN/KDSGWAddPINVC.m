//
//  KDSGWAddPINVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWAddPINVC.h"
#import "KDSGWAddPINProxyVC.h"
#import "KDSGWAddPINPermanentVC.h"

@interface KDSGWAddPINVC () <UIScrollViewDelegate>

///保存顶部3个按钮的数组。
@property (nonatomic, strong) NSArray<UIButton *> *btns;
///游标。
@property (nonatomic, strong) UIView *vernierView;
///scroll view
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation KDSGWAddPINVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"addPIN");
    [self setupUI];
}

- (void)setupUI
{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    topView.backgroundColor = KDSRGBColor(0xf8, 0xf8, 0xf8);
    [self.view addSubview:topView];
    //-------新版网关锁功能：时效、周期、临时---------
    NSArray *titles;
    if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
    || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion) {
         titles = @[Localized(@"timeliness"), Localized(@"period"), Localized(@"temporary")];
    }else{
        //******老版网关锁功能:永久、临时***********
        titles = @[Localized(@"forever"),Localized(@"temporary")];
    }
    
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSString *title in titles)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x99, 0x99, 0x99) forState:UIControlStateNormal];
        [btn setTitleColor:KDSRGBColor(0x1f, 0x96, 0xf7) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        CGSize size = [title sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
        btn.bounds = (CGRect){0, 0, ceil(size.width), ceil(size.height)};
        [btn addTarget:self action:@selector(clickSubfuncBtnSelectSubfunc:) forControlEvents:UIControlEventTouchUpInside];
        [topView addSubview:btn];
        [btns addObject:btn];
    }
    self.btns = btns.copy;
    if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
    || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion) {
        
        [self.btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(topView.mas_left).offset(51 * kScreenWidth / 375.0 + self.btns[0].bounds.size.width / 2);
            make.centerY.equalTo(@0);
        }];
        [self.btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(@0);
        }];
        [self.btns[2] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(topView.mas_right).offset(-51 * kScreenWidth / 375.0 - self.btns[2].bounds.size.width / 2);
            make.centerY.equalTo(@0);
        }];
        
    }else{
        
        [self.btns[0] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.centerX.equalTo(topView.mas_left).offset(51 * kScreenWidth / 375.0 + self.btns[0].bounds.size.width / 2);
        }];
        [self.btns[1] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0);
            make.centerX.equalTo(topView.mas_right).offset(-51 * kScreenWidth / 375.0 - self.btns[1].bounds.size.width / 2);
        }];
    }
    self.vernierView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 2)];
    self.vernierView.center = CGPointMake(51 * kScreenWidth / 375.0 + self.btns.firstObject.bounds.size.width / 2, 44 - 7.5);
    self.vernierView.backgroundColor = KDSRGBColor(0x1f, 0x96, 0xf7);
    [topView addSubview:self.vernierView];
    
    CGFloat height = kScreenHeight - kStatusBarHeight - kNavBarHeight - topView.bounds.size.height;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), kScreenWidth, height)];
    self.scrollView.bounces = NO;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(kScreenWidth * titles.count, height);
    [self.view addSubview:self.scrollView];
  
    if (([[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100Z"] == NSOrderedSame
    || [[self.lock.gwDevice.lockversion componentsSeparatedByString:@";"][0] caseInsensitiveCompare:@"8100A"] == NSOrderedSame) && self.lock.gwDevice.lockversion) {
        // 网关锁新功能
        KDSGWAddPINProxyVC *vc1 = [KDSGWAddPINProxyVC new];
        [self addChildViewController:vc1];
        vc1.view.frame = CGRectMake(0, 0, kScreenWidth, height);
        vc1.keyType = self.keyType;
        vc1.lock = self.lock;//时效
        [self.scrollView addSubview:vc1.view];
        
        KDSGWAddPINProxyVC *vc2 = [KDSGWAddPINProxyVC new];
        vc2.type = 1;//周期
        vc2.keyType = self.keyType;
        vc2.lock = self.lock;
        [self addChildViewController:vc2];
        vc2.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, height);
        [self.scrollView addSubview:vc2.view];
        
        KDSGWAddPINProxyVC *vc3 = [KDSGWAddPINProxyVC new];
        vc3.type = 2;//临时
        vc3.keyType = self.keyType;
        vc3.lock = self.lock;
        [self addChildViewController:vc3];
        vc3.view.frame = CGRectMake(kScreenWidth * 2, 0, kScreenWidth, height);
        [self.scrollView addSubview:vc3.view];
        
    }else{
         ////网关锁老版功能实现
        KDSGWAddPINPermanentVC * vc1 = [KDSGWAddPINPermanentVC new];
        vc1.type = 0;///永久
        vc1.keyType = self.keyType;
        vc1.lock = self.lock;
        [self addChildViewController:vc1];
        vc1.view.frame = CGRectMake(0, 0, kScreenWidth, height);
        [self.scrollView addSubview:vc1.view];
    
        KDSGWAddPINPermanentVC *vc2 = [KDSGWAddPINPermanentVC new];
        vc2.type = 2;///临时
        vc2.keyType = self.keyType;
        vc2.lock = self.lock;
        [self addChildViewController:vc2];
        vc2.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, height);
        [self.scrollView addSubview:vc2.view];
        
    }
    
    [self clickSubfuncBtnSelectSubfunc:self.btns.firstObject];
}

#pragma mark - 控件等事件方法。
///点击顶部的子功能按钮切换子功能。
- (void)clickSubfuncBtnSelectSubfunc:(UIButton *)sender
{
    for (UIButton *btn in self.btns)
    {
        if (btn.selected && btn == sender) return;
        btn.selected = NO;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    sender.selected = YES;
    sender.titleLabel.font = [UIFont systemFontOfSize:17];
    if (sender.center.x != 0)
    {
        [self.scrollView setContentOffset:CGPointMake(kScreenWidth * [self.btns indexOfObject:sender], 0) animated:YES];
        [UIView animateWithDuration:0.15 animations:^{
            self.vernierView.center = CGPointMake(sender.center.x, self.vernierView.center.y);
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self clickSubfuncBtnSelectSubfunc:self.btns[index]];
}

@end
