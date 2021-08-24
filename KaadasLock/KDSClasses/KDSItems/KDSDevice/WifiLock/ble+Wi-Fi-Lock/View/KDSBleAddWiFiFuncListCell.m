//
//  KDSBleAddWiFiFuncListCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/4/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSBleAddWiFiFuncListCell.h"

@implementation KDSBleAddWiFiFuncListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CGFloat height = (260 * kScreenWidth / 375.0 - 1) / 2.0;
    self.imgViewTopConstraint.constant = (height - (129 - 53)) / 53.0 * 30;
}

@end
