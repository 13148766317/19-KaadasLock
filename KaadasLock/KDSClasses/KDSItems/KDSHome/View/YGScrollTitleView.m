//
//  ScrollViewTopView.m
//  滚动视图
//
//  Created by wuyiguang on 15/12/5.
//  Copyright (c) 2015年 YG. All rights reserved.
//

#import "YGScrollTitleView.h"
#import "YGScrollTitleBottomLineView.h"
#import "GatewayDeviceModel.h"
#import "MyDevice.h"
#import "KDSZeroFireSingleModel.h"
#import "KDSWifiLockModel.h"


// 按钮的起始tag
#define kBtnTag 777
// 图片按钮
#define kImageTag 1111
// 每屏所显示按钮的最大个数
#define kSingleViewBtnCount 3

// 按钮的超出部分
#define kBtnBeyondWidth 5

@interface YGScrollTitleView ()

@property (nonatomic, copy) CallBack block;
///文字按钮
@property (nonatomic,strong)NSMutableArray<UIButton *> *labelList;
///图片按钮
@property (nonatomic,strong)NSMutableArray<UIButton *> *imgList;
///下划线
@property (nonatomic,strong) YGScrollTitleBottomLineView * topLine;
///记录当前选择的按钮
@property (nonatomic,assign)NSInteger index;
///记录titles count
@property (nonatomic,assign)NSInteger titlesCount;
///按钮宽度
@property (nonatomic,assign)  CGFloat btnWidth;
@property (nonatomic,strong) UIScrollView * scrollView;

@end

@implementation YGScrollTitleView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles callBack:(CallBack)block
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        _titlesCount = titles.count;
        self.block = block;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        [self addMySubViewWithTitles:titles];
    }
    return self;
}

