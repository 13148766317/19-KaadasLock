//
//  KDSGesturePwdView.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/1.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGesturePwdView.h"



@interface KDSGesturePwdView ()

///画手势时显示手势密码的图片视图的数组。
@property (nonatomic, strong) NSMutableArray<UIImageView *> *gestureImageViews;
///画中的显示手势密码的图片的视图的数组。
@property (nonatomic, strong) NSMutableArray<UIImageView *> *selectedGestureImageViews;
///选中不带箭头的手势密码图片。
@property (nonatomic, strong) UIImage *selectedImg;
///选中且带箭头的手势密码图片。
@property (nonatomic, strong) UIImage *selectedArrowImg;
///未选中的手势密码图片。
@property (nonatomic, strong) UIImage *unselectedImg;
///错误的手势密码图片。
@property (nonatomic, strong) UIImage *errorImg;
///错误且带箭头的手势密码图片。
@property (nonatomic, strong) UIImage *errorArrowImg;
///手指移动过程中的当前点，如果手指已抬起，将当前点的坐标设置为NaN(默认)。
@property (nonatomic, assign) CGPoint currentPoint;


@end


@implementation KDSGesturePwdView

- (NSMutableArray<UIImageView *> *)selectedGestureImageViews
{
    if (!_selectedGestureImageViews)
    {
        _selectedGestureImageViews = [NSMutableArray array];
    }
    return _selectedGestureImageViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self drawImagesAndImageViews];
        self.currentPoint = (CGPoint){NAN, NAN};
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.selectedGestureImageViews.count == 0) return;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 3);
    NSUInteger count = self.selectedGestureImageViews.count;
    UIImageView *iv = self.selectedGestureImageViews.firstObject;
    for (NSUInteger i = 0; i < count; ++i)
    {
        iv = self.selectedGestureImageViews[i];
        if (i == 0)
        {
            CGContextMoveToPoint(ctx, iv.center.x, iv.center.y);
        }
        else
        {
            CGContextAddLineToPoint(ctx, iv.center.x, iv.center.y);//绘制手势路径
        }
        if (count > 1 && i < count - 1)
        {
            //不是最后一个加箭头
            if (iv.image == self.selectedImg)
            {
                iv.image = self.selectedImg;
            }
            else if (iv.image == self.errorImg)
            {
                iv.image = self.errorImg;
            }
            if (CGAffineTransformIsIdentity(iv.transform))//如果转置矩阵没有改变过，改变转置矩阵使得箭头和绘制顺序一致。
            {
                UIImageView *nextIV = self.selectedGestureImageViews[i + 1];
                //y = ax + b，通过求y1-y2、x1-x2求a和b。
                CGFloat y1_y2 = iv.center.y - nextIV.center.y;
                CGFloat x1_x2 = iv.center.x - nextIV.center.x;
                if (x1_x2 == 0)//无斜率。箭头垂直向上或向下
                {
                    CGFloat coe = iv.center.y>nextIV.center.y ? -1 : 1;
                    iv.transform = CGAffineTransformRotate(iv.transform, coe * M_PI_2);
                }
                else if (y1_y2 == 0)//斜率为0，箭头水平向左或向右
                {
                    CGFloat radian = iv.center.x>nextIV.center.x ? M_PI : 0;
                    iv.transform = CGAffineTransformRotate(iv.transform, radian);
                }
                else//2点组成的直线有斜率且不等于0
                {
                    CGFloat a = y1_y2 / x1_x2;
                    CGFloat radian = a * y1_y2 < 0 ? atan(a) : (atan(a) - M_PI);
                    iv.transform = CGAffineTransformRotate(iv.transform, radian);
                }
            }
        }
    }
    if (!isnan(self.currentPoint.x))//手指抬起后不画最后一条线。
    {
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
    }
    CGContextSetStrokeColorWithColor(ctx, (iv.image==self.errorImg || iv.image==self.errorArrowImg) ? KDSRGBColor(0xdb, 0x39, 0x2b).CGColor : KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
}

///初始化时执行的绘制图片和手势视图的方法。
- (void)drawImagesAndImageViews
{
    UIGraphicsBeginImageContext(CGSizeMake(outerRingDiameter, outerRingDiameter));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, innerRingRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    self.unselectedImg = img;
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(outerRingDiameter, outerRingDiameter));
    ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, contentInnerRingRadius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, innerRingRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    img = UIGraphicsGetImageFromCurrentImageContext();
    self.selectedImg = img;
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(outerRingDiameter, outerRingDiameter));
    ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, contentInnerRingRadius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, innerRingRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    //绘制高为4且3等分大小圆间距(包括大圆线宽1)的等边三角形。
    CGContextMoveToPoint(ctx, 47, 25.5);
    CGContextAddLineToPoint(ctx, 43, 25.5 - sqrt(16.0 / 3));
    CGContextAddLineToPoint(ctx, 43, 25.5 + sqrt(16.0 / 3));
    CGContextMoveToPoint(ctx, 47, 25.5);
//    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0x1f, 0x96, 0xf7).CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    img = UIGraphicsGetImageFromCurrentImageContext();
    self.selectedArrowImg = img;
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(outerRingDiameter, outerRingDiameter));
    ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, contentInnerRingRadius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0xdb, 0x39, 0x2b).CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, innerRingRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(ctx, KDSRGBColor(0xdb, 0x39, 0x2b).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    img = UIGraphicsGetImageFromCurrentImageContext();
    self.errorImg = img;
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(CGSizeMake(outerRingDiameter, outerRingDiameter));
    ctx = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(ctx, true);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, contentInnerRingRadius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0xdb, 0x39, 0x2b).CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, outerRingDiameter/2, outerRingDiameter/2, innerRingRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(ctx, KDSRGBColor(0xdb, 0x39, 0x2b).CGColor);
    CGContextDrawPath(ctx, kCGPathStroke);
    //绘制高为4且3等分大小圆间距(包括大圆线宽1)的等边三角形。
    CGContextMoveToPoint(ctx, 47, 25.5);
    CGContextAddLineToPoint(ctx, 43, 25.5 - sqrt(16.0 / 3));
    CGContextAddLineToPoint(ctx, 43, 25.5 + sqrt(16.0 / 3));
    CGContextMoveToPoint(ctx, 47, 25.5);
