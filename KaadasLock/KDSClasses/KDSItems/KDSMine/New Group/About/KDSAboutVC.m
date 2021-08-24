//
//  KDSAboutVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSAboutVC.h"
#import "KDSAboutHeardView.h"
#import "KDSAboutCell.h"
#import <KDSToolkit/KDSAppSettingsVC.h>

@interface KDSAboutVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,readwrite,strong)KDSAboutHeardView * heardView;
@property (nonatomic,readwrite,strong)UIImageView *myBgImageview;

@end

@implementation KDSAboutVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"aboutKaadas");
    [self.view addSubview:self.myBgImageview];
    [self setUI];
}

-(void)setUI
{
    self.heardView.frame = CGRectMake(0, 0, KDSScreenWidth,264);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.myBgImageview addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    self.tableView.tableHeaderView = self.heardView;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 60;
    self.tableView.sectionHeaderHeight = 10;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
   
    self.myBgImageview.userInteractionEnabled = YES;
    self.tableView.separatorInset=UIEdgeInsetsMake(0,20, 0, 20);
    [self.myBgImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
}

//MARK:点击客服电话拨打。
- (void)tapServiceTelMakeACall:(UITapGestureRecognizer *)sender
{
    NSString *number = [((UILabel *)sender.view).text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

///点击网址用Safari打开。
- (void)tapUrlOpenUrlWithSafari:(UITapGestureRecognizer *)sender
{
    NSURL *url = [NSURL URLWithString:[@"https://" stringByAppendingString:((UILabel *)sender.view).text]];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        //[[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    
    if (!cell)
    {
        cell = [[KDSAboutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSArray * titleArr = @[Localized(@"weixinPublicAccount"),Localized(@"weiboPublicAccount"),Localized(@"serviceTel"),Localized(@"InvestmentTelephone"),Localized(@"officialWebsite")];
    NSArray * detailArr = @[@"凯迪仕智能门锁",@"凯迪仕智能锁",@"400-800-5919",@"400-800-3756",@"www.kaadas.com"];
    cell.titleLabel.text = titleArr[indexPath.row];
    cell.detail.text = detailArr[indexPath.row];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    if (indexPath.row == 2) {//客服电话
    
        NSString *number = @"4008005919";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }else if (indexPath.row == 3){//招商电话
        
        NSString *number = @"4008003756";
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", number]];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
        
    }else if (indexPath.row == 4){//企业官网
        
        NSURL *url = [NSURL URLWithString:[@"http://" stringByAppendingString:@"www.kaadas.com"]];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
-(void) showDebugVC {
    DDLogInfo(@"");
    KDSAppSettingsVC *vc = [[KDSAppSettingsVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:YES completion:nil];
    
    
    vc.backBlock = ^() {
        [self dismissViewControllerAnimated:YES completion:nil];
    };
}
#pragma mark --Lazy load
- (KDSAboutHeardView *)heardView
{
    ESWeakSelf
    if (!_heardView) {
        _heardView = ({
            KDSAboutHeardView * hV = [KDSAboutHeardView new];
            hV.backgroundColor = [UIColor clearColor];
            UILongPressGestureRecognizer *tempTap = [[UILongPressGestureRecognizer alloc] initWithTarget:__weakSelf action:@selector(showDebugVC)];
            //三指，按下5秒
            tempTap.minimumPressDuration = 5;
            tempTap.numberOfTouchesRequired = 3;
            [hV addGestureRecognizer:tempTap];
            hV;
    
        });
    }
    
    return _heardView;
}

-(UIImageView *)myBgImageview
{
    if (!_myBgImageview) {
        _myBgImageview = ({
            UIImageView * myBg = [UIImageView new];
            myBg.image = [UIImage imageNamed:@"aboutUs_bg"];
            myBg;
        });
    }
    
    return _myBgImageview;
}


@end
