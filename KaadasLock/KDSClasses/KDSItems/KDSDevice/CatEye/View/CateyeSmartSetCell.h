//
//  CateyeSmartSetCell.h
//  lock
//
//  Created by zhaowz on 2017/6/20.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CateyeSetModel;
@protocol CateyeSmartSetCellDelegate <NSObject>

- (void)clickPirBtn;
@end
@interface CateyeSmartSetCell : UITableViewCell
@property (nonatomic, strong) CateyeSetModel *model;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *switchBtn;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, weak) id <CateyeSmartSetCellDelegate> delegate;

+ (instancetype )cellWithTableView:(UITableView *)tableView;

@end
