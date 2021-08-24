//
//  KDSAMModeSpecificationVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/16.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSAMModeSpecificationVC.h"

@interface KDSAMModeSpecificationVC ()

@end

@implementation KDSAMModeSpecificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = self.title;
    
    UIImage *image = [UIImage imageNamed:@"deviceLockAMMode"];
    UIImageView *specificationIV = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:specificationIV];
    
    UILabel *specificationLabel = [[UILabel alloc] init];
    NSString *specification = Localized(@"A/MModeSpecification");
    UIFont *font = [UIFont systemFontOfSize:kScreenHeight < 667 ? 13 : 15];
    specificationLabel.text = specification;
    specificationLabel.font = font;
    specificationLabel.textColor = KDSRGBColor(0x14, 0x14, 0x14);
    specificationLabel.textAlignment = NSTextAlignmentCenter;
    specificationLabel.numberOfLines = 0;
    CGRect rect = [specification boundingRectWithSize:CGSizeMake(kScreenWidth - 20, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    rect.size.width = kScreenWidth - 20;
    rect.size.height = ceil(rect.size.height);
    [self.view addSubview:specificationLabel];
    
    //V:[70-40-70]比例
    CGFloat top = (kScreenHeight - kStatusBarHeight - kNavBarHeight - image.size.height - rect.size.height) / 18 * 7;
    specificationIV.frame = (CGRect){(kScreenWidth - image.size.width) / 2.0, top, image.size};
    rect.origin.x = 10;
    rect.origin.y = CGRectGetMaxY(specificationIV.frame) + top * 4 / 7;
    specificationLabel.frame = rect;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
