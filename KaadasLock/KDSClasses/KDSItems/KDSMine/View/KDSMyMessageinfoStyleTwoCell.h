//
//  KDSMyMessageinfoStyleTwoCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSMyMessageinfoStyleTwoCell : UITableViewCell
///发布时间：fm:-mm-dd HH:mm
@property(nonatomic,readwrite,strong)UILabel * timeLabel;
///第二种cell：title、icone、time
@property(nonatomic,readwrite,strong)UILabel * titleLabel;
///内容
@property(nonatomic,readwrite,strong)UILabel * detailLabel;

@end

NS_ASSUME_NONNULL_END
