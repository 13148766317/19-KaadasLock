//
//  CateyePIRSilenceVC.m
//  lock
//
//  Created by zhaona on 2019/4/23.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "CateyePIRSilenceVC.h"
#import "CateyePIRSilenceCell.h"
#import "CateyeSetModel.h"
#import "MBProgressHUD+MJ.h"
#import "KDSMQTT.h"
#import "CateyeSmartSetCell.h"



@interface CateyePIRSilenceVC ()<UITableViewDelegate,UITableViewDataSource,CateyeSmartSetCellDelegate>

@property (nonatomic,readwrite,strong)UITableView * tableView;
@property (nonatomic,readwrite,strong)NSMutableArray * dataSource;
///是否启动静默策略
@property (nonatomic,readwrite,strong)NSString * enable;
///监控pir周期 单位分钟
@property (nonatomic,readwrite,strong)NSString * periodtime;
///一个周期时间内触发n次
@property (nonatomic,readwrite,strong)NSString * threshold;
///保护期持续时间m分钟，
@property (nonatomic,readwrite,strong)NSString * protecttime;
///静默单位时间10分钟，每次加陪递增
@property (nonatomic,readwrite,strong)NSString * ust;
///静默时间倍增最大次数
@property (nonatomic,readwrite,strong)NSString * maxprohibition;
@property (nonatomic,readwrite,strong)CateyeSetModel * model6;
///保存按钮
@property(nonatomic,strong)UIButton * saveBtn;

@end

@implementation CateyePIRSilenceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = Localized(@"PIR silence");
    self.tableView.frame = CGRectMake(0, 0, KDSScreenWidth, 360);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.saveBtn];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-KDSSSALE_HEIGHT(50));
        make.centerX.mas_equalTo(self.view.mas_centerX).offset(0);
    }];

    ///查询静默值
    [self getPIRSilenceValue];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(242, 242, 242);
}

-(void)getPIRSilenceValue{
    
     
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait")];

    [[KDSMQTTManager sharedManager] gwGetPir:self.cateye.gw.model completion:^(NSError * _Nullable error, BOOL success, int periodtime, int threshold, int protecttime, int ust, int maxprohibition, BOOL enable) {

        [hud hideAnimated:YES];

        if (success) {
            ///监控pir周期 单位分钟
            self.periodtime = [NSString stringWithFormat:@"%d",periodtime];
            ///一个周期时间内触发n次
            self.threshold = [NSString stringWithFormat:@"%d",threshold];
            ///保护期持续时间m分钟，表示用户按下猫眼前面板按键 或者呼叫按钮，或者呼叫唤醒了一次，持续10分钟内不限制pir触发时间
            self.protecttime = [NSString stringWithFormat:@"%d",protecttime];
            ///静默单位时间10分钟，每次加陪递增
            self.ust = [NSString stringWithFormat:@"%d",ust];
            ///静默时间倍增最大次数
            self.maxprohibition = [NSString stringWithFormat:@"%d",maxprohibition];
            ///是否启动静默策略
            
            self.enable  = [NSString stringWithFormat:@"%d",enable];
            
            [self setDataSourceArr];
        }else{
            [MBProgressHUD showError:Localized(@"cateyePIRSilenceFail")];
        }
     
    }];
    
}


