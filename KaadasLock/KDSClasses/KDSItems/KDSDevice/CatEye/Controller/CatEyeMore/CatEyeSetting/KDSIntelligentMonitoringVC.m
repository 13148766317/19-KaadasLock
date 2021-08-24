//
//  KDSIntelligentMonitoringVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/13.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSIntelligentMonitoringVC.h"
#import "KDSDBManager+CY.h"
#import "CateyeSetModel.h"
#import "CDZPicker.h"
#import "CateyePIRSilenceVC.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
//#import "NSObject+MJKeyValue.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "KDSFTIndicator.h"


@interface KDSIntelligentMonitoringVC ()<UITableViewDelegate,UITableViewDataSource,KDSCatEyeMoreSettingCellDelegate>

@property (nonatomic,readwrite,strong)UITableView * tableView;
@property (nonatomic,strong)CateyeSetModel *thirdModel;
@property (nonatomic,readwrite,strong)NSMutableArray * dataSource;
///触发次数(N)
@property (nonatomic,readwrite,strong)NSString * WanderTimes;
///秒数(M)
@property (nonatomic,readwrite,strong)NSString * inSeconds;

@end

@implementation KDSIntelligentMonitoringVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"Intelligent monitoring");
    self.dataSource = [NSMutableArray array];
    ///先查sd卡状态，根据状态更改pir开关状态
    [self getSdCardStatus];
    [self setDataSource];
   
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(self.dataSource.count * 60);
    }];
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}
-(void)getSdCardStatus{
//    [MBProgressHUD showMessage:Localized(@"pleaseWait")];
    [KDSFTIndicator showProgressWithMessage:Localized(@"pleaseWait") userInteractionEnable:YES];
    [[KDSMQTTManager sharedManager] cyGetSDCardStatus:self.cateye.gatewayDeviceModel completion:^(NSError * _Nullable error, BOOL success, int status) {
         [KDSFTIndicator dismissProgress];
        if (success) {
            self.cateyeParam.sdStatus = [NSString stringWithFormat:@"%d",status];
            [[KDSDBManager sharedManager] updatSdCard:self.cateyeParam.sdStatus deviceID:self.cateyeParam.deviceId];
            [self setDataSource];
            [self.tableView reloadData];
        }
    }];
}

