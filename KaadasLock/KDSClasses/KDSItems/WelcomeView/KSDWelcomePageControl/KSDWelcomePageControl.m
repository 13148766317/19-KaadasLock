//
//  KSDWelcomePageControl.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/3.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KSDWelcomePageControl.h"

#define kItemWidth      9
#define margin          KDSSSALE_WIDTH(15)
@implementation KSDWelcomePageControl

-(instancetype)init{
    self = [super init];
    if (self) {
        if (@available(iOS 14.0, *)) {
        
        } else {
            self.userInteractionEnabled = YES;
            self.pageIndicatorTintColor = [UIColor clearColor];
            self.currentPageIndicatorTintColor = KDSRGBColor(52, 196, 255);
        }
        
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (@available(iOS 14.0, *)) {
    
    } else {
        //计算圆点间距
        CGFloat marginX = margin + 3;
        //计算整个pageControll的宽度
        CGFloat newW = (self.subviews.count - 1 ) * marginX;
        //设置新frame
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newW, self.frame.size.height);
        //设置居中
        CGPoint center = self.center;
        center.x = self.superview.center.x;
        self.center = center;
        //遍历subview,设置圆点frame
        for (int i=0; i<[self.subviews  count]; i++) {
            UIImageView* dot = [self.subviews objectAtIndex:i];
            [dot setFrame:CGRectMake(i * marginX, dot.frame.origin.y, kItemWidth, kItemWidth)];
        }

    }
    
 }

-(void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    
    if (@available(iOS 14.0, *)) {
    
    } else {
        for (NSUInteger subViewIndex = 0; subViewIndex<[self.subviews count];subViewIndex++) {
            UIView *subView = [self.subviews objectAtIndex:subViewIndex];
            [subView setFrame:CGRectMake(subView.frame.origin.x, subView.frame.origin.y, kItemWidth, kItemWidth)];
            if (subViewIndex == currentPage) {
                //当前样式
                subView.layer.masksToBounds = YES;
                subView.layer.cornerRadius = kItemWidth/2;
              //  subView.layer.borderWidth = 1;
                subView.layer.borderColor = self.currentPageIndicatorTintColor.CGColor;
            }else{
                //其他样式
                subView.layer.masksToBounds = YES;
                subView.layer.cornerRadius = kItemWidth/2;
                //subView.layer.borderWidth = 1;
                subView.backgroundColor = KDSRGBColor(160, 197, 212);
            }
        }
    }
    
}
@end
