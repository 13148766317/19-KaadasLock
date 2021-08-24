//
//  KDSSceneDetailStyle2Cell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSceneDetailStyle2Cell.h"

@interface KDSSceneDetailStyle2Cell ()

///标题
@property (nonatomic,strong)UILabel * titleLb;
///状态按钮
@property (nonatomic,strong)UIButton * stateBtn;

@end

@implementation KDSSceneDetailStyle2Cell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.titleLb = [UILabel new];
        self.titleLb.text = @"一键关闭";
        self.titleLb.textColor = KDSRGBColor(51, 51, 51);
        self.titleLb.textAlignment = NSTextAlignmentLeft;
        self.titleLb.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.titleLb];
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.width.equalTo(@(KDSScreenWidth/2));
        }];
        self.stateBtn = [UIButton new];
        [self.contentView addSubview:self.stateBtn];
        [self.stateBtn setBackgroundImage:[UIImage imageNamed:@"on-powerStatusIcon"] forState:UIControlStateNormal];
        [self.stateBtn setBackgroundImage:[UIImage imageNamed:@"off-powerStatusIcon"] forState:UIControlStateSelected];
        [self.stateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@37);
            make.height.equalTo(@18);
            make.centerY.equalTo(self);
            make.right.mas_equalTo(self.mas_right).offset(-13);
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


@end
