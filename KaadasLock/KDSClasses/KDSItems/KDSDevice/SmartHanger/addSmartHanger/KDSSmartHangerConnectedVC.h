//
//  KDSSmartHangerConnectedVC.h
//  KaadasLock
//
//  Created by Frank Hu on 2021/1/8.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "KDSBluetoothTool.h"
#import "KDSSmartHangerWiFiPwdVerificationVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSmartHangerConnectedVC : KDSBaseViewController <KDSBluetoothToolDelegate>


@property (nonatomic, weak) KDSBluetoothTool *bleTool;

@property (nonatomic, strong) CBPeripheral *destPeripheral;

@property (nonatomic, strong) UIImageView *smartHangerConnectedImg;

@property (nonatomic, strong) UILabel *label;

@end

NS_ASSUME_NONNULL_END
