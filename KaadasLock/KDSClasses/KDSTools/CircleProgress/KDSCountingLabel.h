//
//  KDSCountingLabel.h
//  KaadasLock
//
//  Created by Frank Hu on 2019/5/18.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSCountingLabel : UILabel

@property (nonatomic, assign) CGFloat duration;

- (void)countingFrom:(CGFloat)fromValue to:(CGFloat)toValue;
- (void)countingFrom:(CGFloat)fromValue to:(CGFloat)toValue duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
