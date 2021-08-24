//
//  KDSXMMediaDownloadPlayVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/30.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"
#import "KDSWifiLockAlarmModel.h"

NS_ASSUME_NONNULL_BEGIN
////此类是先下载成功再去播放抓拍的视频（后期如果需要的话，可以用此类优化）
@interface KDSXMMediaDownloadPlayVC : KDSAutoConnectViewController

@property (nonatomic,strong)KDSWifiLockAlarmModel * model;

@end

NS_ASSUME_NONNULL_END
