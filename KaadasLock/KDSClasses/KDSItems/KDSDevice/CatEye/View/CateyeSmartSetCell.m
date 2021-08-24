
//
//  CateyeSmartSetCell.m
//  lock
//
//  Created by zhaowz on 2017/6/20.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "CateyeSmartSetCell.h"
#import "CateyeSetModel.h"
#import "UIView+Extension.h"

@interface CateyeSmartSetCell()

@end

@implementation CateyeSmartSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
}


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *reuseID = @"CateyeSmartSetCell";
    CateyeSmartSetCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (cell == nil) {
        cell = [[CateyeSmartSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
        
        
    }
    return self;
}
- (void)setUI{
    
    self.backgroundColor = UIColor.whiteColor;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _switchBtn = [[UIButton alloc] init];
    _titleLabel.textColor = [UIColor grayColor];
    [_switchBtn setImage:[UIImage imageNamed:@"btnNormalImg"] forState:UIControlStateNormal];
    [_switchBtn setImage:[UIImage imageNamed:@"btnSelecteImg"] forState:UIControlStateSelected];
    [_switchBtn addTarget:self action:@selector(clickSwitchBtn) forControlEvents:UIControlEventTouchUpInside];
    _switchBtn.userInteractionEnabled = YES;
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_switchBtn];
    [self.contentView addSubview:_valueLabel];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor grayColor];
    _bottomLine = bottomLine;
}

- (void)clickSwitchBtn{

    NSLog(@"开关被点击1");
    if (_delegate && [_delegate respondsToSelector:@selector(clickPirBtn)]) {
        [_delegate clickPirBtn];
    }
}

- (void)setModel:(CateyeSetModel *)model{
    _model = model;
    _titleLabel.text = model.titleName;
    if ([model.value isEqualToString:@"1"]) {
        _switchBtn.hidden = NO;
        _switchBtn.selected = YES;
        _valueLabel.hidden = YES;
    }else if ([model.value isEqualToString:@"0"]){
        _switchBtn.hidden = NO;
        _switchBtn.selected = NO;
        _valueLabel.hidden = YES;
    }else{
        _switchBtn.hidden = YES;
        _valueLabel.hidden = NO;
        _valueLabel.text = model.value;
    }
    [self layoutSubviews];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat space = 20;
    _titleLabel.frame = CGRectMake(space, 0, 180, self.height);
    CGFloat switchBtnW = 48;
    CGFloat switchBtnH = 24;
    
    _switchBtn.frame = CGRectMake(self.width - space -switchBtnW, (self.height-switchBtnH)/2, switchBtnW, switchBtnH);
    CGFloat valueLabelW = 100;
    
    _valueLabel.frame = CGRectMake(self.width - space -valueLabelW, (self.height-switchBtnH)/2, valueLabelW, switchBtnH);
    
    _bottomLine.frame = CGRectMake(0, self.height - 1, KDSScreenWidth, 1);
    
}

@end

