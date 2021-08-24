//
//  KDSAddDeviceTwoCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/11/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddDeviceTwoCell.h"

@implementation KDSAddDeviceTwoCell

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
