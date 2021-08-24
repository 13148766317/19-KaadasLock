//
//  KDSNightVisionVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/9/2.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSNightVisionVC.h"
#import "UIButton+Color.h"
#import "KDSCateyeMoreCell.h"
#import "KDSMQTTManager+CY.h"
#import "MBProgressHUD+MJ.h"

#define ZQWindow [UIApplication sharedApplication].keyWindow

@interface KDSNightVisionVC ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

///手动按钮。
@property (nonatomic, strong) UIButton * manualBtn;
///自动按钮。
@property (nonatomic, strong) UIButton * automaticBtn;
///横向滚动的滚动视图，装着手动设置条件和自动设置表视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///显示手动设置内容的表视图。
@property (nonatomic, strong) UITableView *ManualTableView;
///显示自动设置内容的表视图。
@property (nonatomic, strong) UITableView *AutomaticTableView;
///数据源
@property(nonatomic,strong)NSMutableArray * manualDataSourceArr;
@property(nonatomic,strong)NSMutableArray * automaticDataSourceArr;
///当前手动选中
@property(nonatomic,assign)NSUInteger currentManuakIndex;
///当前自动选中
@property(nonatomic,assign)NSUInteger currentAutomaticIndex;
///手动选中的事项
@property(nonatomic,assign)NSNumber* selectManuakRingNum;
///自动选中的事项
@property(nonatomic,assign)NSNumber* selectAutomaticRingNum;
///猫眼夜视模式高:70-120、中:50-100、低:20-70
@property(nonatomic,strong)NSString * nightVisionStr;
///白天黑夜
@property(nonatomic,strong)NSString * dayAndNight;
///取消按钮
@property(nonatomic,strong)UIButton * cancelBtn;
///确定按钮
@property(nonatomic,strong)UIButton * okBtn;

@end

@implementation KDSNightVisionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.navigationTitleLabel.text =@"夜视功能";
    [self setupUI];
    _automaticDataSourceArr = [NSMutableArray array];
    _manualDataSourceArr = [NSMutableArray array];
    //自动设置的表示图
    [_automaticDataSourceArr addObjectsFromArray:@[@"高",@"中",@"低"]];
    //手动设置的表示图
    [_manualDataSourceArr addObjectsFromArray:@[@"白天",@"黑夜"]];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //获取猫眼夜视模式
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] cyGetCamInfrared:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success, NSString * _Nonnull automaticModel) {
        [hud hideAnimated:YES];
        self.cateyeParam.CamInfrared = automaticModel;
        NSArray * arr = [self.cateyeParam.CamInfrared componentsSeparatedByString:@","];
        if (arr.count==3) {
            if ([arr[0] isEqualToString:@"1"]) {
                _currentManuakIndex = 0;//白天
                self.dayAndNight = @"1";
            }else if ([arr[0] isEqualToString:@"2"]){
                _currentManuakIndex = 1;//黑夜
                self.dayAndNight = @"2";
            }else{
                _currentManuakIndex = 2;//当为2时没有选中的夜视模式：白天、黑夜
            }
            if ([arr[1] isEqualToString:@"120"]) {
                _currentAutomaticIndex = 0;//高
                self.nightVisionStr = @"120,70";
            }else if ([arr[1] isEqualToString:@"100"]){
                _currentAutomaticIndex = 1;//中
                self.nightVisionStr = @"100,50";
            }else{
                _currentAutomaticIndex = 2;//低
                self.nightVisionStr = @"70,20";
            }
        }
        _selectManuakRingNum = @(_currentManuakIndex);
        _selectAutomaticRingNum = @(_currentAutomaticIndex);
        [self.AutomaticTableView reloadData];
        [self.ManualTableView reloadData];
    }];
    
}

- (void)viewDidLayoutSubviews
{
    if (CGRectIsEmpty(self.ManualTableView.frame))
    {
        self.scrollView.contentSize = CGSizeMake((kScreenWidth-(KDSSSALE_WIDTH(53)*2)) * 2, 228-88);
        CGRect frame = self.scrollView.bounds;
        frame.origin.x += 10;
        frame.origin.y -= 35;
        frame.size.width -= 20;
        self.ManualTableView.frame = frame;
        frame.origin.x += kScreenWidth-(KDSSSALE_WIDTH(53)*2);
        self.AutomaticTableView.frame = frame;
    }
}

