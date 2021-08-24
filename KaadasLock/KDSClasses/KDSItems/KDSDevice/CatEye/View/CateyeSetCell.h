//
//  CateyeSetCell.h
//  lock
//
//  Created by zhaowz on 2017/6/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CateyeSetModel;
@protocol CateyeSetCellDelegate <NSObject>

- (void)clickPirBtn;
@end
@interface CateyeSetCell : UITableViewCell
@property (nonatomic, strong) UIImageView *accessImageView; //右箭头
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;         
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) CateyeSetModel *model;

@property (nonatomic, weak) id <CateyeSetCellDelegate> delegate;
+ (instancetype )cellWithTableView:(UITableView *)tableView;

@end
