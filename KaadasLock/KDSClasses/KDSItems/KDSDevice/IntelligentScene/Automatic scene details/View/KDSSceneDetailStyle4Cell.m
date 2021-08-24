//
//  KDSSceneDetailStyle4Cell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSceneDetailStyle4Cell.h"

@interface KDSSceneDetailStyle4Cell ()

@property (nonatomic,strong)UIImageView * tipsIconImg;
///设备名称
@property (nonatomic,strong)UILabel * tipsNameLb;
///房间位置标签
@property (nonatomic,strong)UILabel * positionMarkLb;
///房间具体位置
@property (nonatomic,strong)UILabel * positionLb;
///零火开关状态的按钮
@property (nonatomic,strong)UIButton * powerStateBtn;
///分割线
@property(nonatomic,strong)UIView * line;
///安全模式的标签
@property(nonatomic,strong)UIButton * securityModeLb;
///反锁模式的标签
@property(nonatomic,strong)UIButton * antiLockModeLb;
///布防模式的标签
@property(nonatomic,strong)UIButton * defenseModeLb;

@end

@implementation KDSSceneDetailStyle4Cell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.tipsIconImg = [UIImageView new];
        self.tipsIconImg.image = [UIImage imageNamed:@"danPTimingIconImg"];
        [self.contentView addSubview:self.tipsIconImg];
        [self.tipsIconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@25);
            make.left.mas_equalTo(self.mas_left).offset(15);
            make.top.mas_equalTo(self.mas_top).offset(6);
        }];
        self.powerStateBtn = [UIButton new];
        [self.powerStateBtn setBackgroundImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateNormal];
        [self.powerStateBtn setBackgroundImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateSelected];
        [self.powerStateBtn addTarget:self action:@selector(powerStateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.powerStateBtn];
        [self.powerStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@37);
            make.height.equalTo(@18);
            make.top.mas_equalTo(self.mas_top).offset(9);
            make.right.mas_equalTo(self.mas_right).offset(-13);
        }];
        self.tipsNameLb = [UILabel new];
        self.tipsNameLb.text = @"门 锁";
        self.tipsNameLb.textColor = KDSRGBColor(51, 51, 51);
        self.tipsNameLb.font = [UIFont systemFontOfSize:13];
        self.tipsNameLb.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.tipsNameLb];
        [self.tipsNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(12);
            make.left.mas_equalTo(self.mas_left).offset(50);
            make.right.mas_equalTo(self.powerStateBtn.mas_left).offset(-20);
            make.height.equalTo(@15);
        }];
        self.line = [UIView new];
        self.line.backgroundColor = KDSRGBColor(234, 233, 233);
        [self.contentView addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(-40);
            make.left.mas_equalTo(self.mas_left).offset(10);
            make.right.mas_equalTo(self.mas_right).offset(-5);
            make.height.equalTo(@1);
        }];
        self.positionMarkLb = [UILabel new];
        self.positionMarkLb.text = @"房间位置";
        self.positionMarkLb.textAlignment = NSTextAlignmentLeft;
        self.positionMarkLb.textColor = KDSRGBColor(51, 51, 51);
        self.positionMarkLb.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.positionMarkLb];
        [self.positionMarkLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(50);
            make.width.equalTo(@((KDSScreenWidth-65)/2));
            make.bottom.mas_equalTo(self.line.mas_bottom).offset(-10);
            make.height.equalTo(@15);
        }];
        self.positionLb = [UILabel new];
        self.positionLb.text = @"客厅";
        self.positionLb.textColor = KDSRGBColor(133, 133, 133);
        self.positionLb.font = [UIFont systemFontOfSize:12];
        self.positionLb.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.positionLb];
        [self.positionLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).offset(-10);
            make.bottom.mas_equalTo(self.line.mas_bottom).offset(-10);
            make.width.equalTo(@((KDSScreenWidth-65)/2));
            make.height.equalTo(@15);
        }];
        
        self.securityModeLb = [UIButton new];
        [self.securityModeLb setTitle:@"安全模式" forState:UIControlStateNormal];
        [self.securityModeLb setTitleColor:KDSRGBColor(133, 133, 133) forState:UIControlStateNormal];
        self.securityModeLb.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.securityModeLb];
        [self.securityModeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.line);
            make.bottom.equalTo(self);
            make.width.equalTo(@(KDSScreenWidth/3));
        }];
        self.antiLockModeLb = [UIButton new];
        [self.antiLockModeLb setTitle:@"反 锁" forState:UIControlStateNormal];
        [self.antiLockModeLb setTitleColor:KDSRGBColor(133, 133, 133) forState:UIControlStateNormal];
        self.antiLockModeLb.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.antiLockModeLb];
        [self.antiLockModeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.securityModeLb.mas_right);
            make.top.equalTo(self.line);
            make.bottom.equalTo(self);
            make.width.equalTo(@(KDSScreenWidth/3));
        }];
        self.defenseModeLb = [UIButton new];
        [self.defenseModeLb setTitle:@"布防模式" forState:UIControlStateNormal];
        [self.defenseModeLb setTitleColor:KDSRGBColor(133, 133, 133) forState:UIControlStateNormal];
        self.defenseModeLb.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.defenseModeLb];
        [self.defenseModeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.line);
            make.bottom.equalTo(self);
            make.width.equalTo(@(KDSScreenWidth/3));
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame
{
    frame.origin.y += 10;
    frame.size.height -= 10;
    [super setFrame:frame];
}

-(void)powerStateBtnClick:(UIButton *)sender
{
    
}

@end
