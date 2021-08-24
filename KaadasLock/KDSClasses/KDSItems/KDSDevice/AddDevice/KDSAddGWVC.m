//
//  KDSAddGWVC.m
//  
//
//  Created by zhaona on 2019/5/5.
//

#import "KDSAddGWVC.h"
#import "KDSAddGWCell.h"
#import "KDSAddGWVCOne.h"
#import "MBProgressHUD+MJ.h"

@interface KDSAddGWVC ()

@property(nonatomic,readwrite,strong)NSArray * deviceImgArr;
@property(nonatomic,readwrite,strong)NSArray * titleNameArr;

@end

@implementation KDSAddGWVC

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
    
    self.deviceImgArr = @[@"Gateway_pic",@"6030GW"];
    self.titleNameArr = @[Localized(@"CatEyeByGw"),Localized(@"6030 GateWay")];
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
    cell.deviceImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", self.deviceImgArr[indexPath.row]]];
    cell.deviceNameLb.text = [NSString stringWithFormat:@"%@",self.titleNameArr[indexPath.row]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.item) {
        case 0:///添加猫眼网关
        {
            KDSAddGWVCOne *vc = [[KDSAddGWVCOne alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:///6030网关
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.removeFromSuperViewOnHide = YES;
            hud.mode = MBProgressHUDModeText;
            hud.labelText = Localized(@"This function is not yet open");
            [hud hideAnimated:YES afterDelay:2];
        }
            break;
            
        default:
            break;
    }
}

@end