-(void)addMySubViewWithTitles:(NSArray *)titles
{
    // 计算按钮的宽度
    if (titles.count <= kSingleViewBtnCount) {
        _btnWidth = self.bounds.size.width / titles.count;
    } else {
        _btnWidth = self.bounds.size.width / kSingleViewBtnCount + kBtnBeyondWidth;
    }
    
    _scrollView.contentSize = CGSizeMake(titles.count * _btnWidth, _scrollView.bounds.size.height);
    
    for (int i = 0; i < titles.count; i++)
    {
        //为了搞间距
        CGFloat imgWidth = _btnWidth/2;
        UIButton  *imgVBtn = [[UIButton alloc] initWithFrame:CGRectMake(_btnWidth * i+_btnWidth/4, 0, imgWidth, 20)];
        imgVBtn.tag = kImageTag + i;
        [self.imgList addObject:imgVBtn];
        imgVBtn.backgroundColor = [UIColor clearColor];
        imgVBtn.contentMode = UIViewContentModeScaleAspectFit;
        id model = titles[i];
        GatewayDeviceModel * gwM;MyDevice * deM;KDSWifiLockModel * wifiM;KDSZeroFireSingleModel * zeroFModel;
        KDSDeviceHangerModel *hangerModel;
        NSString * titleStr;
        if ([model isKindOfClass:[GatewayDeviceModel class]]) {
            ///猫眼、网关锁
            gwM = (GatewayDeviceModel *)model;
            titleStr = gwM.nickName ?:gwM.deviceId;
            if ([gwM.device_type isEqualToString:@"kdscateye"]) {///猫眼
                [imgVBtn setImage:[UIImage imageNamed:@"非当前猫眼"] forState:UIControlStateNormal];
                [imgVBtn setImage:[UIImage imageNamed:@"当前猫眼"] forState:UIControlStateSelected];
            }else{
                [imgVBtn setImage:[UIImage imageNamed:@"非当前门锁"] forState:UIControlStateNormal];
                [imgVBtn setImage:[UIImage imageNamed:@"当前门锁"] forState:UIControlStateSelected];
            }
        }else if ([model isKindOfClass:[MyDevice class]]){
            deM = (MyDevice *)model;
            titleStr = deM.lockNickName ?: deM.lockNickName;
            [imgVBtn setImage:[UIImage imageNamed:@"非当前门锁"] forState:UIControlStateNormal];
            [imgVBtn setImage:[UIImage imageNamed:@"当前门锁"] forState:UIControlStateSelected];
        }else if ([model isKindOfClass:KDSWifiLockModel.class]){
            wifiM = (KDSWifiLockModel *)model;
            titleStr = wifiM.lockNickname ?: wifiM.wifiSN;
            [imgVBtn setImage:[UIImage imageNamed:@"非当前门锁"] forState:UIControlStateNormal];
            [imgVBtn setImage:[UIImage imageNamed:@"当前门锁"] forState:UIControlStateSelected];
        }else if ([model isKindOfClass:KDSZeroFireSingleModel.class]){
            zeroFModel = (KDSZeroFireSingleModel *)model;
            titleStr = zeroFModel.name;
            [imgVBtn setImage:[UIImage imageNamed:@"off-zeroFireTitleImg"] forState:UIControlStateNormal];
            [imgVBtn setImage:[UIImage imageNamed:@"on-zeroFireTitleImg"] forState:UIControlStateSelected];
            
        }else if ([model isKindOfClass:[KDSDeviceHangerModel class]]) {
            hangerModel = (KDSDeviceHangerModel *) model;
            titleStr = hangerModel.hangerNickName;
            [imgVBtn setImage:[UIImage imageNamed:@"hanger_tab"] forState:UIControlStateNormal];
            [imgVBtn setImage:[UIImage imageNamed:@"hanger_tab_selected"] forState:UIControlStateSelected];
        }
        
        [imgVBtn addTarget:self action:@selector(ImgbtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn = [self createBtn:CGRectMake(_btnWidth * i , 20, _btnWidth, self.bounds.size.height-20) title:titleStr];
        [_scrollView addSubview:btn];
        [_scrollView addSubview:imgVBtn];
        btn.tag = kBtnTag + i;
        [self.labelList addObject:btn];
        if (i == 0) {
            btn.selected = YES;
            imgVBtn.selected = YES;
            _index = 0;
            
            // 线条
            _topLine = [[YGScrollTitleBottomLineView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-5, _btnWidth, 2)];
            [_topLine configWithTitlsCount:titles.count];
            _topLine.backgroundColor = [UIColor clearColor];
            _topLine.contentView.backgroundColor = [UIColor whiteColor];
            [_scrollView addSubview:_topLine];
        }
    }
}
- (UIButton *)createBtn:(CGRect)frame title:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
   //%@ btn.frame = CGRectMake(frame.origin.x, frame.origin.y, 50, frame.size.height);;
    NSString   * titleStr ;
#warning   zhu修改的地方
    if ( title.length > 5) {
        NSString  * titleheadStr = [title substringToIndex:2 ];
        NSString  * middel= @"...";
        NSString  * titletailStr = [title  substringFromIndex:title.length-3];
      titleStr = [NSString stringWithFormat:@"%@%@%@",titleheadStr,middel,titletailStr];
    }else{
        titleStr = title;
    }
    // 修改文字显现
    btn.titleLabel.lineBreakMode  = NSLineBreakByTruncatingMiddle;
    [btn setTitle:titleStr forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTitleColor:KDSRGBColor(133, 182, 242) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void)btnClick:(UIButton *)sender
{
    if (sender.selected) return;
    
    sender.selected = YES;
    
    UIButton *oldBtn = (UIButton *)[_scrollView viewWithTag:kBtnTag + _index];
    
    oldBtn.selected = NO;
    
    // 记录新的下标
    _index = sender.tag - kBtnTag;
    
    // 回调
    if (self.block) {
        self.block(_index);
    }
    [self selectedImgBtnIndex:_index];
}

-(void)ImgbtnClick:(UIButton *)sender{
    
    if (sender.selected) return;
    
    sender.selected = YES;
    
    UIButton *oldBtn = (UIButton *)[_scrollView viewWithTag:kImageTag + _index];
    
    oldBtn.selected = NO;
    
    // 记录新的下标
    _index = sender.tag - kImageTag;
    
    // 回调
    if (self.block) {
        self.block(_index);
    }
    [self labelBtnIndex:_index];
}

/**
 选择对应的按钮
 */
- (void)selectButtonIndex:(NSInteger)index
{

    [self labelBtnIndex:index];
    [self  selectedImgBtnIndex:index];
}
//---记录文字btn选中
-(void)labelBtnIndex:(NSInteger )index{
    
    UIButton *btn = (UIButton *)[_scrollView viewWithTag:kBtnTag + index];
    for (UIButton *labelBtn in self.labelList) {
        labelBtn.selected = NO;
    }
        btn.selected = YES;
        // 记录
        _index = index;
}

//---记录图片btn选中
-(void)selectedImgBtnIndex:(NSInteger)index{
    
    UIButton *btn = (UIButton *)[_scrollView viewWithTag:kImageTag + index];
    for (UIButton *imgBtn in self.imgList) {
        imgBtn.selected = NO;
    }
    btn.selected = YES;
    
    // 记录
    _index = index;
}
/**
 设置底部线条的实时偏移量
 */
- (void)moveTopViewLine:(CGPoint)point
{
    CGRect rect = _topLine.frame;
    
    if (_titlesCount <= kSingleViewBtnCount)
    {
        rect.origin.x = point.x / _titlesCount;
    }
    else
    {
        // 计算超过kSingleViewBtnCount个数按钮的线条偏移量
        rect.origin.x = (point.x / kSingleViewBtnCount) + (point.x / self.bounds.size.width * kBtnBeyondWidth);
    }
    
    _topLine.frame = rect;
    
    // 修改scrollView的偏移量
    [_scrollView scrollRectToVisible:rect animated:NO];
}

-(NSMutableArray<UIButton *> *)labelList{
    if (!_labelList) {
        _labelList = [NSMutableArray new];
    }
    return _labelList;
}
-(NSMutableArray<UIButton *> *)imgList{
    if (!_imgList) {
        _imgList  = [NSMutableArray new];
    }
    return _imgList;
}
@end
