//
//  KDSSceneDetailStyle3Cell.m
//  KaadasLock
//
//  Created by zhaona on 2020/2/18.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSSceneDetailStyle3Cell.h"

@interface KDSSceneDetailStyle3Cell ()
///标题
@property (nonatomic,strong)UILabel * titleLb;
///添加设备按钮
@property (nonatomic,strong)UIButton * addDeviceBtn;

@end


@implementation KDSSceneDetailStyle3Cell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.titleLb = [UILabel new];
        self.titleLb.text = @"场景联动设备";
        self.titleLb.textColor = KDSRGBColor(51, 51, 51);
        self.titleLb.textAlignment = NSTextAlignmentLeft;
        self.titleLb.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.titleLb];
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.mas_equalTo(self.mas_left).offset(20);
            make.width.equalTo(@(KDSScreenWidth/2));
        }];
        self.addDeviceBtn = [UIButton new];
        [self.contentView addSubview:self.addDeviceBtn];
        [self.addDeviceBtn setBackgroundImage:[UIImage imageNamed:@"添加设备"] forState:UIControlStateNormal];
        [self.addDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@21);
            make.centerY.equalTo(self);
            make.right.mas_equalTo(self.mas_right).offset(-20);
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
