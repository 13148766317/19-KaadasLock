//
//  CYPhotoCell.m
//  自定义流水布局
//
//  Created by 葛聪颖 on 15/11/13.
//  Copyright © 2015年 聪颖不聪颖. All rights reserved.
//

#import "CYPhotoCell.h"

@interface CYPhotoCell()
@end

@implementation CYPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lockImg.userInteractionEnabled = NO;
    self.lockImg.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.lockImg.layer.borderWidth = 10;
}

@end
