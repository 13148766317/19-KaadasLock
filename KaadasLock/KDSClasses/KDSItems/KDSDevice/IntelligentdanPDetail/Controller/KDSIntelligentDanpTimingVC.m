//
//  KDSIntelligentDanpTimingVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSIntelligentDanpTimingVC.h"
#import "KDSDanPDeviceTimingCell.h"
#import "KDSAddDanpTimingVC.h"

@interface KDSIntelligentDanpTimingVC ()<UITableViewDataSource, UITableViewDelegate>

///格式 HH:mm
@property (nonatomic, strong) NSDateFormatter *fmt;
///显示设备定时列表
@property (nonatomic, strong) UITableView *tableView;
///左滑删除事件。
@property (nonatomic, strong) UITableViewRowAction *deleteAction;

@end

@implementation KDSIntelligentDanpTimingVC

#pragma mark - getter setter
- (NSDateFormatter *)fmt
{
    if (!_fmt)
    {
        _fmt = [[NSDateFormatter alloc] init];
        _fmt.timeZone = [NSTimeZone localTimeZone];
        _fmt.dateFormat = @"HH:mm";
    }
    return _fmt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"timing");
    [self setRightButton];
    [self.rightButton setImage:[UIImage imageNamed:@"新添加设备"] forState:UIControlStateNormal];
    [self setUI];
}
-(void)setUI
{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.mas_equalTo(kNavBarHeight+kStatusBarHeight);
    }];
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDeviceTiming)];
    //上拉加载
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDeviceTiming)];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.right.equalTo(self.view);
    }];
    
}

#pragma mark 事件响应

-(void)loadNewDeviceTiming
{
    
}

-(void)loadMoreDeviceTiming
{
    
}
-(void)navRightClick
{
    KDSAddDanpTimingVC * vc = [KDSAddDanpTimingVC new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark  UITableViewDelegate 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[self.deleteAction];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
     KDSDanPDeviceTimingCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
         cell = [[KDSDanPDeviceTimingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    return cell;
}

#pragma mark --Lazy load
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView * b = [UITableView new];
            b.backgroundColor = UIColor.clearColor;
            b.showsVerticalScrollIndicator = NO;
            b.showsHorizontalScrollIndicator = NO;
            b.delegate = self;
            b.dataSource = self;
            b.rowHeight = 110;
            b.separatorStyle = UITableViewCellSeparatorStyleNone;
            b;
        });
    }
    return _tableView;
}
- (UITableViewRowAction *)deleteAction
{
    if (!_deleteAction)
    {
//        __weak typeof(self) weakSelf = self;
        _deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
        }];
    }
    return _deleteAction;
}

@end
