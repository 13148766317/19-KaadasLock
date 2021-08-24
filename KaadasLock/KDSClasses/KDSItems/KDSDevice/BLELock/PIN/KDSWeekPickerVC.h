//
//  KDSWeekPickerVC.h
//  KaadasLock
//
//  Created by orange on 2019/4/3.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSWeekPickerVC : KDSBaseViewController

///表示已选的日期。低位起分别表示星期日 ~ 星期六，最高位留0，1选中。
@property (nonatomic, assign) char mask;
///选择完毕执行的回调，参数mask参考属性mask。
@property (nonatomic, copy) void(^didSelectWeekBlock) (char mask);

@end

NS_ASSUME_NONNULL_END