- (void)setupUI
{
    UIView * supView = [UIView new];
    supView.backgroundColor = UIColor.whiteColor;
    supView.layer.masksToBounds = YES;
    supView.layer.cornerRadius  = 5;
    [self.view addSubview:supView];
    [supView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(153));
        make.right.mas_equalTo(self.view.mas_right).offset(-KDSSSALE_WIDTH(53));
        make.left.mas_equalTo(self.view.mas_left).offset(KDSSSALE_WIDTH(53));
        make.height.mas_equalTo(228);
    }];
    //顶部功能选择按钮
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth-KDSSSALE_WIDTH(53)*2, 44)];
    view.backgroundColor = UIColor.whiteColor;
    [supView addSubview:view];
    [view addSubview:self.manualBtn];
    [view addSubview:self.automaticBtn];
    CGFloat width = (KDSScreenWidth-KDSSSALE_WIDTH(53)*2)/2;
    [self.manualBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.automaticBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = UIColor.whiteColor;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [supView addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view.mas_bottom).offset(0);
        make.left.bottom.right.equalTo(supView);
    }];
    
    self.ManualTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.ManualTableView.showsVerticalScrollIndicator = NO;
    self.ManualTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.ManualTableView.dataSource = self;
    self.ManualTableView.delegate = self;
    self.ManualTableView.scrollEnabled = NO;
    self.ManualTableView.tableHeaderView = [UIView new];
    self.ManualTableView.tableFooterView = [UIView new];
    [self.ManualTableView registerClass:[KDSCateyeMoreCell class] forCellReuseIdentifier:KDSCateyeMoreCell.ID];
    [self.scrollView addSubview:self.ManualTableView];
    
    self.AutomaticTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.AutomaticTableView.showsVerticalScrollIndicator = NO;
    self.AutomaticTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.AutomaticTableView.dataSource = self;
    self.AutomaticTableView.delegate = self;
    self.AutomaticTableView.scrollEnabled = NO;
    self.AutomaticTableView.tableHeaderView = [UIView new];
    self.AutomaticTableView.tableFooterView = [UIView new];
    [self.AutomaticTableView registerClass:[KDSCateyeMoreCell class] forCellReuseIdentifier:KDSCateyeMoreCell.ID];
    [self.scrollView addSubview:self.AutomaticTableView];
    self.ManualTableView.rowHeight = (228 -88)/2;
    self.AutomaticTableView.rowHeight = (228-88)/3;
    self.ManualTableView.backgroundColor = self.AutomaticTableView.backgroundColor = UIColor.clearColor;
    UIView * bottomView = [UIView new];
    bottomView.backgroundColor = UIColor.whiteColor;
    [supView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(supView.mas_bottom).offset(0);
        make.left.right.equalTo(supView);
        make.height.mas_equalTo(44);
    }];
    
    [bottomView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(bottomView);
        make.width.mas_equalTo(@(width));
    }];
    [bottomView addSubview:self.okBtn];
    [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(bottomView);
        make.width.mas_equalTo(@(width));
    }];
    UIView * line = [UIView new];
    line.backgroundColor = KDSRGBColor(234, 233, 233);
    [bottomView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.6);
        make.bottom.top.equalTo(bottomView);
        make.centerX.mas_equalTo(bottomView.mas_centerX).offset(0);
    }];
    UIView * line1 = [UIView new];
    line1.backgroundColor = KDSRGBColor(234, 233, 233);
    [bottomView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.6);
        make.right.left.top.equalTo(bottomView);
    }];
    if (@available(iOS 11.0, *)) {
        self.AutomaticTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.ManualTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

#pragma mark - 控件等事件方法。
///点击开锁记录、预警信息按钮调整滚动视图的偏移，切换页面。
- (void)clickRecordBtnAdjustScrollViewContentOffset:(UIButton *)sender
{
    if (sender.selected) return;
    self.manualBtn.selected = self.automaticBtn.selected = NO;
    sender.selected = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.contentOffset = CGPointMake(sender == self.manualBtn ? 0 : kScreenWidth-(KDSSSALE_WIDTH(53)*2), 0);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView)
    {
        self.manualBtn.selected = scrollView.contentOffset.x == 0;
        self.automaticBtn.selected = !self.manualBtn.selected;
       
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.ManualTableView) {
        
        return self.manualDataSourceArr.count;
        
    }else{
        return self.automaticDataSourceArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCateyeMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCateyeMoreCell.ID];
    if (tableView == self.ManualTableView) {
        //手动
        cell.titleNameLb.text = self.manualDataSourceArr[indexPath.row];
        cell.selectBtn.tag = indexPath.row;
        [cell.selectBtn addTarget:self action:@selector(manualTBringNumClick:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row == self.manualDataSourceArr.count -1) {
            self.ManualTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
           self.ManualTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        if (indexPath.row == _currentManuakIndex) {
            cell.selectBtn.selected = YES;
        }
        else{
            cell.selectBtn.selected = NO;
        }
    }else{
        //自动
        cell.titleNameLb.text = self.automaticDataSourceArr[indexPath.row];
        cell.selectBtn.tag = indexPath.row;
        [cell.selectBtn addTarget:self action:@selector(automaticTBringNumClick:) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.row == self.automaticDataSourceArr.count -1) {
            self.AutomaticTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else{
            self.AutomaticTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        if (indexPath.row == _currentAutomaticIndex) {
            cell.selectBtn.selected = YES;
        }
        else{
            cell.selectBtn.selected = NO;
        }
    }
    
    return cell;
}

#pragma mark 手势
//手动
-(void)manualTBringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentManuakIndex = sender.tag;
    [self.ManualTableView reloadData];
    _selectManuakRingNum = @(sender.tag+1);
    switch (_selectManuakRingNum.intValue) {
        case 1:
            self.dayAndNight = @"1";
            break;
        case 2:
            self.dayAndNight = @"2";
            break;
        default:
            break;
    }
    
}
//自动
-(void)automaticTBringNumClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    _currentAutomaticIndex = sender.tag;
    [self.AutomaticTableView reloadData];
    _selectAutomaticRingNum = @(sender.tag+1);
    switch (_selectAutomaticRingNum.intValue) {
        case 1:
            self.nightVisionStr = @"120,70";
            break;
        case 2:
            self.nightVisionStr = @"100,50";
            break;
        case 3:
            self.nightVisionStr = @"70,20";
            break;
            
        default:
            break;
    }
    
}

-(void)cancelBtnClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)okBtnClick:(UIButton *)sender
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    NSArray * arr = [self.nightVisionStr componentsSeparatedByString:@","];
    NSString * str1,* str2;
    if (arr.count == 2) {
        str1 = arr[0];
        str2 = arr[1];
    }
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setCamInfrared:self.dayAndNight.intValue photoresistorHAcquisition:str1.intValue photoresistorLacquisition:str2.intValue completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
    
}

