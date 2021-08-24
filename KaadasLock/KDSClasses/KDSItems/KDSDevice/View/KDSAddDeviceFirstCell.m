//
//  KDSAddDeviceFirstCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/11/2.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAddDeviceFirstCell.h"

@implementation KDSAddDeviceFirstCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = UIColor.whiteColor;
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.06].CGColor;
    self.layer.shadowRadius = 13;
    self.layer.shadowOpacity = 1;
    self.layer.cornerRadius = 5;
    self.layer.shadowOffset = CGSizeMake(0,3);
    [self setLabelSpace:self.lockDevNameLb withSpace:5 withFont:[UIFont systemFontOfSize:11]];
    
}

-(void)setLabelSpace:(UILabel*)label withSpace:(CGFloat)space withFont:(UIFont*)font  {
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentCenter;
    paraStyle.lineSpacing = space; //设置行间距
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paraStyle, NSKernAttributeName:@0.0f};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:label.text attributes:dic];
    label.attributedText = attributeStr;
}

@end
