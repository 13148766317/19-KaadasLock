//
//  XMPlayBarView.m
//  XMDemo
//
//  Created by xunmei on 2020/9/1.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import "XMPlayBarView.h"

@interface XMPlayBarView ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSMutableArray<UIButton *> * funSetBtns;
@end

@implementation XMPlayBarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
//    if (@available(iOS 13.0, *)) {
//        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
//        if (mode == UIUserInterfaceStyleDark) {
//            self.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
//        } else if (mode == UIUserInterfaceStyleLight) {
//            self.backgroundColor = [UIColor darkGrayColor];
//        }
//    } else {
//        self.backgroundColor = [UIColor lightGrayColor];
//    }
    [self addSubview:self.stackView];
    NSArray *normalImageNames = @[@"截图",@"静音",@"对讲",@"录屏",@"相册"];
    NSArray *selectedImageNames = @[@"截图 选中",@"video_icon_silence_seleted",@"对讲 选中",@"video_icon_recording screen_seleted",@"相册 选中"];
    NSArray *buttonTitles = @[@"截图",@"静音",@"对讲",@"录屏",@"相册"];
    for (int i = 0; i < normalImageNames.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        CGFloat btnWidth = KDSScreenWidth/5;
        if (i != 2) {
            [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
            button.frame = CGRectMake(i*btnWidth, 20, btnWidth, 67);
            [button setImage:[UIImage imageNamed:normalImageNames[i]] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:selectedImageNames[i]] forState:UIControlStateSelected];
            
        }else{
            self.voiceSmallBtn= [UIButton buttonWithType:UIButtonTypeCustom];
            self.voiceSmallBtn.frame = CGRectMake(i*btnWidth, 56, btnWidth, 10);
            [self.voiceSmallBtn setTitle:@"对讲" forState:UIControlStateNormal];
            [self.voiceSmallBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            [self.voiceSmallBtn setTitle:@"对讲中" forState:UIControlStateSelected];
            [self.voiceSmallBtn setTitleColor:UIColor.whiteColor forState:UIControlStateSelected];
            self.voiceSmallBtn.titleLabel.font = [UIFont systemFontOfSize:11];
            self.voiceSmallBtn.selected = NO;
            [self addSubview:self.voiceSmallBtn];
            button.frame = CGRectMake(i*btnWidth, 10, btnWidth, 67);
            [button setImage:[UIImage imageNamed:@"icon_voice"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"icon_talking"] forState:UIControlStateSelected];
        }
        
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        if (i != 2) {
            CGFloat    space = 5;// 图片和文字的间距
            CGFloat    imageHeight = button.currentImage.size.height;
            CGFloat    imageWidth = button.currentImage.size.width;
            CGFloat    titleHeight = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].height;
            CGFloat    titleWidth = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width;
            [button setImageEdgeInsets:UIEdgeInsetsMake(-(imageHeight*0.5 + space*0.5), titleWidth*0.5, imageHeight*0.5 + space*0.5, -titleWidth*0.5)];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(titleHeight*0.5 + space*0.5, -imageWidth*0.5, -(titleHeight*0.5 + space*0.5), imageWidth*0.5)];
        }
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:button];
        [self.funSetBtns addObject:button];
        [self bringSubviewToFront:self.voiceSmallBtn];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat margin = 16.0;
    CGSize size = self.bounds.size;
    self.stackView.frame = CGRectMake(margin, 0, size.width - margin * 2, size.height);
    
}

- (void)setPlayBarViewButtonType:(XMPlayBarViewButtonType)type enabled:(BOOL)enabled {
    for (UIButton *button in self.funSetBtns) {
        if (button.tag == type) {
            button.enabled = enabled;
            break;
        }
    }
}

- (void)setPlayBarViewButtonType:(XMPlayBarViewButtonType)type state:(XMPlayBarViewButtonState)state {
    for (UIButton * btn in self.funSetBtns) {
        if (btn.tag == type) {
            if (state == XMPlayBarViewButtonStateSelected) {
                btn.selected = true;
            } else {
                btn.selected = false;
            }
            break;
        }
    }
}

- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 2) {
        NSLog(@"对讲中的选择状态");
        if (button.selected == YES) {
            self.voiceSmallBtn.selected = NO;
        }else{
            self.voiceSmallBtn.selected = YES;
        }
        
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(XMPlayBarView:buttonClicked:type:)]) {
        [self.delegate XMPlayBarView:self buttonClicked:button type:button.tag];
    }
}

- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [UIStackView new];
        self.stackView.spacing = 0;
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        self.stackView.alignment = UIStackViewAlignmentCenter;
        self.stackView.distribution = UIStackViewDistributionEqualCentering;
    }
    return _stackView;
}

- (NSMutableArray<UIButton *> *)funSetBtns
{
    if (!_funSetBtns) {
        _funSetBtns = [NSMutableArray array];
    }
    return _funSetBtns;
}

@end
