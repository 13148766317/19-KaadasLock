//
//  KDSHomePageLockStatusCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/3/28.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSHomePageLockStatusCell : UITableViewCell

///开锁时间:（yyyy-MM-dd ）暂用时分----HH:mm
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
///一般状态是灰色圆圈，低电量会特殊提示
@property (weak, nonatomic) IBOutlet UIImageView *dynamicImageView;
///cell展示的竖线，圆圈的上部分
@property (weak, nonatomic) IBOutlet UILabel *topLine;
///cell展示的竖线，圆圈的下部分
@property (weak, nonatomic) IBOutlet UILabel *bottomLine;
///开锁方式：密码开锁、手机开锁、（右边的Lb）
@property (weak, nonatomic) IBOutlet UILabel *unlockModeLabel;
///开锁者alarmRecBtn（左边的Lb）
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
///当alarmTableView的cell的时候才会显示
@property (weak, nonatomic) IBOutlet UILabel *alarmRecLabel;

@end

NS_ASSUME_NONNULL_END
