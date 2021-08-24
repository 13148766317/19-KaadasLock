//
//  KDSAddDeviceVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/6/25.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//
#import "KDSAddDeviceVC.h"
#import "SYAlertView.h"
#import "KDSAddGWVCOne.h"
#import "KDSAddCateyeNewVC.h"
#import "KDSBindingGatewayVC.h"
#import "KDSBleBindVC.h"
#import <AVFoundation/AVFoundation.h>
#import "KDSAddDeviceListCell.h"
#import "KDSAddRYGWVC.h"
#import "KDSAddZeroFireSingleStep1VC.h"
#import "RHScanViewController.h"
#import "KDSAddWiFiLockFatherVC.h"
#import "KDSAddDeviceFirstCell.h"
#import "KDSAddDeviceTwoCell.h"
#import "KDSAddVideoWifiLockStep1VC.h"
#import "KDSAddNewWiFiLockStep1VC.h"
#import "KDSAddSmartHangerMainVC.h"

static NSString * const deviceListCellId = @"deviceListCellId";
static NSString * const deviceFirstCellId = @"deviceFirstCellId";
static NSString * const deviceTwoCellId = @"deviceTwoCellId";
@interface KDSAddDeviceVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
///用来展示设备列表的cell
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///点击添加锁的弹出视图
//@property (nonatomic,strong)KDSAddLockActionSheetView * actionSheetView;
@property (nonatomic,strong)SYAlertView *alertView;
///当前热卖锁型号
@property (nonatomic,strong)NSArray * firstDeviceNameArray;
///当前热卖锁图片
@property (nonatomic,strong)NSArray * firstDeviceImgArray;
///选择智能锁类型
@property (nonatomic,strong)NSArray * twoDeviceNameArray;
///选择智能锁类型锁图片
@property (nonatomic,strong)NSArray * twoDeviceImgArray;
///其他智能设备
@property (nonatomic,strong)NSArray * threeDeviceNameArray;
///其他智能设备图片
@property (nonatomic,strong)NSArray * threeDeviceImgArray;

@end

@implementation KDSAddDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"addDevice");
    [self.view addSubview:self.collectionView];
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceListCell class]) bundle:nil] forCellWithReuseIdentifier:deviceListCellId];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceFirstCell class]) bundle:nil] forCellWithReuseIdentifier:deviceFirstCellId];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceTwoCell class]) bundle:nil] forCellWithReuseIdentifier:deviceTwoCellId];
    
    
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceListCell class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:deviceListCellId];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceFirstCell class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:deviceFirstCellId];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddDeviceTwoCell class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:deviceTwoCellId];
    
    self.firstDeviceNameArray = @[@"K20-V\n可视猫眼智能锁",@"K11 Face\n     ",@"兰博基尼传奇\n3D人脸识别智能锁"];
    self.firstDeviceImgArray = @[@"equipment_k20v",@"equipment_k11face",@"equipment_3d"];
    self.twoDeviceNameArray = @[@"视频锁",@"人脸锁",@"WiFi锁",@"蓝牙锁",@"网关锁"];
    self.twoDeviceImgArray = @[@"equipment_video",@"equipment_face",@"addDoorLockSuit",@"addBleLockIcon",@"addZigBeeLockIcon"];
    self.threeDeviceNameArray = @[@"晾衣机",@"猫 眼",@"GW6032",@"GW6010"];
    self.threeDeviceImgArray  = @[@"smart_hanger_small",@"cateye_pic",@"GW6030Img",@"GW6010Img"];
    
    UIButton *scancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    scancleBtn.frame = CGRectMake(KDSScreenWidth - 44, kStatusBarHeight, 44, 44);
    scancleBtn.backgroundColor = UIColor.clearColor;
    [scancleBtn.widthAnchor constraintEqualToConstant:30].active = YES;
    [scancleBtn.heightAnchor constraintEqualToConstant:30].active = YES;
    [scancleBtn setImage:[UIImage imageNamed:@"scancleBlackImg"] forState:UIControlStateNormal];
    [scancleBtn addTarget:self action:@selector(scancleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:scancleBtn];

    [self setUI];
    
}