//    CGContextSetFillColorWithColor(ctx, KDSRGBColor(0xdb, 0x39, 0x2b).CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFill);
    img = UIGraphicsGetImageFromCurrentImageContext();
    self.errorArrowImg = img;
    UIGraphicsEndImageContext();
    
    self.backgroundColor = UIColor.clearColor;
    self.gestureImageViews = [NSMutableArray array];
    CGFloat x = (self.bounds.size.width - outerRingDiameter*3 - marginLeftAndRight*2) / 2;
    CGFloat y = (self.bounds.size.height - outerRingDiameter*3 - marginLeftAndRight*2) / 2;
    for (int i = 0; i < 9; ++i)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(x + i%3*(circlePadding), y + i/3*circlePadding, outerRingDiameter, outerRingDiameter)];
        iv.image = self.unselectedImg;
        [self.gestureImageViews addObject:iv];
        [self addSubview:iv];
    }
}

#pragma mark - 重载UIResponder的touches的4个方法，拦截触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [touches.anyObject locationInView:self];
    UIImageView *iv = [self pointIsInTheBoundsOfGestureImageView:point];
    if (iv)
    {
        [KDSRGBColor(0x1f, 0x96, 0xf7) setFill];
        [self.selectedGestureImageViews addObject:iv];
        iv.image = self.selectedImg;
        self.currentPoint = point;
        if ([self.delegate respondsToSelector:@selector(gesturePwdViewDidBegin:firstPwd:)])
        {
            [self.delegate gesturePwdViewDidBegin:self firstPwd:@([self.gestureImageViews indexOfObject:iv] + 1)];
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
    if (!isnan(self.currentPoint.x))
    {
        CGPoint point = [touches.anyObject locationInView:self];
        self.currentPoint = point;
        UIImageView *iv = [self pointIsInTheBoundsOfGestureImageView:point];
        if (iv && ![self.selectedGestureImageViews containsObject:iv])
        {
            [self.selectedGestureImageViews addObject:iv];
            iv.image = self.selectedImg;
        }
        [self setNeedsDisplay];//刷新绘制路径
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UIImageView *iv in self.selectedGestureImageViews)
    {
        iv.image = self.unselectedImg;
        iv.transform = CGAffineTransformIdentity;
    }
    [self.selectedGestureImageViews removeAllObjects];
    [self setNeedsDisplay];//刷新为初始化绘制页面
    self.currentPoint = (CGPoint){NAN, NAN};
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
    if (isnan(self.currentPoint.x)) return;
    //让用户看1秒绘制完毕的手势，然后恢复画面。
    self.userInteractionEnabled = NO;
    self.currentPoint = (CGPoint){NAN, NAN};
    [self setNeedsDisplay];//消除最后一条线。
    NSMutableArray<NSNumber *> *pwds = [NSMutableArray array];
    NSUInteger count = self.selectedGestureImageViews.count;
    for (UIImageView *iv in self.selectedGestureImageViews)
    {
        [pwds addObject:@([self.gestureImageViews indexOfObject:iv] + 1)];
        if (count < 4) iv.image = self.errorImg;
    }
    if (count < 4)//小于4个手势密码，绘制失败。
    {
        [self setNeedsDisplay];//刷新错误绘制路径
        if ([self.delegate respondsToSelector:@selector(gesturePwdViewDidFail:passwords:)])
        {
            [self.delegate gesturePwdViewDidFail:self passwords:pwds.copy];
        }
    }
    else//绘制完成，获取到手势密码。
    {
        if ([self.delegate respondsToSelector:@selector(gesturePwdViewDidComplete:passwords:)])
        {
            [self.delegate gesturePwdViewDidComplete:self passwords:pwds.copy];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.userInteractionEnabled = YES;
        for (UIImageView *iv in self.selectedGestureImageViews)
        {
            iv.image = self.unselectedImg;
            iv.transform = CGAffineTransformIdentity;
        }
        [self.selectedGestureImageViews removeAllObjects];
        [self setNeedsDisplay];//刷新为初始化绘制页面
        if ([self.delegate respondsToSelector:@selector(gesturePwdViewDidEnd:)])//绘制结束
        {
            [self.delegate gesturePwdViewDidEnd:self];
        }
    });
}

///根据触摸点判断该点是否处于九宫格的手势指示视图中，如果该视图包含点且未被选中返回该视图，否则返回nil。
- (nullable UIImageView *)pointIsInTheBoundsOfGestureImageView:(CGPoint)point
{
    for (UIImageView *iv in self.gestureImageViews)
    {
        if (iv.image == self.selectedImg) continue;
        if (CGRectContainsPoint(iv.frame, point))
        {
            return iv;
        }
    }
    return nil;
}

- (void)setIsWrongPwd:(BOOL)isWrongPwd
{
    _isWrongPwd = isWrongPwd;
    if (!isWrongPwd) return;
    for (UIImageView *iv in self.selectedGestureImageViews)
    {
        iv.image = self.errorArrowImg;
    }
    self.selectedGestureImageViews.lastObject.image = self.errorImg;
    [self setNeedsDisplay];//刷新错误绘制路径
}

@end
