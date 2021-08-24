//
//  KDSCatEyeSnapshotVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/7.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeSnapshotVC.h"
#import "KDSCatEyePlaybackCell.h"
#import "MBProgressHUD+MJ.h"
#import "LxFTPRequest.h"
#import "MJRefresh.h"
#import "AlarmMessageModel.h"
#import "KDSDBManager+CY.h"
#import "NSDate+KDS.h"
#import "AlarmFileShowViewController.h"
#import "pirUpdateTipView.h"
#import "KDSFTIndicator.h"

static NSString * const USERNAME = nil;
static NSString * const PASSWORD = nil;
#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]
@interface KDSCatEyeSnapshotVC ()<UITableViewDelegate,UITableViewDataSource,PirUpdateTipViewDelegate>
@property (nonatomic,readwrite,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray<AlarmMessageModel*> * listArray;//当前显示的列表数据源
@property(nonatomic,assign)uint16_t ftpPort;//此次ftp打开的端口
@property(nonatomic,copy)NSString * ftpIPAddress;//此次ftp的
@property(nonatomic,copy)NSString *currentPath;//当前猫眼存储快照的文件夹
@property(strong, nonatomic)PirUpdateTipView *pirUpdateTipView;
@property(strong,nonatomic)LxFTPRequest * request;

@end

@implementation KDSCatEyeSnapshotVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSArray *pirPicArray = [[KDSDBManager sharedManager] getPirArrayWithCateID:self.gatewayDeviceModel.deviceId picDate:self.currentPicDate];
    if (pirPicArray.count != 0) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStr" ascending:NO];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[pirPicArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
        self.listArray = resultArray;
        [self.tableView reloadData];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (_request) {
        [_request stop];
    }
    [KDSFTIndicator dismissProgress];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.pirUpdateTipView];
    [self UpdatePirNumView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(KDSScreenHeight-200-kStatusBarHeight);
    }];
    KDSWeakSelf(self);
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakself.pirUpdateTipView) {
            weakself.pirUpdateTipView.hidden = YES;
            [KDSUserDefaults removeObjectForKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",weakself.gatewayDeviceModel.deviceId]];
        }
        [weakself setFTPEnableisChangeDate:NO];
        NSLog(@"点击了下拉刷新");
    }];
    self.tableView.mj_header = header;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SnapshotSelected:) name:@"KDSSnapshotTimeSelected" object:nil];
    [KDSNotificationCenter addObserver:self
                              selector:@selector(pirPhotoUpdate:)
                                  name:@"PirPhotoAlarmUpdate"
                                object:nil];
}
-(void)UpdatePirNumView{
    NSArray * pirPhotoArray = [KDSUserDefaults objectForKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",self.gatewayDeviceModel.deviceId]];
    if (pirPhotoArray.count != 0) {
        if (!_pirUpdateTipView) {
            _pirUpdateTipView = [[PirUpdateTipView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 25)];
            _pirUpdateTipView.delegate = self;
            _pirUpdateTipView.backgroundColor = KDSRGBColorZA(31, 150, 247, 0.59);
            _pirUpdateTipView.tipLab.text = [NSString stringWithFormat:Localized(@"新增张快照，请下拉刷新"),(unsigned long)pirPhotoArray.count];
            [self.view addSubview:_pirUpdateTipView];
        }else{
            _pirUpdateTipView.hidden = NO;
            _pirUpdateTipView.tipLab.text = [NSString stringWithFormat:Localized(@"新增张快照，请下拉刷新"),(unsigned long)pirPhotoArray.count];
        }
    }
}
//开启ftp通道
-(void)setFTPEnableisChangeDate:(BOOL)isChangeDate{
    [KDSFTIndicator showProgressWithMessage:[NSString stringWithFormat:@"%@%@",Localized(@"正在连接"),@"..."] userInteractionEnable:NO];
    KDSWeakSelf(self);
    [[KDSMQTTManager sharedManager] cy:self.gatewayDeviceModel openFtpRelay:YES withAddress:kFTPRelayHost completion:^(NSError * _Nullable error, NSString * _Nullable ip, NSInteger port) {
        [KDSFTIndicator dismissProgress];
        if (!error) {
            weakself.ftpIPAddress = ip?:ip;
            weakself.ftpPort = port;                                            
            [KDSFTIndicator showProgressWithMessage:Localized(@"正在获取列表") userInteractionEnable:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself ResourceListFTPRequestWithDateisChangeDate:isChangeDate withDateStr:weakself.currentPicDate ];
            });
        }else{
            [KDSFTIndicator showErrorWithMessage:Localized(@"猫眼连接失败")];
            [weakself.tableView.mj_header endRefreshing];
        }
    }];
}
//开始ftp下载
-(void)ResourceListFTPRequestWithDateisChangeDate:(BOOL)isChangeDate withDateStr:(NSString *)dateStr{
    NSString *dateFileName = [NSString stringWithFormat:@"orangecat-%@",[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    KDSWeakSelf(self);
    _request = [LxFTPRequest resourceListRequest];
    if (self.ftpIPAddress.length == 0) {
        [KDSFTIndicator showErrorWithMessage:Localized(@"资源链接失败")];
        return;
    }
    NSString *FTPAddress = [NSString stringWithFormat:@"ftp://%@:",weakself.ftpIPAddress];;
    uint16_t port = weakself.ftpPort;
    NSString * urlStr = [FTPAddress stringByAppendingString:[NSString stringWithFormat:@"%hu",port]];
    NSString *URL;
    if ([weakself.currentPicDate isEqualToString:dateStr]) {
        URL = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/sdap0/storage/%@/",dateFileName]];
    }else{
        URL = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/../%@/",dateFileName]];
    }
    _request.serverURL = [NSURL URLWithString:URL];
    _request.username = [NSString stringWithFormat:@"%@,%@,%@",[KDSUserManager sharedManager].user.uid,weakself.gatewayDeviceModel.gatewayId,weakself.gatewayDeviceModel.deviceId ];
    _request.password = PASSWORD;
    NSLog(@"serverURL====%@",_request.serverURL);
    _request.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        NSLog(@"--ftp---totalSize = %ld, finishedSize = %ld, finishedPercent = %f", (long)totalSize, (long)finishedSize, finishedPercent);
    };
    _request.successAction = ^(Class resultClass, id result) {
        [weakself.tableView.mj_header endRefreshing ];
        if ([weakself.currentPicDate isEqualToString:dateStr]) {//获取前一天
            [KDSFTIndicator dismissProgress];
//            [MBProgressHUD showSuccess:Localized(@"列表获取成功")];
            [KDSFTIndicator showSuccessWithMessage:Localized(@"列表获取成功")];
            NSLog(@"---dateStr 1 = %@",dateStr);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//解决8小时时间差问题
            NSDate *date = [dateFormatter dateFromString:dateStr];
            NSDate *errorDay;
            if ([[NSTimeZone localTimeZone].abbreviation containsString:@"+"]) {//东时区
                errorDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
            }else{
                errorDay = [NSDate dateWithTimeInterval:+24*60*60 sinceDate:date];//前一天
            }
            NSLog(@"errorDay=%@",errorDay);
            NSString *errorDayStr = [errorDay stringWithFormat:@"yyyy-MM-dd"];
            [weakself ResourceListFTPRequestWithDateisChangeDate:NO withDateStr:errorDayStr];
        }else{
            
        }
        NSLog(@"--ftp---成功 dateStr=%@ resultArray.count==%lu",dateStr,(unsigned long)weakself.listArray.count);
        [weakself arrayToDB:(NSMutableArray *)result isChangeDate:isChangeDate];
    };
    _request.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString * errorMessage) {
        if ([weakself.currentPicDate isEqualToString:dateStr]) {//获取前一天
            [KDSFTIndicator dismissProgress];
            [weakself.tableView.mj_header endRefreshing];
            if (error == 550) {
                [KDSFTIndicator showErrorWithMessage:Localized(@"未找到文件列表")];
            }else{
                [KDSFTIndicator showErrorWithMessage:[NSString stringWithFormat:@"%@ %@",Localized(@"列表获取失败"),errorMessage]];
            }
            NSLog(@"--ftp---domain = %ld, error = %ld, errorMessage = %@", domain, (long)error, errorMessage);
            NSLog(@"---dateStr 3 = %@",dateStr);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//解决8小时时间差问题
            NSDate *date = [dateFormatter dateFromString:dateStr];
            NSDate *errorDay;
            if ([[NSTimeZone localTimeZone].abbreviation containsString:@"+"]) {//东时区
                errorDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
            }else{
                errorDay = [NSDate dateWithTimeInterval:+24*60*60 sinceDate:date];//后一天
            }
            NSString *errorDayStr = [errorDay stringWithFormat:@"yyyy-MM-dd"];
            [weakself ResourceListFTPRequestWithDateisChangeDate:NO withDateStr:errorDayStr];
        }
    };
    [_request start];
}