-(void)setDataSourceArr
{
    CateyeSetModel * model1 = [CateyeSetModel setWithName:Localized(@"PIR cycle") andValue:self.periodtime];
    CateyeSetModel * model2 = [CateyeSetModel setWithName:Localized(@"Number of triggers") andValue:self.threshold];
    CateyeSetModel * model3 = [CateyeSetModel setWithName:Localized(@"Duration") andValue:self.protecttime];
    CateyeSetModel * model4 = [CateyeSetModel setWithName:Localized(@"Unit time") andValue:self.ust];
    CateyeSetModel * model5 = [CateyeSetModel setWithName:Localized(@"Maximum times of multiplication") andValue:self.maxprohibition];
    self.model6 = [CateyeSetModel setWithName:Localized(@"Start Silence Strategy") andValue:[NSString stringWithFormat:@"%@",self.enable]];
    
    [self.dataSource removeAllObjects];
    
    [self.dataSource addObjectsFromArray:@[model1,model2,model3,model4,model5,self.model6]];
    [self.tableView reloadData];
}
#pragma mark 事件
-(void)saveBtnClick:(UIButton *)sender
{
    ///点击设置的时候调设置pir静默的API
    
    [self setPIRSilenceValue];
    
}
-(void)setPIRSilenceValue{
    
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait")];
    [[KDSMQTTManager sharedManager] gw:self.cateye.gw.model setPirEnable:self.enable.intValue withPeriod:self.periodtime.intValue threshold:self.threshold.intValue protectTime:self.protecttime.intValue ust:self.ust.intValue maxProhibit:self.maxprohibition.intValue completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
            [self setDataSourceArr];
            
        }else{
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
        
    }];
}
-(void)textFieldClick:(UITextField *)tf
{
    if (tf.text.length == 1) {
        NSString * str = [tf.text substringToIndex:1];
        if (str.intValue > 6) {
            [MBProgressHUD showError:@"只能输入小于60的数字"];
            tf.text = @"";
            return;
        }
    }
    if (tf.text.length>2) {
        [MBProgressHUD showError:@"只能输入小于60的数字"];
        tf.text = [tf.text substringToIndex:2];
        return;
    }
    switch (tf.tag) {
        case 0:
            self.periodtime = tf.text;
            break;
        case 1:
            self.threshold = tf.text;
            break;
        case 2:
            self.protecttime = tf.text;
            break;
        case 3:
            self.ust = tf.text;
            break;
        case 4:
             self.maxprohibition = tf.text;
            break;
           
        default:
            break;
    }
    
}

-(void)clickPirBtn{
    KDSLog(@"静默开关被点击2");
    if ([self.model6.value isEqualToString:@"0"]) {
         self.model6.value = @"1";
         self.enable = @"1";

    }else{
        self.model6.value = @"0";
        self.enable = @"0";
    }

    [self.tableView reloadData];
   
    
}

#pragma mark UITableviewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5) {
        CateyeSmartSetCell *scell = [CateyeSmartSetCell cellWithTableView:tableView];
        [scell setSelectionStyle:UITableViewCellSelectionStyleNone];
        scell.titleLabel.textColor = UIColor.blackColor;
        scell.model = self.dataSource[indexPath.row];
        scell.delegate = self;
        return scell;
    }else{
        CateyePIRSilenceCell *cell = [tableView dequeueReusableCellWithIdentifier:CateyePIRSilenceCell.ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.dataSource[indexPath.row];
        [cell.contentTf addTarget:self action:@selector(textFieldClick:) forControlEvents:UIControlEventEditingChanged];
        cell.contentTf.tag = indexPath.row;
        return cell;
    }
    return nil;
}

#pragma mark -- lazy load
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.delegate = self;
            tv.dataSource = self;
            tv.rowHeight = 60;
            tv.scrollEnabled = NO;
            tv.backgroundColor = UIColor.whiteColor;
            [tv registerClass:[CateyePIRSilenceCell class ] forCellReuseIdentifier:CateyePIRSilenceCell.ID];
            tv;
        });
    }
    return _tableView;
}
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource=({
            NSMutableArray * a = [NSMutableArray array];
            a;
        });
    }
    return _dataSource;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = ({
            UIButton * b = [UIButton new];
            [b setTitle:Localized(@"save") forState:UIControlStateNormal];
            b.backgroundColor = KDSRGBColor(31, 150, 247);
            [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            b.layer.cornerRadius = 22;
            [b addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            b;
        });
    }
    return _saveBtn;
}

@end
