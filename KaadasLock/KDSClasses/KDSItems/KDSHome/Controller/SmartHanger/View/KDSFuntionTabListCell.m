//
//  KDSFuntionTabListCell.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/28.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSFuntionTabListCell.h"

@interface KDSFuntionTabListCell ()

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UILabel *funtablabel;

@property (nonatomic, strong) UILabel *labelCountDown;

@end
@implementation KDSFuntionTabListCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}


- (void)setupUI{
    [self.contentView  addSubview:self.coverImageView];
    [self.contentView addSubview:self.labelCountDown];
    [self.contentView  addSubview:self.funtablabel];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       // make.top.right.left.equalTo(self.contentView);
        make.height.width.equalTo(@62);
        make.centerX.equalTo(self.contentView);
        
    }];
    
    [self.labelCountDown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@62);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.funtablabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.height.equalTo(@17);
        make.bottom.equalTo(self.contentView).offset(0);
    }];
}

 //  数据填充
- (void)setupData:(KDSFuntionTabModel *)data {
    self.funtablabel.text = data.funtabtitle;
    //[self.coverImageView sd_setImageWithURL:[NSURL URLWithString:data.images]];
    self.coverImageView.image = [UIImage  imageNamed:data.imageName];
    if (data.countdown>0) {
        self.labelCountDown.hidden = NO;
        self.labelCountDown.text = [self formatMinute:data.countdown];
    }else {
        self.labelCountDown.hidden = YES;
    }
}


-(NSString *) formatMinute:(NSUInteger ) minute {
    NSUInteger hour = minute/60;
    NSUInteger lMinute = minute % 60;
    return [NSString stringWithFormat:@"%02d:%02d",hour,lMinute];
}


// MARK: - Getter  控件懒加载 

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [UIImageView new];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (UILabel *)funtablabel {
    if (!_funtablabel) {
        _funtablabel = [UILabel new];
        _funtablabel.font = [UIFont systemFontOfSize:11];
        _funtablabel.textColor = [UIColor blackColor];
        _funtablabel.textAlignment = NSTextAlignmentCenter;
    }
    return _funtablabel;
}

- (UILabel *)labelCountDown {
    if (!_labelCountDown) {
        self.labelCountDown = [[UILabel alloc] init];
        _labelCountDown.textColor = [UIColor whiteColor];
        _labelCountDown.textAlignment = NSTextAlignmentCenter;
        _labelCountDown.font = [UIFont systemFontOfSize:12];
    }
    return _labelCountDown;
}

@end