- (void)viewWillAppear:(BOOL)animated{
 [super  viewWillAppear:animated];
 [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark  监听侧滑事件
- (void)willMoveToParentViewController:(UIViewController*)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent) {
        NSLog(@"zhuxioakai -----开始侧滑");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)didMoveToParentViewController:(UIViewController*)parent
{
    [super didMoveToParentViewController:parent];
    
    if(!parent){
        NSLog(@"离开了页面");
    }
}

#pragma mark 重写返回按钮的方法
- (void)navBackClick{
    
    NSLog(@"KDSAddDeviceVC --- 添加也的范返回按钮");
    // 关闭当前视图
    [self.navigationController  popToRootViewControllerAnimated:YES];
}


-(void)setUI{
  
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(15);
        make.right.mas_equalTo(self.view.mas_right).offset(-15);
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kBottomSafeHeight);
    }];
    
}
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

#pragma mark - getter

- (SYAlertView *)alertView
{
    if (_alertView == nil) {
        _alertView = [[SYAlertView alloc] init];
        _alertView.isAnimation = YES;
        _alertView.userInteractionEnabled = YES;
    }
    return _alertView;
}
#pragma mark 点击事件

-(void)scancleBtnAction:(UIButton *)sender
{
    ///鉴权相机权限
    RHScanViewController *vc = [RHScanViewController new];
    vc.isOpenInterestRect = YES;
    vc.isVideoZoom = YES;
    vc.fromWhereVC = @"AddDeviceVC";//添加设备
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark:内部调用

-(void)backUpZigBeeConfigureWithFromStrValue:(NSUInteger)fromStrValue
{
    ///用来判断当前用户是否绑定网关
    ///如果用户绑定过网关才可以进行绑定猫眼和锁
    if (self.gateways.count >0) {
        KDSBindingGatewayVC * bindGatewayVC = [KDSBindingGatewayVC new];
        bindGatewayVC.fromStrValue = fromStrValue;
        [self.navigationController pushViewController:bindGatewayVC animated:YES];
    }else{
        ///反之提醒用户去设置网关
        
        UIAlertController * aler = [UIAlertController alertControllerWithTitle:Localized(@"NoZigBeeGatewayAvailable") message:Localized(@"addZigBeeSettingsnYouNeedConfigureGatewayConfiguringIt") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * ok = [UIAlertAction actionWithTitle:Localized(@"ToConfigure") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ///点击配置网关
            
            KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }];
        UIAlertAction * cancle = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        
        //修改message
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:Localized(@"addZigBeeSettingsnYouNeedConfigureGatewayConfiguringIt")];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:KDSRGBColor(153, 153, 153) range:NSMakeRange(0, alertControllerMessageStr.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, alertControllerMessageStr.length)];
        [aler setValue:alertControllerMessageStr forKey:@"attributedMessage"];
        [cancle setValue:[UIColor blackColor] forKey:@"_titleTextColor"];
        [aler addAction:cancle];
        [aler addAction:ok];
        [self presentViewController:aler animated:YES completion:nil];
        
    }
    
}

#pragma mark Lazy --load
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = KDSRGBColor(248, 248, 248);
        layout.headerReferenceSize = CGSizeMake(KDSScreenWidth, 60);
        [_collectionView flashScrollIndicators];
    }
    return _collectionView;
}

#pragma mark UICollecionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if (section == 0) {
        return self.firstDeviceNameArray.count;
    }else if (section == 1){
        return self.twoDeviceNameArray.count;
    }else{
        return self.threeDeviceNameArray.count;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        KDSAddDeviceFirstCell * firstCell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceFirstCellId forIndexPath:indexPath];
        firstCell.lockDevNameLb.text = self.firstDeviceNameArray[indexPath.row];
        firstCell.lockPickIconImg.image = [UIImage imageNamed:self.firstDeviceImgArray[indexPath.row]];
        return firstCell;
    }else if (indexPath.section == 1){
        KDSAddDeviceTwoCell * twoCell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceTwoCellId forIndexPath:indexPath];
        twoCell.lockTwoDevNameLb.text = self.twoDeviceNameArray[indexPath.row];
        twoCell.lockTwoImg.image = [UIImage imageNamed:self.twoDeviceImgArray[indexPath.row]];
        return twoCell;
    }
    KDSAddDeviceListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceListCellId forIndexPath:indexPath];
    cell.deviceNameLb.text = self.threeDeviceNameArray[indexPath.row];
    cell.deviceNameImg.image = [UIImage imageNamed:self.threeDeviceImgArray[indexPath.row]];
