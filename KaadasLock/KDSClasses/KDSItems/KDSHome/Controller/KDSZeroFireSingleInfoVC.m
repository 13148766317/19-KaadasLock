//
//  KDSZeroFireSingleInfoVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/14.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSZeroFireSingleInfoVC.h"
#import "KDSDanPDeviceTimingCell.h"


@interface KDSZeroFireSingleInfoVC ()<UITableViewDelegate, UITableViewDataSource>

///最外围的大圆。
@property (strong, nonatomic) UIImageView *bigCircleIV;
///中间的圆。
@property (strong, nonatomic) UIImageView *middleCircleIV;
///内部的小圆
@property (strong, nonatomic) UIImageView *smallCircleIV;
///显示ZigBee图标的视图。
@property (strong, nonatomic) UIImageView *zbLogoIV;
///锁动作提示标签(开锁、连接等)。
@property (nonatomic, strong) UILabel *actionLabel;
///锁状态提示标签(反锁、布防等)。
@property (nonatomic, strong) UILabel *stateLabel;
///wifi锁信息更新的时间
@property (nonatomic, strong) UILabel *updateTimeLb;
///“守护时间”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianDayLocalizedLabel;
///锁绑定天数标签。
@property (nonatomic, strong) UILabel *dayLabel;
///守护时间“天”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *dayLocalizedLabel;
///“守护次数”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *guardianTimesLocalizedLabel;
///锁开锁次数标签。
@property (nonatomic, strong) UILabel *timesLabel;
///守护次数“次”标签，设置语言本地化用。
@property (nonatomic, weak) UILabel *timesLocalizedLabel;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
///锁状态。
@property (nonatomic, assign) KDSLockState lockState;
@property (nonatomic, strong) UITableView * tableView;
///记录是否正在进行连接成功，如果是，设置锁状态时直接返回，等动画完毕再设置锁状态。
@property (nonatomic, assign) BOOL animating;

@end

@implementation KDSZeroFireSingleInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)setupUI
{
    CGFloat rate = kScreenHeight / 667;
    rate = rate<1 ? rate : 1;
    self.bigCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"on-zeroFireSingleIconImg"]];
    [self.view addSubview:self.bigCircleIV];
    [self.bigCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kScreenHeight<667 ? 10 : 26);
        make.centerX.equalTo(@0);
        make.width.height.equalTo(@(179 * rate));
    }];
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageViewUnlock:)];
    [self.bigCircleIV addGestureRecognizer:longPressGesture];
    self.bigCircleIV.userInteractionEnabled = YES;
    self.middleCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    [self.view addSubview:self.middleCircleIV];
    [self.middleCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bigCircleIV);
        make.width.height.equalTo(@(142 * rate));
    }];
    self.smallCircleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    self.smallCircleIV.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.smallCircleIV];
    [self.smallCircleIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.centerY.equalTo(self.bigCircleIV).offset(-6 * rate);
        make.width.height.equalTo(@(30 * rate));
    }];
    self.zbLogoIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    self.zbLogoIV.hidden = YES;
    [self.view addSubview:self.zbLogoIV];
    [self.zbLogoIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bigCircleIV);
        make.bottom.equalTo(self.smallCircleIV.mas_top).offset(-14 * rate);
        make.width.height.equalTo(@(18 * rate));
    }];
    self.actionLabel = [self createLabelWithText:Localized(@"deviceOffline") color:KDSRGBColor(0x14, 0xa6, 0xf5) font:[UIFont systemFontOfSize:12]];
    self.actionLabel.hidden = YES;
    [self.view addSubview:self.actionLabel];
    [self.actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smallCircleIV.mas_bottom).offset(kScreenHeight<667 ? 5 : 10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.stateLabel = [self createLabelWithText:Localized(@"") color:KDSRGBColor(0xc6, 0xf5, 0xff) font:[UIFont systemFontOfSize:15]];
    [self.view addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
    }];
    self.updateTimeLb = [self createLabelWithText:@"2019.12.28 13:05:56" color:UIColor.whiteColor font:[UIFont systemFontOfSize:11]];
    self.updateTimeLb.hidden = YES;
    [self.view addSubview:self.updateTimeLb];
    [self.updateTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stateLabel.mas_bottom).offset(10);
        make.centerX.equalTo(self.bigCircleIV);
        
    }];
    
    UIView *cornerView = [UIView new];
    cornerView.layer.cornerRadius = 4;
    cornerView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:cornerView];
    [cornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bigCircleIV.mas_bottom).offset(57 * rate);
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.height.equalTo(@80);
    }];
    
    UIView *grayView = [UIView new];
    grayView.backgroundColor = KDSRGBColor(0xf2, 0xf2, 0xf2);
    [self.view addSubview:grayView];
    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cornerView.mas_centerY);
        make.left.bottom.right.equalTo(self.view);
    }];

    self.tableView = [UITableView new];
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(grayView.mas_top);
        make.left.right.bottom.equalTo(self.view);
    }];
    self.tableView.rowHeight = 110;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = UIColor.clearColor;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
}

///根据各属性创建一个label，返回的label已计算好bounds。alignment center.
- (UILabel *)createLabelWithText:(NSString *)text color:(UIColor *)color font:(UIFont *)font
{
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName : font}];
    label.bounds = CGRectMake(0, 0, ceil(size.width), ceil(size.height));
    return label;
}

#pragma mark - 控件等事件方法。
///长按中间的浅绿色视图开锁。为方便其它页面发起的通知开锁，sender传nil和手势共用一个方法。
- (void)longPressImageViewUnlock:(UILongPressGestureRecognizer *)sender
{
    [MBProgressHUD showError:@"不可点击开门"];
    return;
}

#pragma mark - UITableViewDelegate, UITableViewDataSourc

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
        KDSDanPDeviceTimingCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[KDSDanPDeviceTimingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
       
    return cell;
}

@end
