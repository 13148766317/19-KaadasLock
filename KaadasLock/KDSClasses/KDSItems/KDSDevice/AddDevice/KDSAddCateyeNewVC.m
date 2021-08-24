//
//  KDSAddCateyeNewVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/5.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSAddCateyeNewVC.h"
#import "KDSAddGWCell.h"
#import "KDSMQTT.h"
#import "KDSAddGWVCOne.h"
#import "KDSBindingGatewayVC.h"

@interface KDSAddCateyeNewVC ()

@property(nonatomic,readwrite,strong)NSArray * deviceImgArr;
@property(nonatomic,readwrite,strong)NSArray * titleNameArr;

@end

@implementation KDSAddCateyeNewVC

static NSString * const reuseIdentifier = @"Cell";

-(instancetype)init{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat width = (KDSScreenWidth-90)/2;
    CGFloat height = (KDSScreenHeight-264)/3;
    
    layout.itemSize = CGSizeMake(width, height);
    // 设置最小行间距
    layout.minimumLineSpacing = 0;
    // 设置垂直间距
    layout.minimumInteritemSpacing = 0;
    // 设置边缘的间距，默认是{0，0，0，0}
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    return [self initWithCollectionViewLayout:layout];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Register cell classes
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSAddGWCell class]) bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    if (self.gateways.count != [KDSUserManager sharedManager].gateways.count) {
        self.gateways = [KDSUserManager sharedManager].gateways;
    }
    self.deviceImgArr = @[@"cateye_pic"];
    self.titleNameArr = @[Localized(@"KaadasCateye")];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.deviceImgArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KDSAddGWCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = UIColor.clearColor;
    cell.deviceImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",self.deviceImgArr[indexPath.row]]];
    cell.deviceNameLb.text = [NSString stringWithFormat:@"%@",self.titleNameArr[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.item) {
        case 0:///添加Kaadas 猫眼
        {
            [self backUpZigBeeConfigureWithFromStrValue:2];
        }
            break;
       
            
        default:
            break;
    }
}
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


@end
