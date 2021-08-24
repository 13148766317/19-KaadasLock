//
//  KDSHomeRoutersVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/12/12.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSHomeRoutersVC.h"
#import "KDSHomeRoutersCell.h"

@interface KDSHomeRoutersVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray * dataSourceArray;
@property (nonatomic,strong)NSArray * titleArray;
@property (nonatomic,strong)UITableView * tableView;

@end

@implementation KDSHomeRoutersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.tableView];
    self.navigationTitleLabel.text = Localized(@"Supported home routers");
    self.titleArray = @[@"HUAWEI",@"TP-LINK",@"Mi",@"ASUS",@"Tenda",@"MERCURY",@"360",@"Netgear",@"Linksys",@"FAST",@"D-Link",@"⻜⻥星",@"TOTOLINK",@"大⻨⽆线",@"PHICOMM",@"GAOKE",@"极路由",@"乐视",@"Netcore",@"Antbang",@"Youku",@"ZTE",@"UTT",@"Buffalo",@"CMCC",@"ZyXEL",@"netis",@"TRENDnet",@"Haier",@"SITECOM",@"EnGenius",@"BELKIN",@"CISCO",@"LB-Link",@"Lenovo",@"Yueme",@"Newifi"];
    self.dataSourceArray = @[@{@"HUAWEI":@"WS860S\nHornor HiRouter"},
                             @{@"TP-LINK":@"TL-1043ND\nWDR2041N\nTL-WR866N\nTL-WR840N\nTL-WR841N\nTL-TW845N\nTL-WDR5600\nTL-WR703N\nArcher-D7b\nArcher-C9 \nTL-WDR5600\nTL-WDR4310\nTL-WDR7400"},
                             @{@"Mi":@"R1CL\nR1C \nR3P\nMI-3"},
                             @{@"ASUS":@"RT-N16\nRT-N66U\nRT-AC87U"},
                             @{@"Tenda":@"811RV2\nF6\n302R \nN318\n304R\nF9\nAC10\nAC6 \nFH456\n837R\nAC9"},
                             @{@"MERCURY":@"MW305R\nMW310R\nMW325R"},
                             @{@"360":@"P3"},
                             @{@"Netgear":@"R6220\nKWGR614\nR7000 \nR2000\nWNDR3800\nWDR3700v4\nR6300v2\nR6800 \nR6120"},
                             @{@"Linksys":@"EA6900"},
                             @{@"FAST":@"FW310\nFW450R "},
                             @{@"D-Link":@"DIR-822 \nDIR-859 \nDIR-600LW\nDIR-612\nDIR-605L\nDIR-605L \nDIR-809\nDIR-619L"},
                             @{@"⻜⻥星":@"VF35A \nVF35A "},
                             @{@"TOTOLINK":@"N301RT"},
                             @{@"大⻨⽆线":@"DW22D"},
                             @{@"PHICOMM":@"FIR300C\nK3C"},
                             @{@"GAOKE":@"Q370R "},
                             @{@"极路由":@"HC5761\nHC5761"},
                             @{@"乐视":@"LBA-047-CH"},
                             @{@"Netcore":@"737W\nAC1"},
                             @{@"Antbang":@"A3S\nA5 "},
                             @{@"Youku":@"YK-L1C\nYK-L1C"},
                             @{@"ZTE":@"E5501S"},
                             @{@"UTT":@"AW750"},
                             @{@"Buffalo":@"WHR-HP-GN\nAG300H"},
                             @{@"CMCC":@"AP218 "},
                             @{@"ZyXEL":@"NBG6617\nNBG6503"},
                             @{@"netis":@"WF2533"},
                             @{@"TRENDnet":@"TEW711BR"},
                             @{@"Haier":@"RT-A6 "},
                             @{@"SITECOM":@"WLM4600INT v"},
                             @{@"EnGenius":@"ESR350"},
                             @{@"BELKIN":@"AC1800"},
                             @{@"CISCO":@"WRVS4400N"},
                             @{@"LB-Link":@"BL-9101 \n97\nWR4000\nBL-AC886M\nBL-845R\nD9103 "},
                             @{@"Lenovo":@"R6400\nR3220"},
                             @{@"Yueme":@"HG228GI "},
                             @{@"Newifi":@"D1 \nR6830"}
    ];
    [self setUI];
}

-(void) setUI{
    
    UILabel * routerNamelb = [UILabel new];
    routerNamelb.text = @"路由器名称";
    routerNamelb.textAlignment = NSTextAlignmentCenter;
    routerNamelb.font = [UIFont systemFontOfSize:13];
    routerNamelb.textColor = KDSRGBColor(54, 54, 54);
    [self.view addSubview:routerNamelb];
    [routerNamelb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(13);
        make.height.equalTo(@15);
        make.width.equalTo(@(KDSScreenWidth/3));
        make.left.mas_equalTo(self.view.mas_left).offset(0);
    }];
    
    UILabel * routerModellb = [UILabel new];
    routerModellb.text = @"型号";
    routerModellb.textAlignment = NSTextAlignmentCenter;
    routerModellb.font = [UIFont systemFontOfSize:13];
    routerModellb.textColor = KDSRGBColor(54, 54, 54);
    [self.view addSubview:routerModellb];
    [routerModellb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(13);
        make.height.equalTo(@15);
        make.width.equalTo(@((KDSScreenWidth/3)*2));
        make.right.mas_equalTo(self.view.mas_right).offset(0);
    }];
    
}

#pragma UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSHomeRoutersCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSHomeRoutersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    NSString * titleStr = self.titleArray[indexPath.section];
    cell.titleLabel.text = titleStr;
    NSDictionary * dic = self.dataSourceArray[indexPath.section];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.lineSpacing = 10;
    paraStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@1.5f
    };
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:[dic objectForKey:titleStr] attributes:dict];
    cell.detail.attributedText = attributeStr;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * titleStr = self.titleArray[indexPath.section];
    NSDictionary * dic = self.dataSourceArray[indexPath.section];
    NSString * detailStr = [NSString stringWithFormat:@"%@",[dic objectForKey:titleStr]];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 10;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [detailStr boundingRectWithSize:CGSizeMake((kScreenWidth/3)*2, kScreenHeight)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:dict
                                       context:nil].size;

    return  size.height + 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 7;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma --Lazy load

- (UITableView *)tableView{
    
    UITableView * tb = [[UITableView alloc] initWithFrame:CGRectMake(10, 36, KDSScreenWidth-20, KDSScreenHeight-kNavBarHeight-kStatusBarHeight-36-7) style:UITableViewStyleGrouped];
    tb.dataSource = self;
    tb.delegate = self;
    tb.backgroundColor = UIColor.clearColor;
    tb.separatorStyle = NO;
    
    return tb;
}


@end