//    cell.line.hidden = (indexPath.row + 1) % 3 == 0 ? YES : NO;
    cell.line.hidden = YES;
    return cell;

}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return CGSizeMake((KDSScreenWidth-60) / 3.0, 202);
    }else if (indexPath.section == 1){
        if (indexPath.row == 0 || indexPath.row == 1) {
            return CGSizeMake((KDSScreenWidth-38) / 2.0, 86);
        }else{
            return CGSizeMake((KDSScreenWidth-46) / 3.0, 86);
        }
    }else if (indexPath.section == 2){
        return CGSizeMake((KDSScreenWidth-46) / 3.0, 86);
    }
    return CGSizeMake(0, 0);
}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 7;
}
// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
#pragma mark - 视图内容
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    // 视图添加到 UICollectionReusableView 创建的对象中
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            UICollectionReusableView *firstHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:deviceFirstCellId forIndexPath:indexPath];
            firstHeaderView.backgroundColor = UIColor.clearColor;
            UIView * supview = [UIView new];
            supview.backgroundColor = UIColor.clearColor;
            [firstHeaderView addSubview:supview];
            [supview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.top.right.equalTo(firstHeaderView);
            }];
            UILabel * timeLb = [UILabel new];
            timeLb.font = [UIFont systemFontOfSize:15];
            timeLb.textColor = KDSRGBColor(102, 102, 102);
            timeLb.textAlignment = NSTextAlignmentLeft;
            [supview addSubview:timeLb];
            [timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(firstHeaderView.mas_left).offset(15);
                make.right.equalTo(firstHeaderView.mas_right).offset(-15);
                make.bottom.equalTo(firstHeaderView.mas_bottom).offset(-5);
                make.height.equalTo(@30);
            }];
            timeLb.text = @"添加智能锁";
            return firstHeaderView;
        }
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:deviceListCellId forIndexPath:indexPath];
        headerView.backgroundColor = UIColor.clearColor;
        UIView * supview = [UIView new];
        supview.backgroundColor = UIColor.clearColor;
        [headerView addSubview:supview];
        [supview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.top.right.equalTo(headerView);
        }];
        UILabel * timeLb = [UILabel new];
        timeLb.font = [UIFont systemFontOfSize:15];
        timeLb.textColor = KDSRGBColor(102, 102, 102);
        timeLb.textAlignment = NSTextAlignmentLeft;
        [supview addSubview:timeLb];
        [timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView.mas_left).offset(15);
            make.right.equalTo(headerView.mas_right).offset(-15);
            make.bottom.equalTo(headerView.mas_bottom).offset(-5);
            make.height.equalTo(@30);
        }];
        
        if (indexPath.section == 1) {
            timeLb.text = @"选择智能锁类型";
        }else{
            timeLb.text = @"其他智能设备";
        }
        
        return headerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                //K20-V 可视猫眼智能锁
                KDSAddVideoWifiLockStep1VC * vc = [KDSAddVideoWifiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            case 2:
            {
                //K11 Faces   需要重新调试
                KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
            {
                //视频锁
                //video+wifi
                KDSAddVideoWifiLockStep1VC * vc = [KDSAddVideoWifiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {
                //人脸锁重新调试
                KDSAddNewWiFiLockStep1VC * vc = [KDSAddNewWiFiLockStep1VC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 2:
            {
                //WiFi锁
                KDSAddWiFiLockFatherVC * vc = [KDSAddWiFiLockFatherVC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 3:
            {
                //蓝牙锁
                KDSBleBindVC *vc = [KDSBleBindVC new];
                vc.step = 0;
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 4:
                //网关锁
                [self backUpZigBeeConfigureWithFromStrValue:3];
                
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 2){
        
        switch (indexPath.row) {
            case 0:
            {    //添加晾衣机
                KDSAddSmartHangerMainVC * vc = [KDSAddSmartHangerMainVC new];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:
            {   //猫眼
                [self backUpZigBeeConfigureWithFromStrValue:2];
            }
                break;
            case 2:
            case 3:
            {
                //网关
                KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
    }
}


@end
