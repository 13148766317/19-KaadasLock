//
//  KDSXMMediaLockHelpVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/11/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSXMMediaLockHelpVC.h"
#import "UIButton+Color.h"

@interface KDSXMMediaLockHelpVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *dataArray;//创建一个数据源数组
    NSMutableDictionary *dic;//创建一个字典进行判断收缩还是展开
    NSMutableDictionary * rowHeighDic;
    NSArray *sectionArr;//分组的名字
}

@property (nonatomic,strong)UITableView *tableView;
///怎样配置视频锁按钮。
@property (nonatomic,strong) UIButton *configureVideoLockBtn;
///常见问题按钮。
@property (nonatomic,strong) UIButton *commonProblemBtn;
@property (nonatomic,strong) UIView * line1;
@property (nonatomic,strong) UIView * line2;
@property (nonatomic,strong) UIButton * selectedBtn;
@property (nonatomic,strong)UIImageView * arrowImg;

@end

@implementation KDSXMMediaLockHelpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    self.navigationTitleLabel.text = @"使用帮助";
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    dic = [NSMutableDictionary dictionary];
    rowHeighDic = [NSMutableDictionary dictionary];
    
    [self creatData];
}

- (void)setUpUI
{
    //顶部功能选择按钮
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    view.backgroundColor = UIColor.whiteColor;
    view.layer.cornerRadius = 22;
    [self.view addSubview:view];
    self.configureVideoLockBtn = [UIButton new];
    [self.configureVideoLockBtn setTitle:@"怎样配置视频锁" forState:UIControlStateNormal];
    self.configureVideoLockBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.configureVideoLockBtn.adjustsImageWhenHighlighted = NO;
    [self.configureVideoLockBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    [self.configureVideoLockBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateSelected];
    [self.configureVideoLockBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.configureVideoLockBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.configureVideoLockBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    self.configureVideoLockBtn.selected = YES;
    self.selectedBtn = self.configureVideoLockBtn;
    [view addSubview:self.configureVideoLockBtn];
    
    self.commonProblemBtn = [UIButton new];
    [self.commonProblemBtn setTitle:@"常见问题" forState:UIControlStateNormal];
    self.commonProblemBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.commonProblemBtn.adjustsImageWhenHighlighted = NO;
    [self.commonProblemBtn addTarget:self action:@selector(clickRecordBtnAdjustScrollViewContentOffset:) forControlEvents:UIControlEventTouchUpInside];
    [self.commonProblemBtn setBackgroundColor:UIColor.whiteColor forState:UIControlStateSelected];
    [self.commonProblemBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.commonProblemBtn setTitleColor:KDSRGBColor(31, 150, 247) forState:UIControlStateSelected];
    [self.commonProblemBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [view addSubview:self.commonProblemBtn];
    self.line1 = [UIView new];
    self.line1.backgroundColor = KDSRGBColor(31, 150, 247);
    [view addSubview:self.line1];
    self.line2 = [UIView new];
    self.line2.backgroundColor = KDSRGBColor(31, 150, 247);
    self.line2.hidden = YES;
    [view addSubview:self.line2];
    CGFloat width = KDSScreenWidth/2;
    [self.configureVideoLockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@16);
        make.height.equalTo(@2);
        make.bottom.equalTo(view.mas_bottom).offset(0);
        make.left.equalTo(view.mas_left).offset(((KDSScreenWidth/2)-16)/2);
    }];
    [self.commonProblemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.equalTo(view);
        make.width.mas_equalTo(@(width));
        
    }];
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@16);
        make.height.equalTo(@2);
        make.bottom.equalTo(view.mas_bottom).offset(0);
        make.right.equalTo(view.mas_right).offset(-((KDSScreenWidth/2)-16)/2);
    }];
    
    [self.view addSubview:self.tableView];
    
}

//懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 54, KDSScreenWidth, KDSScreenHeight-kNavBarHeight-kBottomSafeHeight-kStatusBarHeight-44) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColor.clearColor;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 5000;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 45)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, KDSScreenWidth-30, view.frame.size.height)];
    titleLab.text = sectionArr[section];
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.userInteractionEnabled = true;
    [view addSubview:titleLab];
    self.arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(KDSScreenWidth-30, 15, 14, 14)];
    [view addSubview:self.arrowImg];
    //创建一个手势进行点击，这里可以换成button
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(action_tap:)];
    view.tag = 300 + section;
    if (dic.allKeys.count < 1) {
        self.arrowImg.image = [UIImage imageNamed:@"icon_packup"];
    }else{
        NSString *str = [NSString stringWithFormat:@"%d",view.tag - 300];
        if ([dic[str] integerValue] == 0) {
            self.arrowImg.image = [UIImage imageNamed:@"icon_packup"];
        }else{
            self.arrowImg.image = [UIImage imageNamed:@"icon_unfold"];
        }
    }
    
    [view addGestureRecognizer:tap];
    return view;
}

- (void)action_tap:(UIGestureRecognizer *)tap{
    NSString *str = [NSString stringWithFormat:@"%d",tap.view.tag - 300];
    if ([dic[str] integerValue] == 0) {//如果是0，就把1赋给字典,打开cell
        [dic setObject:@"1" forKey:str];
    }else{//反之关闭cell
        [dic setObject:@"0" forKey:str];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:[str integerValue]]withRowAnimation:UITableViewRowAnimationFade];//有动画的刷新
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString *string = [NSString stringWithFormat:@"%ld",(long)section];
    if ([dic[string] integerValue] == 1 ) {  //打开cell返回数组的count
        NSArray *array = [NSArray arrayWithArray:dataArray[section]];
        return array.count;
    }else{
        return 0;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *rowStr = [NSString stringWithFormat:@"%ld",(long)indexPath.section];
    NSString * rowHeigh = rowHeighDic[rowStr];
    return rowHeigh.intValue +30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = dataArray[indexPath.section][indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = KDSRGBColor(102, 102, 102);
    [self setLabelSpace:cell.textLabel withSpace:10.0f withFont:[UIFont systemFontOfSize:12] section:indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 10)];
    footView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    return footView;
}


-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font section:(NSInteger)section {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:UIColor.blackColor, NSParagraphStyleAttributeName:paraStyle};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:label.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:paraStyle}];
    [attrStr addAttributes:attrs range:[label.text rangeOfString:@"解决方法："]];
    label.attributedText = attrStr;
    
    CGFloat rowHeight = [self getLabelHeightWithText:label.text width:KDSScreenWidth-30 textFont:[UIFont systemFontOfSize:12] lineHeight:10];
    NSString *rowStr = [NSString stringWithFormat:@"%ld",(long)section];
    [rowHeighDic setObject:@(rowHeight) forKey:rowStr];
}

/* text 显示的字符串
   font 字体大小
   lineHeight 行间距
 */
- (CGFloat)getLabelHeightWithText:(NSString *)text width:(CGFloat)width textFont:(UIFont *)font lineHeight:(NSInteger)lineHeight{

    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.lineSpacing = lineHeight;
    NSDictionary *attribute = @{NSFontAttributeName:font,
                                NSParagraphStyleAttributeName:paragrapStyle};
    CGRect rect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    return rect.size.height;
}

///点击开锁记录、预警信息按钮调整滚动视图的偏移，切换页面。
- (void)clickRecordBtnAdjustScrollViewContentOffset:(UIButton *)sender
{
    if (sender!= self.selectedBtn) {
        self.selectedBtn.selected = NO;
        sender.selected = YES;
        self.selectedBtn = sender;
    }else{
        self.selectedBtn.selected = YES;
    }
    if (self.selectedBtn == self.configureVideoLockBtn) {
        self.line2.hidden = YES;
        self.line1.hidden = NO;
        [self creatData];
        [self.tableView reloadData];
    }else{
        self.line2.hidden = NO;
        self.line1.hidden = YES;
        [self upDateData];
        
        [self.tableView reloadData];
    }

}


