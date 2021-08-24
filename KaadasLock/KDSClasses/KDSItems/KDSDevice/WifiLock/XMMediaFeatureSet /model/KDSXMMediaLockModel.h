//
//  KDSXMMediaLockModel.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSXMMediaLockModel : NSObject
///视频锁的SN
@property (nonatomic, copy) NSString *deviceSN;
///视频锁截图的data
@property (nonatomic, copy) NSData *lockCutData;
///视频锁截图的名称
@property (nonatomic, copy) NSString *imageName;
///录屏视频的地址
@property (nonatomic, copy) NSString *mp4Address;
///视频锁的录屏data
@property (nonatomic, copy) NSData *lockRecordScreenData;
///视频锁的录屏的名称
@property (nonatomic, copy) NSString *recordScreenMP4Name;


@end

NS_ASSUME_NONNULL_END
