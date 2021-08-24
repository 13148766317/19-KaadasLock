//
//  KDSHomePageLockStatusCell.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSHomePageLockStatusCell.h"

@implementation KDSHomePageLockStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUI
{
    self.dynamicImageView.backgroundColor = UIColor.clearColor;
    self.dynamicImageView.layer.masksToBounds = YES;
    self.dynamicImageView.layer.cornerRadius = self.dynamicImageView.frame.size.height/2;
    self.userNameLabel.textColor = KDSRGBColor(153, 153, 153);
    self.unlockModeLabel.textColor = KDSRGBColor(153, 153, 153);
    self.topLine.backgroundColor = KDSRGBColor(165, 165, 165);
    self.bottomLine.backgroundColor = KDSRGBColor(165, 165, 165);
    self.timerLabel.textColor = KDSRGBColor(153, 153, 153);
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

@end