- (void)creatData
{
    dataArray = @[@[@"① 确认门锁已安装；\n② 推开门锁后面板电池盖（后面板上方位置，用力向上推开），安装上随包配送的锂电池；\n③ 请确保锂电池电量充足，请按电池指向确保电池正负安装正确；\n④ 当门锁出现低电量报警时，请及时更换电池；\n⑤ 请确保家里的WiFi网络（仅支持2.4G网络，后缀是_5G的不支持）能正常使用，请将手机连接到该WiFi网络."
                    ],
                  @[@"① 微信搜索【凯迪仕智能锁】公众号并关注；\n② 进入公众号-【售后服务】，点击【产品激活】；\n③ 扫描包装盒产品序列号，获得激活码；\n④ 唤醒门锁，输入激活码，按“#”确认."
                    ],
                  @[@"① 用手触碰按键区，唤醒门锁，确保门锁数字键盘灯亮；\n② 按键区，输入“*”两次，即“**”；\n③ 输入初始管理员密码“12345678”\n④ 按“#”确认；\n⑤ 语音播报“已进入管理模式，请修改管理密码”；\n⑥ 输入新设定的管理密码，按“#”确认；\n⑦ 再次输入刚才的管理员密码，按“#”完成修改."
                    ],
                   @[@"① 在APP添加设备页面，选择K20-V可视猫眼智能锁或点击右上角扫描图标，扫描；对应门锁后面板的配网二维码，进行配网；\n② 进入门锁配网准备页面，点击“门锁安装好，去配网”按钮；\n③ 点击“门锁已激活”按钮（未激活请参考门锁的激活操作）；\n④ 根据提示，进入管理模式，按“4”进入配网状态；\n⑤ 输入WiFi密码（确保此WiFi是2.4G频段，暂时不支持5G频段），点击下一步；\n⑥ 将生成的二维码放到门锁前面板的镜头前10-15CM扫描，等听到“扫描成功，配网中”语音；后，根据语音提示，点击下一步（若提示配网失败，请重新进入管理模式，按4配网）；\n⑦ WiFi连接成功后，请输入管理员密码，用于开启临时密码功能；\n⑧ 管理员密码验证成功后，可以给门锁起一个名字，完成门锁配网."
                     ],
                   @[@"① 门锁目前支持2.4G的WiFi，暂不支持5G频段的WiFi；\n② 如果您的路由器同时打开了2.4G和5G的WiFi，建议两者使用不同的WiFi名称，以免影响门锁联网效果和视频对讲效果；\n③ 门锁暂不支持同一WiFi名称漫游的公共WiFi环境，比如很多公司、酒店等公共场合的WiFi环境；\n④ 如果需要在上述公共WiFi环境下使用，可以安装一台拥有独立WiFi名称的路由器，并将该路由器接入公共WiFi网络；\n⑤ 如使用连接的家庭WiFi无密码，将不允许配网，请设置密码后再添加门锁."
                    ],
                   @[@"① 确认路由器设置的WiFi名称及密码没有使用特殊字符；\n② 确认路由器的WiFi网络安全认证类型是WPA-PSK或者WPA2-PSK；\n③ 确认路由器的WiFi网络是否设置了白名单、黑名单、MAC地址过滤；\n④ 如果您的路由器长时间工作，建议重启路由器后重试."
                     ],
                   @[@"① 尝试关闭手机WiFi再打开后再试；\n② 重新启动手机系统后再试."
                     ]
    ];
    sectionArr = @[@"配置前确认",
                   @"第一步：进行门锁的激活操作",
                   @"第二步：修改初始管理员密码",
                   @"第三步：门锁首次配网",
                   @"门锁都支持哪些WiFi",
                   @"检查路由器设置",
                   @"以上步骤都正常，仍配网失败"];
}

