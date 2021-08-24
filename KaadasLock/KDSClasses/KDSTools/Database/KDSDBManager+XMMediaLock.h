//
//  KDSDBManager+XMMediaLock.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/24.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSDBManager.h"
#import "KDSXMMediaLockModel.h"

NS_ASSUME_NONNULL_BEGIN

///视频锁相关的数据处理
@interface KDSDBManager (XMMediaLock)

///在数据库中创建网关分表，在KDSDBManager实现文件中打开数据库时调用。@warning 其它地方不要调用这个方法。
- (void)createXMMediaLockTableInDB:(FMDatabase *)db;

/**
 *@abstract 视频锁实时视频截图缓存到数据库。
 *@param data 截图数据。
 *@param imageName 图片地址。
 *@return 参考FMDatabase类的executeUpdate方法。
 */
- (BOOL)insertXMMediaCutScreenData:(nullable NSData *)data withImageName:(NSString *)imageName mp4Address:(NSString *)mp4Address deviceSn:(NSString *)deviceSn;

/**
 *@abstract 查询本地保存的已绑定视频锁的截图、录屏列表。
 *@return 已绑定视频锁列表，can be nil.
 */
- (nullable NSArray<KDSXMMediaLockModel *> *)queryBindedRecordAndCutFileWithDeviceSn:(NSString *)deviceSn;

@end

NS_ASSUME_NONNULL_END
