//
//  AlarmFileShowViewController.h
//  lock
//
//  Created by wzr on 2019/4/11.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "KDSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlarmFileShowViewController : KDSBaseViewController
@property(nonatomic,strong)NSString *currentPicDate;    //当前正在操作的日期 :2019-05-09
@property (nonatomic,readwrite,strong) GatewayDeviceModel * gatewayDeviceModel;
@property(nonatomic,strong)NSString *currentFileName;    //当前正在操作的文件名称
@end

NS_ASSUME_NONNULL_END
