//
//  CYCircularSlider.m
//  CYCircularSlider
//
//  Created by user on 2018/3/23.
//  Copyright © 2018年 com. All rights reserved.
//

#import "CYCircularSlider.h"

#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )
@implementation CYCircularSlider{
    int _angle;
    CGFloat radius;
    int _fixedAngle;
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumValue = 100.0f;
        self.minimumValue = 0.0f;
        self.currentValue = 0.0f;
        self.lineWidth = 5.0f;
        self.unfilledColor = [UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f];;
        self.filledColor = KDSRGBColor(95, 226, 231);
        self.handleColor = UIColor.whiteColor;// UIColor.whiteColor;
        radius = self.frame.size.height/2 - _lineWidth/2-20;
        _angle = 400;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return  self;
}

#pragma mark 画圆
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    //画固定的下层圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI/180*140, M_PI/180*40, 0);
    [_unfilledColor setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    //画可滑动的上层圆
    [self drawBigHandle:ctx];
    [self drawHandle:ctx];
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI/180*140, M_PI/180*(_angle), 0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 渐变色的颜色
    NSArray *colorArr = @[
                          (id)KDSRGBColor(95, 226, 231).CGColor,
                          (id)KDSRGBColor(23, 123, 209).CGColor,
                          ];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colorArr, NULL);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    CGContextReplacePathWithStrokedPath(ctx);
    CGContextClip(ctx);
    // 4. 用渐变色填充
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(0, rect.size.height / 2), CGPointMake(rect.size.width, rect.size.height / 2), 0);
    CGGradientRelease(gradient);
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
}
#pragma mark 画按钮
-(void)drawHandle:(CGContextRef)ctx{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle +3.5];
    [UIColor.whiteColor set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-4, handleCenter.y-4, _lineWidth+8, _lineWidth+8));
    CGContextRestoreGState(ctx);
    
}
-(void)drawBigHandle:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle +3.5];
    [KDSRGBColor(229, 229, 229) set];
    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x-5, handleCenter.y-5, _lineWidth+10, _lineWidth+10));
    CGContextRestoreGState(ctx);
}

-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Define the Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(angleInt)));
    result.x = round(centerPoint.x + radius * cos(ToRad(angleInt)));
    
    return result;
}

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    return YES;
}

-(BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    //用于排除点在圆外面点与圆心半径80以内的点
    if ((lastPoint.x>=0&&lastPoint.x<=275)&&(lastPoint.y>=0 && lastPoint.y<=275)) {
        
        if ((lastPoint.x<=57.5 ||lastPoint.x>=217.5)||(lastPoint.y<=57.5 ||lastPoint.y>=217.5)) {
//            [self moveHandle:lastPoint];
        }
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)moveHandle:(CGPoint)point {
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    if (currentAngle>40 && currentAngle <140) {
    }else{
        if (currentAngle<=40) {
            _angle = currentAngle+360;
        }else{
            _angle = currentAngle;
        }
        
    }
    _currentValue =[self valueFromAngle];
    [self setNeedsDisplay];
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

//在这个地方调整进度条
-(float) valueFromAngle {
    if(_angle <= 40) {
        _currentValue = 220+_angle;
    } else if(_angle>40 && _angle < 140){
        
    }else{
        _currentValue = _angle-100-40;
    }
    _fixedAngle = _currentValue;
    
    return (_currentValue*(_maximumValue - _minimumValue))/260.0f;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    [self.delegate senderVlueWithNum:(int8_t)roundf(_currentValue)];
}

#pragma mark 设置进度条位置
-(void)setAngel:(int)num{
    _angle = num;
    [self setNeedsDisplay];
}

-(void)setAddAngel{
    _angle += (int)260/(_maximumValue - _minimumValue);
    if (_angle>400) {
        _angle = 400;
    }
    [self setNeedsDisplay];
}

-(void)setMovAngel{
    _angle -= (int)260/(_maximumValue - _minimumValue);
    if (_angle<140) {
        _angle = 140;
    }
    [self setNeedsDisplay];
}


-(void)setAngleCurrent:(int)num
{
     int myNum = 0;
       myNum = num;
       int unit = (int)260/(_maximumValue - _minimumValue);
       _angle = myNum * unit;
       if (_angle>400) {
           _angle = 400;
       }
       [self setNeedsDisplay];
}




@end
