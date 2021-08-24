//
//  CateyeSetCell.m
//  lock
//
//  Created by zhaowz on 2017/6/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "CateyeSetCell.h"
#import "CateyeSetModel.h"
#import "UIView+Extension.h"

@interface CateyeSetCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *bottomLine;

@end
@implementation CateyeSetCell


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *reuseID = @"CateyeSetCell";
    CateyeSetCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[CateyeSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
        self.slider.hidden = YES;
        self.valueLabel.hidden = YES;
    }
    return self;
}

- (void)setUI{
//    self.backgroundColor = KDSRGBColor(46, 47, 65);
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_nameLabel];
    
    _slider = [[UISlider alloc] init];
    _slider.minimumValue = 0;
    _slider.maximumValue = 100;
    _slider.value = (_slider.minimumValue + _slider.maximumValue) / 2;// 设置初始值
    [_slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    _slider.continuous = YES;// 设置可连续变化
    [self.contentView addSubview:_slider];
    
    _accessImageView = [[UIImageView alloc] init];
    _accessImageView.image = [UIImage imageNamed:@"access_right"];
    _accessImageView.contentMode = UIViewContentModeCenter;
//    _accessImageView.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:_accessImageView];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor grayColor];
//    [self.contentView addSubview:bottomLine];
    _bottomLine = bottomLine;
    
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    _valueLabel.textColor = [UIColor grayColor];
//    _valueLabel.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:_valueLabel];
    
    _switchBtn = [[UIButton alloc] init];
    [_switchBtn setImage:[UIImage imageNamed:@"btn_off.png"] forState:UIControlStateNormal];
    [_switchBtn setImage:[UIImage imageNamed:@"btn_on.png"] forState:UIControlStateSelected];
    [_switchBtn addTarget:self action:@selector(clickSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sliderValueDidChange:(UISlider *)slider{
    _valueLabel.text = [NSString stringWithFormat:@"%ld",(long)slider.value];
}

- (void)clickSwitchBtn:(UIButton *)sender{
//    sender.selected = !sender.selected;
//    if ([_model.value isEqualToString:@"1"]) {
//        _model.value = @"0";
//    }else{
//        _model.value = @"1";
//    }
}
- (void)setModel:(CateyeSetModel *)model{
    _model = model;
    _nameLabel.text = model.titleName;
    if (model.value) {
        _valueLabel.hidden = NO;
        _valueLabel.text = model.value;
    }else{
        _valueLabel.hidden = YES;
        _accessImageView.hidden = NO;
    }
    [self layoutSubviews];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    _nameLabel.x = 20;
    _nameLabel.y = 0;
    _nameLabel.height = self.height;
      CGSize size = [_nameLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:_nameLabel.font,NSFontAttributeName,nil]];

    _nameLabel.width = size.width;
    CGFloat sliderH = KDSSSALE_WIDTH(30);
    _slider.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+KDSSSALE_WIDTH(20), (self.height-sliderH)/2, KDSSSALE_WIDTH(225), sliderH);

    _bottomLine.frame = CGRectMake(0, self.height - 1, KDSScreenWidth, 1);
    CGFloat accessImageViewW = 15;
    CGFloat accessImageViewH = 60;

    _accessImageView.frame = CGRectMake(self.width-accessImageViewW -KDSSSALE_WIDTH(20), (self.height-accessImageViewH)/2,accessImageViewW , accessImageViewH);
    
    CGFloat valueLabelW = 150;
    CGFloat valueLabelX;
    if (_accessImageView.hidden == YES) {
        valueLabelX = self.width-valueLabelW -KDSSSALE_WIDTH(25);
    }else{
        valueLabelX = self.width-valueLabelW -KDSSSALE_WIDTH(45);
    }
    _valueLabel.frame = CGRectMake(valueLabelX, (self.height-accessImageViewH)/2, valueLabelW, accessImageViewH);
    _valueLabel.numberOfLines = 0;
    
    CGFloat switchBtnW = 50;
    CGFloat switchBtnH = 30;
    _switchBtn.frame = CGRectMake(self.width-accessImageViewW -KDSSSALE_WIDTH(20),(self.height-switchBtnH)/2 , switchBtnW, switchBtnH);
    
}

@end
