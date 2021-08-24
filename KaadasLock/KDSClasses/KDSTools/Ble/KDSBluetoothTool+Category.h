//
//  KDSBluetoothTool+Category.h
//  BLETest
//
//  Created by zhaowz on 2018/4/25.
//  Copyright © 2018年 zhaowz. All rights reserved.
//

#import "KDSBluetoothTool.h"

@interface KDSBluetoothTool (Category)
//父类的方法 在分类中实现
- (void)dealWithReceiveOldBleModelData:(NSData *)data;
- (void)sendConfirmDataToOldBleDevice;
- (void)oldBleModelbeginGetElectric;
- (void)oldBleModelbeginOpenLock;
- (void)sendReveiveInNetOrOutNetDatToOldBleDevice;
- (void)oldBleModelSendInNetSuccessDada;
- (void)oldBleModelSendGetHistoryRecoryOrder;
@end
