//
//  KDSVisitorsRecordCell.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSVisitorsRecordCell.h"
#import<QuartzCore/QuartzCore.h>
#import<Accelerate/Accelerate.h>

@implementation KDSVisitorsRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.visitorsHeadPortraitIconImg.contentMode = UIViewContentModeScaleAspectFit;
    self.visitorsHeadPortraitIconImg.userInteractionEnabled = NO;
    double Degree=90.0/180.0;
    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI* Degree);
    self.visitorsHeadPortraitIconImg.transform = transform;//旋转
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(whenClickImage)];
    [self.visitorsHeadPortraitIconImg addGestureRecognizer:singleTap];

}
///点击播放按钮
- (IBAction)playBtn:(id)sender {
    !_playBtnClickBlock ?: _playBtnClickBlock();
}

- (void)whenClickImage
{
    !_playBtnClickBlock ?: _playBtnClickBlock();
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
