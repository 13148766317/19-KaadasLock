//
//  KDSPIRAlarmRecordCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/13.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSPIRAlarmRecordCell.h"

@implementation KDSPIRAlarmRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