- (void)upDateData
{
    dataArray =    @[@[@"请检查手机是否禁止APP的获取定位权限.\n解决方法：\n打开手机设置-应用权限管理，找到凯迪仕智能锁APP，开启定位权限.\n注： Android手机的APP要获取WiFi列表，需要获取定位权限."
                   ],
                  @[@"将原配锂电池按标签指示方向插入门锁后面板电池仓，若门锁提示电量低，代表锂电池要更换.\n解决方法：\n将锂电池取下然后找一个手机充电器，即可给锂电池充电.\n注: 注意充电器的接口与锂电池的接口要一致，都是使用micro USB接口，充电7个小时左右即可满电."
                   ],
                  @[@"① WiFi是否是2.4G频段\n② 请检查WiFi的密码是否正确\n③ 请检查WiFi路由器是否能上网\n④ 公共场所的WiFi不支持\n⑤ WiFi路由器离门锁太远或者穿越多堵墙？\n⑥ WiFi天线中间连接线是否接好\n⑦ WiFi路由器未设置密码\n解决方法：\n① 目前不支持WiFi的5G频段和公共场所的WiFi（需要密码的那种），请连接2.4G频段的可正常上网的WiFi；\n② 请将路由器离门锁可视距离不超过20米；\n③ 请检查WiFi密码是否正确，区分空格和特殊字符；\n④ 请在门锁上重新进入管理员模式，按4进入配网状态，然后APP上重新按引导步骤添加即可；\n⑤ 请保证WiFi路由器离门锁可视距离不超过20米；\n⑥ 请将WiFi天线连接线接好；\n⑦ 为保障安全，暂时不支持未设置过密码的WiFi路由器给门锁配网.\n注： 注意充电器的接口与锂电池的接口要一致，都是使用micro USB接口，充电7个小时左右即可满电."
                  ],
                   @[@"① 请检查手机APP是否开启推送免打扰；\n② 请检查APP推送权限是否开启.\n解决方法：\n① 点击APP里对应门锁的更多按钮，进入设置页面，选择消息推送，进入后关闭消息免打扰；\n② 打开android手机设置-应用权限管理，找到凯迪仕智能锁APP，开启所有推送和相关权限.\n注：Android手机由于系统厂商默认会禁止APP的消息推送权限和其他权限，需要用户手动设置开启，请允许APP开机自启动，在后台时别杀"
                   ],
                   @[@"① 先检查镜头玻璃是否干净\n② 镜头有无水汽\n③ WiFi信号不稳定\n④ 是否关闭视频长连接\n解决方法：\n① 用无尘布将镜头擦拭干净\n② 若镜头玻璃内部有水汽，需拆机维修\n③ WiFi信号不稳定会导致图像卡顿或无法出图，请将路由器靠近智能锁，可视距离不超过20米④请在APP实时视频页面右上角设置按钮进入，打开视频长连接开关，设置周期为每（00:00-23:59）\n注：联网产品对WiFi信号有要求，请确保手机和家中的WiFi路由器能正常上网."
                   ],
                   @[@"① 请检查APP是否提示获取相机权限受限\n② 门锁后面板二维码损坏\n解决方法：\n① 打开手机设置-应用权限管理，找到凯迪仕智能锁APP，开启相机权限\n② 请选择添加视频锁，手动输入型号：K20V\n注：部分Android手机由于系统厂商默认会禁止APP获取相关权限，需要用户手动设置开启."
                   ],
                   @[@"请检查APP对应门锁的徘徊报警开关是否开启\n解决方法：\n打开凯迪仕APP，找到对应门锁，点击“更多”按钮，进入设置页面，找到徘徊报警选型，进入后，开启徘徊报警开关.\n注：为了省电，徘徊报警默认是关闭的，需打开才能有此功能，徘徊报警的PIR的灵敏度分：低中高，分别对应1米、2米、3米的侦测距离，判定时间10-60秒，默认在门外徘徊30秒触发报警."
                   ]
    ];
    sectionArr = @[@"WiFi列表无法显示？",
                   @"锂电池没电？",
                   @"APP配网失败？",
                   @"收不到门铃和报警推送？",
                   @"图像看不了、不清晰、卡顿？",
                   @"无法扫描二维码？",
                   @"徘徊报警不报警？"];
}

@end
