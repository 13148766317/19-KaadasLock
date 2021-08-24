//
//  KDSWeekPickerVC.m
//  KaadasLock
//
//  Created by orange on 2019/4/3.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSWeekPickerVC.h"
#import "Masonry.h"
@interface KDSWeekPickerVC ()

///8个按钮。
@property (nonatomic, strong) NSArray<UIButton *> *buttons;
///记录初始mask，如果8个按钮一个都没有选中，那么返回初始mask。
@property (nonatomic, assign) char initialMask;

@end

@implementation KDSWeekPickerVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //  类和类之间值得传递是  使用的属性传值  和 block 传值  向上传值是使用的是block 回调  向下传值使用的是 属性传值
    
    self.navigationTitleLabel.text = Localized(@"weekDuplicate");
    self.initialMask = self.mask;  // 根据传递过来的mask 进行视图的创建
    //  一共有8个按钮
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:8];
    // 每一天的按钮
    UIView *dayView = [self createViewWithTitle:Localized(@"everyday") isSelected:self.mask == 0x7f containLine:NO];
   //  dayView.tag =0;  默认值是0
    [btns addObject:[dayView viewWithTag:1000]];
    [self.view addSubview:dayView];
    
    UIView *sunView = [self createViewWithTitle:Localized(@"everySunday") isSelected:self.mask & 0x1 containLine:YES];
    sunView.tag = 1;
    [btns addObject:[sunView viewWithTag:1000]];
    CGRect frame = sunView.frame;
    frame.origin.y += CGRectGetMaxY(dayView.frame) + 10;
    sunView.frame = frame;
    [self.view addSubview:sunView];
    
    UIView *monView = [self createViewWithTitle:Localized(@"everyMonday") isSelected:self.mask & 0x2 containLine:YES];
    monView.tag = 2;
    [btns addObject:[monView viewWithTag:1000]];
    frame = monView.frame;
    frame.origin.y += CGRectGetMaxY(sunView.frame);
    monView.frame = frame;
    [self.view addSubview:monView];

    UIView *tueView = [self createViewWithTitle:Localized(@"everyTue") isSelected:self.mask & 0x4 containLine:YES];
    tueView.tag = 3;
    [btns addObject:[tueView viewWithTag:1000]];
    frame = tueView.frame;
    frame.origin.y += CGRectGetMaxY(monView.frame);
    tueView.frame = frame;
    [self.view addSubview:tueView];
    
    UIView *wedView = [self createViewWithTitle:Localized(@"everyWed") isSelected:self.mask & 0x8 containLine:YES];
    wedView.tag = 4;
    [btns addObject:[wedView viewWithTag:1000]];
    frame = wedView.frame;
    frame.origin.y += CGRectGetMaxY(tueView.frame);
    wedView.frame = frame;
    [self.view addSubview:wedView];
    
    UIView *thuView = [self createViewWithTitle:Localized(@"everyThu") isSelected:self.mask & 0x10 containLine:YES];
    thuView.tag = 5;
    [btns addObject:[thuView viewWithTag:1000]];
    frame = thuView.frame;
    frame.origin.y += CGRectGetMaxY(wedView.frame);
    thuView.frame = frame;
    [self.view addSubview:thuView];
    
    UIView *friView = [self createViewWithTitle:Localized(@"everyFri") isSelected:self.mask & 0x20 containLine:YES];
    friView.tag = 6;
    [btns addObject:[friView viewWithTag:1000]];
    frame = friView.frame;
    frame.origin.y += CGRectGetMaxY(thuView.frame);
    friView.frame = frame;
    [self.view addSubview:friView];
    
    UIView *satView = [self createViewWithTitle:Localized(@"everySat") isSelected:self.mask & 0x40 containLine:NO];
    satView.tag = 7;
    [btns addObject:[satView viewWithTag:1000]];
    frame = satView.frame;
    frame.origin.y += CGRectGetMaxY(friView.frame);
    satView.frame = frame;
    [self.view addSubview:satView];
    
    self.buttons = btns.copy;
}
//  视图即将消失

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    NSLog(@"zhu-xx  -viewWillDisappear设置的mask的值 ==%c",self.mask);
    
}
- (void)dealloc  //   视图销毁的时候设置值
{
    !self.didSelectWeekBlock ?: self.didSelectWeekBlock(self.mask==0 ? self.initialMask : self.mask);
}

- (UIView *)createViewWithTitle:(NSString *)title isSelected:(BOOL)isSelected containLine:(BOOL)contain
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
    view.backgroundColor = UIColor.whiteColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSelectWeekDay:)];
    [view addGestureRecognizer:tap];
    
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = KDSRGBColor(0x33, 0x33, 0x33);
    label.font = [UIFont systemFontOfSize:13];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view);
        make.left.equalTo(view).offset(17);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 1000;
    [btn setImage:[UIImage imageNamed:@"未选择"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"选择"] forState:UIControlStateSelected];
    btn.selected = isSelected;
    [btn addTarget:self action:@selector(tapBtnToSelectWeekDay:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-16);
        make.centerY.equalTo(@0);
        make.width.height.equalTo(@17);
    }];
    
    if (contain)
    {
        UIView *line = [UIView new];
        line.backgroundColor = KDSRGBColor(0xea, 0xe9, 0xe9);
        [view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.bottom.right.equalTo(view);
            make.height.equalTo(@1);
        }];
    }
    return view;
}
///点击手势选择/取消选择日期。
- (void)tapToSelectWeekDay:(UITapGestureRecognizer *)sender
{
    UIButton *btn = self.buttons[sender.view.tag];
    if (sender.view.tag == 0)  // 每天
    {
        for (UIButton *btn_ in self.buttons)
        {
            btn_.selected = btn.selected = NO;
        }
        self.mask = btn.selected ? 0x7f : 0;
        // 保持当前按钮选中
        btn.selected = YES;
    }
    else
    {
        if (btn.selected) // 按钮选中和没有选中时 mask 的 值
        {
            char op[] = {0x7f, 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40};
            
            self.mask |= op[sender.view.tag];
        }
        else
        {
            char op[] = {0x00, 0xfe, 0xfd, 0xfb, 0xf7, 0xef, 0xdf, 0xbf};
            self.mask &= op[sender.view.tag];
        }
        // 设置每天的值
        self.buttons.firstObject.selected = (self.mask == 0x7f);

        // 按钮取反
        btn.selected = !btn.selected;
    }
}

///点击按钮选择/取消选择日期。
- (void)tapBtnToSelectWeekDay:(UIButton *)sender
{
    [self tapToSelectWeekDay:sender.superview.gestureRecognizers.firstObject];
}

@end
