//
//  KDSAddPINVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAddPINVC.h"
#import "Masonry.h"
#import "KDSAddPINProxyVC.h"

@interface KDSAddPINVC () <UIScrollViewDelegate>

///保存顶部3个按钮的数组。
@property (nonatomic, strong) NSArray<UIButton *> *btns;
///游标。
@property (nonatomic, strong) UIView *vernierView;
///scroll view
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation KDSAddPINVC

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
    
    NSArray *titles = @[Localized(@"timeliness"), Localized(@"period"), Localized(@"temporary")];
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
    
    //时效
    KDSAddPINProxyVC *vc1 = [KDSAddPINProxyVC new];
    [self addChildViewController:vc1];
    vc1.view.frame = CGRectMake(0, 0, kScreenWidth, height);
    vc1.lock = self.lock;
    vc1.isSupport20setsPasswords = self.isSupport20setsPasswords;
    [self.scrollView addSubview:vc1.view];
    //周期
    KDSAddPINProxyVC *vc2 = [KDSAddPINProxyVC new];
    vc2.type = 1;
    vc2.lock = self.lock;
    vc2.isSupport20setsPasswords = self.isSupport20setsPasswords;
    [self addChildViewController:vc2];
    vc2.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, height);
    [self.scrollView addSubview:vc2.view];
    //临时
    KDSAddPINProxyVC *vc3 = [KDSAddPINProxyVC new];
    vc3.type = 2;
    vc3.lock = self.lock;
    vc3.isSupport20setsPasswords = self.isSupport20setsPasswords;
    [self addChildViewController:vc3];
    vc3.view.frame = CGRectMake(kScreenWidth * 2, 0, kScreenWidth, height);
    [self.scrollView addSubview:vc3.view];
    
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
