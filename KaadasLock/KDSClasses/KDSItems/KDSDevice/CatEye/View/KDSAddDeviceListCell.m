//
//  KDSAddDeviceListCell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/11.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddDeviceListCell.h"

@implementation KDSAddDeviceListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = UIColor.whiteColor;
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.06].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,3);
    self.layer.shadowRadius = 13;
    self.layer.shadowOpacity = 1;
    self.layer.cornerRadius = 4;
    
}

@end
