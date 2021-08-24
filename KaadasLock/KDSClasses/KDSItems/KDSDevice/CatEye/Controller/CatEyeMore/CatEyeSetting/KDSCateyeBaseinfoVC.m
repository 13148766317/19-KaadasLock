//
//  KDSCateyeBaseinfoVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCateyeBaseinfoVC.h"
#import "KDSCatEyeMoreSettingCellTableViewCell.h"
#import "CateyeSetModel.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "KDSDBManager.h"
//#import "MJExtension.h"
#import "KDSGWCateyeParam.h"



@interface KDSCateyeBaseinfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UITableView * tableView;

@end

@implementation KDSCateyeBaseinfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    self.navigationTitleLabel.text = Localized(@"deviceInfo");
    self.view.backgroundColor = KDSPublicBackgroundColor;
    
    CateyeSetModel *model9 = [CateyeSetModel setWithName:@"序列号" andValue:self.cateyeParam.deviceId];
    CateyeSetModel *model1 = [CateyeSetModel setWithName:Localized(@"swVer") andValue:self.cateyeParam.swVer];
    CateyeSetModel *model2 = [CateyeSetModel setWithName:Localized(@"hwVer") andValue:self.cateyeParam.hwVer];
    CateyeSetModel *model3 = [CateyeSetModel setWithName:Localized(@"mcuVer") andValue:self.cateyeParam.mcuVer];
    CateyeSetModel *model4 = [CateyeSetModel setWithName:Localized(@"t200Ver") andValue:self.cateyeParam.t200Ver];
    CateyeSetModel *model5 = [CateyeSetModel setWithName:Localized(@"macaddr") andValue:self.cateyeParam.macaddr];
    CateyeSetModel *model6 = [CateyeSetModel setWithName:Localized(@"ipaddr") andValue:self.cateyeParam.ipaddr];
    CateyeSetModel *model7 = [CateyeSetModel setWithName:Localized(@"wifiStrength") andValue:[NSString stringWithFormat:@"%d",self.cateyeParam.wifiStrength]];
    
    [self.dataArray addObjectsFromArray:@[model9,model1,model2,model3,model4,model5,model6,model7]];
    
    
    [self setTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

-(void)setTableView{
   
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
        
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
    cell.rightArrowImg.hidden = YES;
    [cell.rightArrowImg mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(1);
        make.right.mas_equalTo(cell.mas_right).offset(0);
        make.centerY.mas_equalTo(cell.mas_centerY).offset(0);
    }];
    cell.model = self.dataArray[indexPath.row];
    
    
    return cell;
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
            tv.scrollEnabled = NO;
            tv.rowHeight = 60;
            [tv registerClass:[KDSCatEyeMoreSettingCellTableViewCell class ] forCellReuseIdentifier:KDSCatEyeMoreSettingCellTableViewCell.ID];
            tv;
        });
    }
    return _tableView;
}

- (NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        
        ///进入到这个页面的时候查询下猫眼的sd状态
//        [self getSdCardStatus];
        
    }
    return _dataArray;
}

@end