#pragma --Lazy load
- (UIButton *)manualBtn
{
    if (!_manualBtn) {
        _manualBtn = [UIButton new];
        [_manualBtn setTitle:Localized(@"manual") forState:UIControlStateNormal];
        _manualBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _manualBtn.adjustsImageWhenHighlighted = NO;
        [_manualBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
        _manualBtn.selected = YES;
        [_manualBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
        [_manualBtn setBackgroundColor:KDSRGBColor(120, 190, 247) forState:UIControlStateNormal];
        [_manualBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_manualBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    }
    return _manualBtn;
}

- (UIButton *)automaticBtn
{
    if (!_automaticBtn) {
        _automaticBtn = [UIButton new];
        [_automaticBtn setTitle:Localized(@"automatic") forState:UIControlStateNormal];
        _automaticBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _automaticBtn.adjustsImageWhenHighlighted = NO;
        [_automaticBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
        [_automaticBtn setBackgroundColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
        [_automaticBtn setBackgroundColor:KDSRGBColor(120, 190, 247) forState:UIControlStateNormal];
        [_automaticBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_automaticBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
        
    }
    return _automaticBtn;
}
- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton new];
        [_cancelBtn setTitle:Localized(@"cancel") forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _cancelBtn;
}
- (UIButton *)okBtn
{
    if (!_okBtn) {
        _okBtn = [UIButton new];
        [_okBtn setTitle:Localized(@"sure") forState:UIControlStateNormal];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_okBtn addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_okBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateNormal];
    }
    return _okBtn;
}

@end
