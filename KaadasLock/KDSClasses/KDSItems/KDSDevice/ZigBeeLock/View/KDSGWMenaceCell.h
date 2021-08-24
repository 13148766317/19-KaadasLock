//
//  KDSGWMenaceCell.h
//  KaadasLock
//
//  Created by orange on 2019/4/29.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSGWMenaceCell : UITableViewCell

///名称。
@property (nonatomic, strong) NSString *name;
///是否隐藏分隔线，默认否。
@property (nonatomic, assign) BOOL hideSeparator;

@end

NS_ASSUME_NONNULL_END
