//
//  KDSIntelligentDetailVC.m
//  KaadasLock
//
//  Created by zhaona on 2020/1/10.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSIntelligentDetailVC.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "CateyeSetModel.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSDBManager.h"
#import "UIView+Extension.h"


@interface KDSIntelligentDetailVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UITableView * tableView;
///删除设备
@property(nonatomic,strong)UIButton * delGWBtn;

@end

@implementation KDSIntelligentDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.view.backgroundColor = KDSPublicBackgroundColor;
    [self setDataSource];
    [self setUI];
    
}

-(void)setDataSource
{
    CateyeSetModel *model1 = [CateyeSetModel setWithName:Localized(@"deviceName") andValue:@"零火单键开关"];
    CateyeSetModel *model2 = [CateyeSetModel setWithName:Localized(@"Room location") andValue:@"100平米大阳台"];
    CateyeSetModel *model3 = [CateyeSetModel setWithName:Localized(@"deviceModel") andValue:@"GDFTFT"];
    CateyeSetModel *model4 = [CateyeSetModel setWithName:Localized(@"deviceId") andValue:@"GW6030-0.0.5"];
    CateyeSetModel *model5 = [CateyeSetModel setWithName:Localized(@"ipaddr") andValue:@"125.02.0365.0"];
    CateyeSetModel *model6 = [CateyeSetModel setWithName:Localized(@"firmwareVer") andValue:@"已是最新版本"];
    CateyeSetModel *model7 = [CateyeSetModel setWithName:Localized(@"Binding time") andValue:@"2020/01/03"];
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:@[model1,model2,model3,model4,model5,model6,model7]];
   
}

-(void)setUI{
    
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.delGWBtn];
    
    [self.delGWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-45);
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.delGWBtn.mas_top).offset(-40);
    }];
}

#pragma mark UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyeMoreSettingCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 5) {
        [cell.rightArrowImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@6.4);
            make.height.equalTo(@11.3);
            make.right.mas_equalTo(cell.mas_right).offset(-10);
            make.centerY.mas_equalTo(cell.mas_centerY).offset(0);
        }];
    }else{
        [cell.rightArrowImg mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(1);
            make.right.mas_equalTo(cell.mas_right).offset(0);
            make.centerY.mas_equalTo(cell.mas_centerY).offset(0);
        }];
    }
    if (indexPath.row == 0|| indexPath.row == 1 || indexPath.row == 5) {
        cell.rightArrowImg.hidden = NO;
    }else{
        cell.rightArrowImg.hidden = YES;
    }
    cell.model = self.dataArray[indexPath.row];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self changeGwNickName];
            break;
            
        default:
            break;
    }
}

#pragma mark 点击事件
-(void)delClick:(UIButton *)sender
{
     UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:Localized(@"ensureDeleteDevice") message:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        //修改按钮
        [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"deviceDeleteAfter\nRestoreEquipmentfactorySettings")];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alerVC setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        
        [alerVC addAction:cancle];
        [alerVC addAction:ok];
        [self presentViewController:alerVC animated:YES completion:nil];
    
}

///更改设备名称
-(void)changeGwNickName
{
    UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:@"请输入设备名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    __weak typeof(self) ws = self;
    //定义第一个输入框；
    [alerVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
        textField.textAlignment = NSTextAlignmentLeft;
        textField.textColor = KDSRGBColor(199, 199, 204);
        textField.font = [UIFont systemFontOfSize:12];
        [textField addTarget:ws action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    //修改按钮
    [cancle setValue:KDSRGBColor(51, 51, 51) forKey:@"titleTextColor"];
    [alerVC addAction:cancle];
    [alerVC addAction:ok];
    [self presentViewController:alerVC animated:YES completion:nil];
    
}

///密码昵称文本输入框，长度不能超过16
- (void)textFieldTextDidChange:(UITextField *)sender
{
    [sender trimTextToLength:-1];
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
//            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            tv.backgroundColor = UIColor.clearColor;
            [tv registerClass:[KDSCatEyeMoreSettingCellTableViewCell class ] forCellReuseIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
            tv;
        });
    }
    return _tableView;
}

- (UIButton *)delGWBtn
{
    if (!_delGWBtn) {
        _delGWBtn = [UIButton new];
        [_delGWBtn setTitle:Localized(@"deleteDevice") forState:UIControlStateNormal];
        [_delGWBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _delGWBtn.backgroundColor = KDSRGBColor(255, 59, 48);
        _delGWBtn.layer.masksToBounds = YES;
        _delGWBtn.layer.cornerRadius = 22;
        [_delGWBtn addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _delGWBtn;
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