-(void)setDataSource
{
    //pir开关
    NSString * pirStr = [[KDSDBManager sharedManager] getPirEnable:self.cateyeParam.deviceId];
    NSString * sdCardStr = [[KDSDBManager sharedManager] getSdCardStatus:self.cateyeParam.deviceId];
    if ([pirStr isEqualToString:@"1"]) {
        if ([sdCardStr isEqualToString:@"0"]) {//没有sd卡的时候
            self.thirdModel = [CateyeSetModel setWithName:Localized(@"Doorbell PIR switch") andValue:@"0"];
        }else{
            self.thirdModel = [CateyeSetModel setWithName:Localized(@"Doorbell PIR switch") andValue:@"1"];
        }
        
    }else{
        self.thirdModel = [CateyeSetModel setWithName:Localized(@"Doorbell PIR switch") andValue:@"0"];
    }
    NSArray *array = [self.cateyeParam.pirSensitivity componentsSeparatedByString:@","];
    CateyeSetModel *model2;
    if (array.count == 2) {
        NSString * pirSensitivityStr = [NSString stringWithFormat:@"%@/%@",array[0],array[1]];
        model2 = [CateyeSetModel setWithName:Localized(@"PIR wandering") andValue:pirSensitivityStr];
    }else{
        model2 = [CateyeSetModel setWithName:Localized(@"PIR wandering") andValue:self.cateyeParam.pirSensitivity];
    }
    [self.dataSource removeAllObjects];
    
    CateyeSetModel * model3 = [CateyeSetModel setWithName:Localized(@"PIR silence") andValue:nil];
    if (self.cateyeParam.pirSensitivity == nil || self.cateyeParam.pirSensitivity == NULL || [self.cateyeParam.pirSensitivity isKindOfClass:[NSNull class]] || [[self.cateyeParam.pirSensitivity stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 ) {
        
        [self.dataSource addObjectsFromArray:@[self.thirdModel,model3]];
        
    }else{
        [self.dataSource addObjectsFromArray:@[self.thirdModel,model2,model3]];
    }
    
    if ([sdCardStr isEqualToString:@"1"]) {//有sd卡的时候
        CateyeSetModel * model4 = [CateyeSetModel setWithName:@"SD卡" andValue:@"有"];
        [self.dataSource addObject:model4];
    }else{
        CateyeSetModel * model4 = [CateyeSetModel setWithName:@"SD卡" andValue:@"无"];
        [self.dataSource addObject:model4];
    }
    self.tableView.frame = CGRectMake(0, 0, KDSScreenWidth, self.dataSource.count * 60);
}

#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyeMoreSettingCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
    
    cell.model = self.dataSource[indexPath.row];
    cell.delegate = self;
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count ==4) {
        switch (indexPath.row) {
            case 1:///pir徘徊
                [self showPickView];
                break;
            case 2:///pir静默
            {
                CateyePIRSilenceVC * pirSilenceVC = [CateyePIRSilenceVC new];
                pirSilenceVC.deviceModel = self.cateyeParam;
                pirSilenceVC.cateye = self.cateye;
                
                [self.navigationController pushViewController:pirSilenceVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 1:///pir静默
            {
                CateyePIRSilenceVC * pirSilenceVC = [CateyePIRSilenceVC new];
                pirSilenceVC.deviceModel = self.cateyeParam;
                pirSilenceVC.cateye = self.cateye;
                
                [self.navigationController pushViewController:pirSilenceVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
    
}
-(void)showPickView
{
    ///1次
    NSMutableArray * oneSecondsArr = [NSMutableArray array];
    for (int i = 3; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [oneSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *one = [[CDZPickerComponentObject alloc]initWithText:@"1次"];
    one.subArray = [NSMutableArray arrayWithArray:oneSecondsArr];
    ///2次
    NSMutableArray * twoSecondsArr = [NSMutableArray array];
    for (int i = 5; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [twoSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *two = [[CDZPickerComponentObject alloc]initWithText:@"2次"];
    two.subArray = [NSMutableArray arrayWithArray:twoSecondsArr];
    ///3次
    NSMutableArray * threeSecondsArr = [NSMutableArray array];
    for (int i = 7; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [threeSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *three = [[CDZPickerComponentObject alloc]initWithText:@"3次"];
    three.subArray = [NSMutableArray arrayWithArray:threeSecondsArr];
    ///4次
    NSMutableArray * fourSecondsArr = [NSMutableArray array];
    for (int i = 9; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [fourSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *four = [[CDZPickerComponentObject alloc]initWithText:@"4次"];
    four.subArray = [NSMutableArray arrayWithArray:fourSecondsArr];
    ///5次
    NSMutableArray * fiveSecondsArr = [NSMutableArray array];
    for (int i = 11; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [fiveSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *five = [[CDZPickerComponentObject alloc]initWithText:@"5次"];
    five.subArray = [NSMutableArray arrayWithArray:fiveSecondsArr];
    ///6次
    NSMutableArray * sixSecondsArr = [NSMutableArray array];
    for (int i = 13; i <= 15; i ++) {
        NSString * SecondsStr = [NSString stringWithFormat:@"%d秒",i];
        CDZPickerComponentObject *Seconds = [[CDZPickerComponentObject alloc]initWithText:SecondsStr];
        [sixSecondsArr addObject:Seconds];
    }
    CDZPickerComponentObject *six = [[CDZPickerComponentObject alloc]initWithText:@"6次"];
    six.subArray = [NSMutableArray arrayWithArray:sixSecondsArr];
    ///7次
    CDZPickerComponentObject *seven = [[CDZPickerComponentObject alloc]initWithText:@"7次"];
    CDZPickerComponentObject *sevenSeconds = [[CDZPickerComponentObject alloc]initWithText:@"15秒"];
    seven.subArray = [NSMutableArray arrayWithObjects:sevenSeconds, nil];
    
    
    [CDZPicker showLinkagePickerInView:self.view withBuilder:nil components:@[one,two,three,four,five,six,seven] confirm:^(NSArray<NSString *> * _Nonnull strings, NSArray<NSNumber *> * _Nonnull indexs) {
        
        self.WanderTimes = [strings[0] substringToIndex:1];
        if (strings[1].length == 3) {
            self.inSeconds = [strings[1] substringToIndex:2];
        }else{
            self.inSeconds = [strings[1] substringToIndex:1];
        }
        
        ///设置pir徘徊监测
        [self SettingPIRmonitoring];
        
        
    }cancel:^{
        //your code
    }];
}

#pragma mark Switch点击事件
-(void)clickPirBtn:(UIButton *)sender{
    KDSLog(@"pir开关被点击2");
    NSString * sdCardStr = [[KDSDBManager sharedManager] getSdCardStatus:self.cateyeParam.deviceId];
    if ([sdCardStr isEqualToString:@"0"]) {//没有sd卡，禁止操作
        [KDSFTIndicator dismissProgress];
        [KDSFTIndicator showSuccessWithMessage:@"没有sd卡，不允许操作"];
        return;
    }
    
    /*pir功能开关*/
    if ([_thirdModel.value isEqualToString:@"1"]) {
        _thirdModel.value = @"0";
    }else{
        _thirdModel.value = @"1";
    }
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"requestingResetPwd") toView:self.view];
    [[KDSMQTTManager sharedManager] cy:self.cateye.gatewayDeviceModel setPirEnable:_thirdModel.value completion:^(NSError * _Nullable error, BOOL success) {
        if (success) {
            [hud hideAnimated:YES];
            [[KDSDBManager sharedManager] updatPirSwitch:[NSString stringWithFormat:@"%@",_thirdModel.value] deviceID:self.cateyeParam.deviceId];
            [KDSFTIndicator dismissProgress];
            [KDSFTIndicator showSuccessWithMessage:Localized(@"setSuccess")];
            
            if (self.dataSource.count>0) {
                [self.dataSource removeAllObjects];
                [self setDataSource];
            }
            [self.tableView reloadData];
        }else{
            [hud hideAnimated:YES];
            [KDSFTIndicator dismissProgress];
            [KDSFTIndicator showSuccessWithMessage:Localized(@"setFailed")];
            
        }
    }];
    
}


-(void)SettingPIRmonitoring
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"requestingResetPwd") toView:self.view];
    [[KDSMQTTManager sharedManager]cy:self.cateye.gatewayDeviceModel setPirWanderTimes:self.WanderTimes.intValue inSeconds:self.inSeconds.intValue completion:^(NSError * _Nullable error, BOOL success) {
        [MBProgressHUD hideHUD];
        if (success) {
            [hud hideAnimated:YES];
            [[KDSDBManager sharedManager] updatPirWander:[NSString stringWithFormat:@"%@,%@",self.WanderTimes,self.inSeconds] deviceID:self.cateyeParam.deviceId];
            self.cateyeParam.pirSensitivity =[NSString stringWithFormat:@"%@,%@",self.WanderTimes,self.inSeconds];
            [KDSFTIndicator dismissProgress];
            [KDSFTIndicator showSuccessWithMessage:Localized(@"setSuccess")];
            
            if (self.dataSource.count>0) {
                [self.dataSource removeAllObjects];
                [self setDataSource];
            }
            [self.tableView reloadData];
        }else{
            
            [hud hideAnimated:YES];
            [KDSFTIndicator dismissProgress];
            [KDSFTIndicator showSuccessWithMessage:Localized(@"setFailed")];
        }
    }];
}

#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.delegate = self;
            tv.dataSource = self;
            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            [tv registerClass:[KDSCatEyeMoreSettingCellTableViewCell class ] forCellReuseIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
            tv;
        });
    }
    return _tableView;
}
#pragma mark 其他

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if (oldValue == [NSNull null]) {
        if ([oldValue isKindOfClass:[NSArray class]]) {
            return @[];
        }else if([oldValue isKindOfClass:[NSDictionary class]]){
            return @{};
        }else{
            return @"";
        }
    }
    return oldValue;
}

@end