//刷新或插入列表数据
-(void)arrayToDB:(id)arrayOrData isChangeDate:(BOOL)isChangeDate{
    NSMutableArray * totalArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in  arrayOrData) {
        if ([dic objectForKey:@"kCFFTPResourceName"]) {
            [totalArray addObject:[dic objectForKey:@"kCFFTPResourceName"]];
        }
    }
    //标记未点击的文件
    NSMutableArray * picArray = [[NSMutableArray alloc] init];
    for (NSString * str in totalArray) {
        if ([str containsString:@"jpg"] &&![str hasPrefix:@"."]) {
            AlarmMessageModel * alarmModel = [AlarmMessageModel alloc];
            alarmModel.timeStr = [str substringWithRange:NSMakeRange(0, 10)];
            alarmModel.isChecked = @"false";
            [picArray addObject:alarmModel];
        }
    }
    //判断是否为当天文件
    NSMutableArray * filtArray = [[NSMutableArray alloc] init];
    for (AlarmMessageModel *am in picArray) {
        //文件的nsdate
        NSString *fileDateStr = [KDSTool timestampSwitchTime:[am.timeStr integerValue] andFormatter:@"yyyy-MM-dd HH:mm"];
        NSString * dateStr1 = [self.currentPicDate stringByAppendingString:@" 00:00"];
        NSString * dateStr2 = [self.currentPicDate stringByAppendingString:@" 23:59"];
        NSLog(@"fileDateStr=%@ am.timestr111=%@",fileDateStr,am.timeStr);
        if ([fileDateStr compare:dateStr1] == NSOrderedDescending && [fileDateStr compare:dateStr2] == NSOrderedAscending) {
            [filtArray addObject:am];
            NSLog(@"fileDateStr=%@ am.timestr222=%@",fileDateStr,am.timeStr);
        }
    }
    picArray = filtArray;
    //    当刷新界面时，只添加原来没有的数据
    if (self.listArray.count != 0 && !isChangeDate){
        NSMutableArray * oldTimeStrArray = [[NSMutableArray alloc] init];
        for (AlarmMessageModel *am in self.listArray) {
            [oldTimeStrArray addObject:am.timeStr];
        }
        NSMutableArray * oldArray = [NSMutableArray arrayWithArray:self.listArray];
        for (AlarmMessageModel *am in picArray) {
            if (![oldTimeStrArray containsObject:am.timeStr]) {
                AlarmMessageModel * alarmModel = [AlarmMessageModel alloc];
                alarmModel.timeStr = [am.timeStr substringWithRange:NSMakeRange(0, 10)];
                alarmModel.isChecked = @"false";
                [oldArray addObject:alarmModel];
            }
        }
        picArray = oldArray;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStr" ascending:NO];
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[picArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    self.listArray = [NSMutableArray arrayWithArray:resultArray];
    [self.tableView reloadData];
    for (AlarmMessageModel *am in picArray) {
        NSLog(@"isChecked222 == %@",am.isChecked);
    }
    [[KDSDBManager sharedManager] addPirArray:picArray cateyeID:self.gatewayDeviceModel.deviceId picDate:self.currentPicDate];
}
#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyePlaybackCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyePlaybackCell.ID];
    AlarmMessageModel *model = self.listArray[indexPath.row];
    cell.alarmModel = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmMessageModel *am = self.listArray[indexPath.row];
    AlarmFileShowViewController *vc = [[AlarmFileShowViewController alloc] init];
    vc.gatewayDeviceModel = self.gatewayDeviceModel;
    vc.currentPicDate = self.currentPicDate;
    vc.currentFileName = [am.timeStr substringWithRange:NSMakeRange(0, 10)];
    [self.navigationController pushViewController:vc animated:YES];
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSWeakSelf(self)
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Localized(@"确定删除？") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actions = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *dateFileName = [NSString stringWithFormat:@"orangecat-%@",[self.currentPicDate stringByReplacingOccurrencesOfString:@"-" withString:@""]];
            NSString *filePath = [PATHDOCUMNT stringByAppendingPathComponent:dateFileName];
            NSString *videoDateName = [NSString stringWithFormat:@"%@.mkv",_listArray[indexPath.row].timeStr];
            NSString *picDateName = [NSString stringWithFormat:@"%@_picture.jpg",_listArray[indexPath.row].timeStr];
            NSString *videoPath = [filePath stringByAppendingPathComponent:videoDateName];
            NSString *picPath = [filePath stringByAppendingPathComponent:picDateName];
            NSFileManager* fileManager=[NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:videoPath]) {
                BOOL videBlDele= [fileManager removeItemAtPath:videoPath error:nil];
                if (videBlDele) {
                    NSLog(@"视频删除成功");
                }
            }
            if ([fileManager fileExistsAtPath:picPath]) {
                BOOL picBlDele= [fileManager removeItemAtPath:picPath error:nil];
                if (picBlDele) {
                    NSLog(@"图片删除成功");
                }
            }
            [_listArray removeObjectAtIndex:indexPath.row];
            [[KDSDBManager sharedManager] addPirArray:_listArray cateyeID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
            [weakself.tableView reloadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:actions];
        [alertVC addAction:cancel];
        if (alertVC) {
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        // 删除操作
        NSLog(@"删除了哦哦哦哦哦");
    }];
    return @[deleteRoWAction];
}
#pragma mark --Lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.tableFooterView = [UIView new];
            tv.delegate = self;
            tv.dataSource = self;
            tv.rowHeight = 100;
            [tv setSeparatorInset:UIEdgeInsetsMake(0, 137, 0, 0)];
            [tv setSeparatorColor:KDSRGBColor(221, 221, 221)];
            [tv registerClass:[KDSCatEyePlaybackCell class ] forCellReuseIdentifier:KDSCatEyePlaybackCell.ID];
            tv;
        });
    }
    return _tableView;
}
#pragma mark 通知方法回调
-(void)SnapshotSelected:(NSNotification*)notif {
    NSString * str = [notif.userInfo objectForKey: @"time"];
    self.currentPicDate = str;
    NSArray *pirPicArray = [[KDSDBManager sharedManager] getPirArrayWithCateID:self.gatewayDeviceModel.deviceId picDate:self.currentPicDate];
    if (pirPicArray.count != 0) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStr" ascending:NO];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[pirPicArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
        self.listArray = resultArray;
        [self.tableView reloadData];
    }else{
        _pirUpdateTipView.hidden = YES;
        [KDSUserDefaults removeObjectForKey:[NSString stringWithFormat:@"PhotoAlarmArray%@",self.gatewayDeviceModel.deviceId]];
        [self setFTPEnableisChangeDate:YES];
    }
    NSLog(@"快照选择了时间%@",str);
}

-(void)pirPhotoUpdate:(NSNotification *)notification{
    [self UpdatePirNumView];
}
#pragma mark PirUpdateTipViewDelegate
-(void)clickCloseBtn{
    _pirUpdateTipView.hidden = YES;
}
- (void)dealloc
{
    NSLog(@"执行了dealloc----Snapshot");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
