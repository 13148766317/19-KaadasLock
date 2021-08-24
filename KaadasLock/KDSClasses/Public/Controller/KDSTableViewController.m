//
//  KDSTableViewController.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSTableViewController.h"

@interface KDSTableViewController ()
{
    UITableView *_tableView;
}

@end

@implementation KDSTableViewController

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.style];
    }
    return _tableView;
}

- (void)setEnablePulldown:(BOOL)enablePulldown
{
    _enablePulldown = enablePulldown;
    if (enablePulldown)
    {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    }
    else
    {
        self.tableView.mj_header = nil;
    }
}

- (void)setEnablePullup:(BOOL)enablePullup
{
    _enablePullup = enablePullup;
    if (enablePullup)
    {
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    }
    else
    {
        self.tableView.mj_footer = nil;
    }
}

#pragma mark - 生命周期方法
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.style = UITableViewStylePlain;
        _enablePullup = NO;
        _enablePulldown = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.tableHeaderView = [UIView new];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

#pragma mark - 控件等事件方法
- (void)loadNewData {}

- (void)loadMoreData {}

@end
